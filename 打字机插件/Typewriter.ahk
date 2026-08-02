#Requires AutoHotkey v2.0
#SingleInstance Force
; ============================================================
; 打字机插件 Typewriter (AutoHotkey v2)
; ------------------------------------------------------------
; 有两种用法：
;   1) 手动：复制文字后按 Ctrl+Alt+T 逐字打出
;   2) 自动模式：按 Ctrl+Alt+D 开启"打字机模式"后，每次 Ctrl+V
;      粘贴会改成逐字打出；再按一次 Ctrl+Alt+D 关闭，恢复正常粘贴。
; 启动后静默后台运行，可在托盘图标右键退出。
; ============================================================

; ---------- 全局设置 ----------
SetKeyDelay(0, 0)            ; 关闭按键自带延迟，完全由下面控制
SetWinDelay(-1)
SetControlDelay(-1)
CoordMode("ToolTip", "Screen")
SendMode("Event")            ; 用 Event 模式，兼容性最好（Word/记事本/网页都能输入中文）

; ---------- 可调参数 ----------
global gDelay      := 80     ; 每个字间隔(毫秒)，可用快捷键加减
global gDelayMin   := 10
global gDelayMax   := 1000
global gTyping     := false  ; 是否正在打字
global gPaused     := false  ; 是否暂停
global gStop       := false  ; 是否停止
global gAutoMode   := false  ; 打字机模式开关（开启后 Ctrl+V 逐字打出）

; ---------- 托盘菜单 ----------
A_IconTip := "打字机插件 Typewriter"
TraySetIcon("shell32.dll", 44)   ; 用系统键盘图标
OnMessage(0x404, WM_NOTIFYICON)  ; 托盘左键双击显示提示
TrayTip("打字机插件已启动", "Ctrl+Alt+D 开启/关闭 打字机模式（替换粘贴）`nCtrl+Alt+T 手动开始打字", 3)

; ============================================================
; 快捷键
; ============================================================

; Ctrl+V : 打字机模式开启时，粘贴改为逐字打出；关闭时正常粘贴
$^v:: {
    if (gAutoMode && A_Clipboard != "") {
        StartTyping()
    } else {
        ; 正常粘贴
        Send("{Ctrl down}v{Ctrl up}")
    }
}

; Ctrl+Alt+D : 打字机模式开关（开启/关闭 Ctrl+V 逐字打字）
^!d:: {
    global gAutoMode
    gAutoMode := !gAutoMode
    if (gAutoMode)
        ShowTip("【打字机模式】已开启`n现在 Ctrl+V 会逐字打出剪贴板内容`n再按 Ctrl+Alt+D 关闭")
    else
        ShowTip("【打字机模式】已关闭`nCtrl+V 恢复为普通粘贴`n再按 Ctrl+Alt+D 开启")
}

; Ctrl+Alt+T : 手动开始打字（读取剪贴板）
^!t:: {
    StartTyping()
}

; Ctrl+Alt+P : 暂停 / 继续
^!p:: {
    TogglePause()
}

; Ctrl+Alt+S : 停止
^!s:: {
    StopTyping()
}

; Ctrl+Alt++ : 加速
^!+:: {
    gDelay := Max(gDelayMin, gDelay - 10)
    ShowTip("加速 → 间隔 " gDelay " 毫秒")
}

; Ctrl+Alt+- : 减速
^!-:: {
    gDelay := Min(gDelayMax, gDelay + 10)
    ShowTip("减速 → 间隔 " gDelay " 毫秒")
}

; Ctrl+Alt+Q : 退出
^!q:: {
    gStop := true
    gTyping := false
    Sleep(100)
    ExitApp()
}

; ---------- 任意键停止：注册所有常用按键热键 ----------
; 用 *~ 前缀：* = 任意修饰键组合都触发，~ = 不拦截原按键功能
; 打字中只要用户按任意物理键就停止；脚本自己 SendInput 注入的字符不会触发这些热键
global gTypingStartTick := 0    ; 打字开始时间，用于忽略触发键

stopKeys := ["a","b","c","d","e","f","g","h","i","j","k","l","m"
    ,"n","o","p","q","r","s","t","u","v","w","x","y","z"
    ,"0","1","2","3","4","5","6","7","8","9"
    ,"Left","Right","Up","Down","Home","End","PgUp","PgDn"
    ,"Space","Enter","Tab","Backspace","Delete","Insert"
    ,"F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12"
    ,"-","=","[","]","\",";","'",",",".","/","``"
    ,"Esc","CapsLock","NumLock","ScrollLock","PrintScreen","Pause"]

for k in stopKeys {
    try Hotkey("*~" k, OnUserKeyPress)
}

OnUserKeyPress(*) {
    global gTyping, gStop, gPaused, gTypingStartTick
    ; 只在打字中、且超过 300ms 宽限期才停止（避免触发键自身误停）
    if (gTyping && A_TickCount - gTypingStartTick > 300) {
        gStop := true
        gPaused := false
    }
}

; ============================================================
; 核心逻辑
; ============================================================

StartTyping() {
    global gTyping, gPaused, gStop
    if (gTyping) {
        ShowTip("正在打字中，按 Ctrl+Alt+S 停止")
        return
    }
    text := A_Clipboard
    if (text = "") {
        ShowTip("剪贴板为空！请先复制要打的文字")
        return
    }
    ; 去掉末尾换行
    text := RTrim(text, "`r`n")
    if (text = "") {
        ShowTip("剪贴板为空！请先复制要打的文字")
        return
    }
    ; 统一换行：把 \r\n 和单独的 \r 都换成 \n，保证逐字发送时换行正确
    text := StrReplace(text, "`r`n", "`n")
    text := StrReplace(text, "`r", "`n")

    gTyping := true
    gPaused := false
    gStop := false
    gTypingStartTick := A_TickCount

    ; 立即开始，无等待
    ShowTip("【打字机】开始打字，共 " StrLen(text) " 字`n按任意键即可停止")
    SetTimer(() => ToolTip(), -1000)

    ; 逐字输入
    Loop Parse, text {
        if (gStop)
            break
        ; 暂停等待
        while (gPaused && !gStop)
            Sleep(50)
        if (gStop)
            break

        ch := A_LoopField

        if (ch = "`n") {
            ; 换行：发 Enter 键，兼容 Word/记事本/网页等所有应用
            Send("{Enter}")
            Sleep(gDelay * 2)
        } else if (ch = "`t") {
            ; 制表符：发 Tab 键
            Send("{Tab}")
            Sleep(gDelay)
        } else {
            ; 普通字符（含空格）：用 Windows API 直接发 Unicode，绕过输入法
            SendUnicodeChar(ord(ch))
            Sleep(gDelay)
        }
    }

    gTyping := false
    if (!gStop)
        ShowTip("【打字机】打字完成 ✓")
    else
        ShowTip("【打字机】已停止")
    gStop := false
}

TogglePause() {
    global gTyping, gPaused
    if (!gTyping) {
        ShowTip("当前未在打字")
        return
    }
    gPaused := !gPaused
    if (gPaused)
        ShowTip("【打字机】已暂停，再按 Ctrl+Alt+P 继续")
    else
        ShowTip("【打字机】继续打字...")
}

StopTyping() {
    global gStop, gTyping, gPaused
    if (!gTyping) {
        ShowTip("当前未在打字")
        return
    }
    gStop := true
    gPaused := false
    ShowTip("【打字机】正在停止...")
}

; ---------- 辅助：屏幕居中提示 ----------
ShowTip(msg) {
    ToolTip(msg, A_ScreenWidth // 2 - 160, A_ScreenHeight // 2 - 40)
    SetTimer(() => ToolTip(), -1800)
}

; ---------- 辅助：用 Windows API 发送 Unicode 字符 ----------
; 直接调用 SendInput 发 Unicode 字符，绕过输入法，中文最可靠
SendUnicodeChar(charCode) {
    ; 处理代理对（emoji 等 4 字节字符）
    if (charCode > 0xFFFF) {
        ; 拆成高代理+低代理分别发送
        hi := 0xD800 + ((charCode - 0x10000) >> 10)
        lo := 0xDC00 + ((charCode - 0x10000) & 0x3FF)
        SendUnicodeInput(hi)
        SendUnicodeInput(lo)
    } else {
        SendUnicodeInput(charCode)
    }
}

SendUnicodeInput(scanCode) {
    ; INPUT 结构大小：type(4) + KEYBDINPUT(24) + padding(8) = 28 字节（含 type 共 32，但 SendInput 的 INPUT 是 28）
    ; 实际：sizeof(INPUT) 在 64 位下 = 40（type 4字节 + 填充4 + KEYBDINPUT 32），用 40
    INPUT_SIZE := 40
    ; 构造两个 INPUT（按下 + 抬起）
    buf := Buffer(INPUT_SIZE * 2, 0)

    ; 第1个：按下
    off := 0
    NumPut("UInt", 1, buf, off)               ; type = INPUT_KEYBOARD
    NumPut("UShort", 0, buf, off + 8)         ; wVk = 0
    NumPut("UShort", scanCode, buf, off + 10) ; wScan = unicode
    NumPut("UInt", 0x0004, buf, off + 12)     ; dwFlags = KEYEVENTF_UNICODE
    NumPut("UInt", 0, buf, off + 16)          ; time
    NumPut("Ptr", 0, buf, off + 24)           ; dwExtraInfo

    ; 第2个：抬起
    off := INPUT_SIZE
    NumPut("UInt", 1, buf, off)               ; type = INPUT_KEYBOARD
    NumPut("UShort", 0, buf, off + 8)         ; wVk = 0
    NumPut("UShort", scanCode, buf, off + 10) ; wScan = unicode
    NumPut("UInt", 0x0006, buf, off + 12)     ; dwFlags = KEYEVENTF_UNICODE | KEYEVENTF_KEYUP
    NumPut("UInt", 0, buf, off + 16)          ; time
    NumPut("Ptr", 0, buf, off + 24)           ; dwExtraInfo

    DllCall("SendInput", "UInt", 2, "Ptr", buf, "UInt", INPUT_SIZE)
}

; ---------- 托盘双击 ----------
WM_NOTIFYICON(wParam, lParam, *) {
    if (lParam = 0x203) {  ; WM_LBUTTONDBLCLK
        state := gAutoMode ? "开启" : "关闭"
        ShowTip("打字机插件运行中`n打字机模式：" state "`nCtrl+Alt+D 切换模式 | Ctrl+Alt+T 手动开始`n间隔 " gDelay "ms`n提示：" (gAutoMode ? "Ctrl+V 会逐字打出" : "Ctrl+V 正常粘贴"))
    }
}
