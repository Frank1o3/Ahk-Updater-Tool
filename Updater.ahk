; Settings
Persistent

/*
 *
 * Made By Frank1o3
 * Version 0.5
 *
 * Note
 * The script may have some bugs
 * and if it does report them to me
 *
 * My GitHub : https://github.com/Frank1o3
 *
*/

; Check wifi access func
InternetCheck() {
    local state := DllCall("wininet\InternetGetConnectedState", "Ptr*", 0, "Int", 0, "Int")
    return state
}

;Variables
Wifi := InternetCheck()
MsgBox Wifi

if !Wifi {
    files := AA.getRepoFiles("thqby", "ahk2_lib")
    handler := HTTP()
}

DownloadLoc := "C:\Users\" . A_UserName . "\Downloads"
Version := ""
LibsUrl := []
LibsUpdate := Array(false, false, false, false, false)
Update := false
Wifi := false


; Get Lib Urls
if !Wifi {
    for fl in files {
        if (fl["type"] == "file") {
            if fl["download_url"] != "" {
                d := StrSplit(fl["download_url"], "/")
                name := d.Get(d.Length)
                if name == "JSON.ahk" {
                    LibsUrl.Push(fl["download_url"])
                } else if name == "Socket.ahk" {
                    LibsUrl.Push(fl["download_url"])
                } else if name == "WebSocket.ahk" {
                    LibsUrl.Push(fl["download_url"])
                } else if name == "Winhttp.ahk" {
                    LibsUrl.Push(fl["download_url"])
                } else if name == "WinHttpRequest.ahk" {
                    LibsUrl.Push(fl["download_url"])
                }
            }
        }
    }
}

; Gui Setup
myGui := Gui()
myGui.Add("Text", "x8 y8 w125 h24 +0x200", "Install/Update Ahk v2 Libs")
Status := myGui.Add("Text", "x155 y8 w125 h24 +0x200", "Wifi Status: ")
CheckBox1 := myGui.Add("CheckBox", "x8 y32 w120 h23", "Json lib")
CheckBox2 := myGui.Add("CheckBox", "x8 y56 w120 h23", "Socket Lib")
CheckBox3 := myGui.Add("CheckBox", "x8 y80 w120 h23", "WebSocket Lib")
CheckBox4 := myGui.Add("CheckBox", "x8 y104 w120 h23", "WinHttp Lib")
CheckBox5 := myGui.Add("CheckBox", "x8 y128 w120 h23", "WinHttpRequest Lib")
ButtonCheck := myGui.Add("Button", "x0 y152 w80 h23", "&Check")
myGui.Add("Text", "x85 y153 w147 h22 +0x200", "Check for any Ahk v2 Updates")
ButtonUpdate := myGui.Add("Button", "x0 y176 w80 h23", "&Update Ahk")
LibUpdate := myGui.Add("Button", "x81 y176 w80 h23", "&Update Libs")
myGui.Title := "Updater"
myGui.Show("w267 h200")

; Gui Event's
ButtonCheck.OnEvent("Click", UpdateCheck)
ButtonUpdate.OnEvent("Click", UpdateAhk)
LibUpdate.OnEvent("Click", UpdateLib)
CheckBox1.OnEvent("Click", CheckUpdate)
CheckBox2.OnEvent("Click", CheckUpdate)
CheckBox3.OnEvent("Click", CheckUpdate)
CheckBox4.OnEvent("Click", CheckUpdate)
CheckBox5.OnEvent("Click", CheckUpdate)
myGui.OnEvent('Close', (*) => ExitApp())

; Check if user Got Wifi
Status.Value := Format("Wifi Status: {1}", Wifi ? "Connected" : "Disconnected")

; Gui Event Handling

CheckUpdate(e, _) {
    global Wifi
    if !Wifi {
        return
    }
    global LibsUpdate
    switch e.Text {
        case "Json lib":
            LibsUpdate.InsertAt(1, !LibsUpdate.Get(1))
            return
        case "Socket Lib":
            LibsUpdate.InsertAt(2, !LibsUpdate.Get(2))
            return
        case "WebSocket Lib":
            LibsUpdate.InsertAt(3, !LibsUpdate.Get(3))
            return
        case "WinHttp Lib":
            LibsUpdate.InsertAt(4, !LibsUpdate.Get(4))
            return
        case "WinHttpRequest Lib":
            LibsUpdate.InsertAt(5, !LibsUpdate.Get(5))
            return
    }
}

UpdateLib(*) {
    global LibsUpdate
    global LibsUrl
    global Wifi
    if !Wifi {
        return
    }
    local updatelibs := Array(
        LibsUpdate.Get(1) ? LibsUrl.Get(1) : false,
        LibsUpdate.Get(2) ? LibsUrl.Get(2) : false,
            LibsUpdate.Get(3) ? LibsUrl.Get(3) : false,
            LibsUpdate.Get(4) ? LibsUrl.Get(4) : false,
            LibsUpdate.Get(5) ? LibsUrl.Get(5) : false
    )
    for v in updatelibs {
        if v != false {
            if !DirExist(A_MyDocuments . "\AutoHotkey\Lib\") {
                DirCreate(A_MyDocuments . "\AutoHotkey\Lib\")
            }
            d := StrSplit(v, "/") ; get the file name
            ToolTip Format("Downloading : {1}", d.Get(d.Length)) ; get the file name
            try {
                Download(v, d.Get(d.Length)) ; Download the file
            } catch Error as e {
                MsgBox "Failed to download file: " . e.Message
                continue
            }
            Sleep 1000
            if FileExist(A_MyDocuments . "\AutoHotkey\Lib\" . d.Get(d.Length)) { ; check if it exist
                FileDelete(A_MyDocuments . "\AutoHotkey\Lib\" . d.Get(d.Length)) ; if it does delete it
            }
            if FileExist(d.Get(d.Length)) { ; check if the file was downloaded
                ToolTip "Moving File : " . d.Get(d.Length)
                try {
                    FileMove(A_ScriptDir . "\" . d.Get(d.Length), A_MyDocuments . "\AutoHotkey\Lib\" . d.Get(d.Length)) ; if it was move it to the libs dir
                    ToolTip()
                } catch Error as e {
                    MsgBox "Failed to move file: " . e.Message
                    continue
                }
                Sleep 1000
            }
        }
    }
}

UpdateAhk(*)
{
    global Update
    global Version
    global Wifi
    if !Wifi {
        return
    }
    if Update {
        try {
            local location := Format("{1}\AutoHotkey_{2}_setup.exe", A_ScriptDir, Version)
            Download("https://www.autohotkey.com/download/ahk-v2.exe", location) ; Download the excutable
        } catch TypeError as e {
            MsgBox e.Message
        }
        Sleep 100
        if FileExist(location) { ; check if file wass downloaded
            FileMove(location, DownloadLoc . "\AutoHotkey_" . Version . "_setup.exe")
            location := DownloadLoc . "\AutoHotkey_" . Version . "_setup.exe"
            if A_IsAdmin { ; Check if user is admin
                Run location
            } else {
                MsgBox "Ahk v2 installer was donwloaded at : " . location
            }
        }
    }
}

UpdateCheck(*) {
    global handler
    global Wifi
    if !Wifi {
        return
    }
    v := handler.Get("https://www.autohotkey.com/download/2.0/version.txt", 4)
    if StrCompare(v, A_AhkVersion) == 0 {
        global Update
        Update := false
        MsgBox "You'r Ahk is up to date."
    } else {
        global Update
        global Version
        Update := true
        Version := v
        MsgBox "You Need To Update Your Ahk."
    }
}
; Classes

class HTTP {
    __Init() {
        this.req := ComObject('WinHttp.WinHttpRequest.5.1') ; Interface for http request
    }
    OpenRequest(method, url) { ; Open the request
        this.req.Open(method, url)
    }
    SendRequest(data := "", limit := 10) { ; Send the request
        this.req.Send(data)
        attempts := 0
        while (this.req.Status != 200) {
            if (this.req.Status == 404) {
                break
            } else if (this.req.Status == 204 && this.req.Status != 200) {
                return
            }
            attempts++
            if (attempts > limit) {  ; change this number to adjust the maximum number of attempts
                throw Error("Maximum attempts exceeded", -1)
            }
            Sleep 100
        }
        str := this.req.ResponseText
        return str
    }
    Get(url, limit) { ; Function for Get request. Works
        this.OpenRequest("GET", url)
        return this.SendRequest(, limit)
    }
}

Class AA {
    static Load(&src, args*) {
        key := "", is_key := false
        stack := [tree := []]
        next := '"{[01234567890-tfn'
        pos := 0
        while ((ch := SubStr(src, ++pos, 1)) != "") {
            if InStr(" `t`n`r", ch)
                continue
            if !InStr(next, ch, true) {
                testArr := StrSplit(SubStr(src, 1, pos), "`n")
                ln := testArr.Length
                col := pos - InStr(src, "`n", , -(StrLen(src) - pos + 1))
                msg := Format("{}: line {} col {} (char {})"
                    , (next == "") ? ["Extra data", ch := SubStr(src, pos)][1]
                    : (next == "'") ? "Unterminated string starting at"
                        : (next == "\") ? "Invalid \escape"
                        : (next == ":") ? "Expecting ':' delimiter"
                        : (next == '"') ? "Expecting object key enclosed in double quotes"
                        : (next == '"}') ? "Expecting object key enclosed in double quotes or object closing '}'"
                        : (next == ",}") ? "Expecting ',' delimiter or object closing '}'"
                        : (next == ",]") ? "Expecting ',' delimiter or array closing ']'"
                        : ["Expecting JSON value(string, number, [true, false, null], object or array)"
                            , ch := SubStr(src, pos, (SubStr(src, pos) ~= "[\]\},\s]|$") - 1)][1]
                    , ln, col, pos)
                throw Error(msg, -1, ch)
            }
            obj := stack[1]
            is_array := (obj is Array)
            if i := InStr("{[", ch) { ; start new object / map?
                val := (i = 1) ? Map() : Array()	; ahk v2
                is_array ? obj.Push(val) : obj[key] := val
                stack.InsertAt(1, val)
                next := '"' ((is_key := (ch == "{")) ? "}" : "{[]0123456789-tfn")
            } else if InStr("}]", ch) {
                stack.RemoveAt(1)
                next := (stack[1] == tree) ? "" : (stack[1] is Array) ? ",]" : ",}"
            } else if InStr(",:", ch) {
                is_key := (!is_array && ch == ",")
                next := is_key ? '"' : '"{[0123456789-tfn'
            } else { ; string | number | true | false | null
                if (ch == '"') { ; string
                    i := pos
                    while i := InStr(src, '"', , i + 1) {
                        val := StrReplace(SubStr(src, pos + 1, i - pos - 1), "\\", "\u005C")
                        if (SubStr(val, -1) != "\")
                            break
                    }
                    if !i ? (pos--, next := "'") : 0
                        continue
                    pos := i ; update pos
                    val := StrReplace(val, "\/", "/")
                    val := StrReplace(val, '\"', '"')
                        , val := StrReplace(val, "\b", "`b")
                        , val := StrReplace(val, "\f", "`f")
                        , val := StrReplace(val, "\n", "`n")
                        , val := StrReplace(val, "\r", "`r")
                        , val := StrReplace(val, "\t", "`t")
                    i := 0
                    while i := InStr(val, "\", , i + 1) {
                        if (SubStr(val, i + 1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
                            continue 2
                        xxxx := Abs("0x" . SubStr(val, i + 2, 4)) ; \uXXXX - JSON unicode escape sequence
                        if (xxxx < 0x100)
                            val := SubStr(val, 1, i - 1) . Chr(xxxx) . SubStr(val, i + 6)
                    }
                    if is_key {
                        key := val, next := ":"
                        continue
                    }
                } else { ; number | true | false | null
                    val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$", , pos) - pos)
                    if IsInteger(val)
                        val += 0
                    else if IsFloat(val)
                        val += 0
                    else if (val == "true" || val == "false")
                        val := (val == "true")
                    else if (val == "null")
                        val := ""
                    else if is_key {
                        pos--, next := "#"
                        continue
                    }
                    pos += i - 1
                }
                is_array ? obj.Push(val) : obj[key] := val
                next := obj == tree ? "" : is_array ? ",]" : ",}"
            }
        }
        return tree[1]
    }
    static jsonDownload(URL) {
        Http := ComObject("WinHttp.WinHttpRequest.5.1")
        Http.Open("GET", URL)
        Http.Send()
        Http.WaitForResponse()
        storage := Http.ResponseText
        return storage ;Set the "text" variable to the response
    }
    static processRepo(url) {
        data := this.jsonDownload(url)
        return this.Load(&data)
    }
    static getRepoFiles(Username, Repository_Name) {
        url := "https://api.github.com/repos/" Username "/" Repository_Name "/contents/"
        data := this.processRepo(url)
        return data
    }
}