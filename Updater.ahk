; Settings
Persistent
#Include Class.ahk

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

;Variables
files := AA.getRepoFiles("thqby", "ahk2_lib")
DownloadLoc := "C:\Users\" . A_UserName . "\Downloads"
handler := HTTP()
Version := ""
LibsUrl := []
LibsUpdate := Array(false,false,false,false,false)
Update := false
Wifi := false


; Get Lib Urls
for fl in files {
    if (fl["type"] == "file") {
        if fl["download_url"] != "" {
            d := StrSplit(fl["download_url"],"/")
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

; Gui Setup
myGui := Gui()
myGui.Add("Text", "x8 y8 w125 h24 +0x200", "Install/Update Ahk v2 Libs")
Status := myGui.Add("Text" , "x135 y8 w125 h24 +0x200","Wifi Status: ")
CheckBox1 := myGui.Add("CheckBox", "x8 y32 w120 h23", "Json lib")
CheckBox2 := myGui.Add("CheckBox", "x8 y56 w120 h23", "Socket Lib")
CheckBox3 := myGui.Add("CheckBox", "x8 y80 w120 h23", "WebSocket Lib")
CheckBox4 := myGui.Add("CheckBox", "x8 y104 w120 h23", "WinHttp Lib")
CheckBox5 := myGui.Add("CheckBox", "x8 y128 w120 h23", "WinHttpRequest Lib")
ButtonCheck := myGui.Add("Button", "x0 y152 w80 h23", "&Check")
myGui.Add("Text", "x80 y152 w147 h22 +0x200", "Check for any Ahk v2 Updates")
ButtonUpdate := myGui.Add("Button", "x0 y176 w80 h23", "&Update Ahk")
LibUpdate := myGui.Add("Button", "x81 y176 w80 h23", "&Update Libs")
ButtonCheck.OnEvent("Click", UpdateCheck)
ButtonUpdate.OnEvent("Click", UpdateAhk)
LibUpdate.OnEvent("Click", UpdateLib)
myGui.OnEvent('Close', (*) => ExitApp())
myGui.Title := "Updater"
myGui.Show("w267 h200")

; Check if user Got Wifi
Wifi := InternetCheck()
Status.Value := Format("Wifi Status: {1}",Wifi ? "Connected":"Disconnected")

; Gui Event Handling
CheckBox1.OnEvent("Click", CheckUpdate)
CheckBox2.OnEvent("Click", CheckUpdate)
CheckBox3.OnEvent("Click", CheckUpdate)
CheckBox4.OnEvent("Click", CheckUpdate)
CheckBox5.OnEvent("Click", CheckUpdate)

CheckUpdate(e,_) {
    global LibsUpdate
    switch e.Text {
        case "Json lib":
            LibsUpdate.InsertAt(1,e.Value)
            return
        case "Socket Lib":
            LibsUpdate.InsertAt(2,e.Value)
            return
        case "WebSocket Lib":
            LibsUpdate.InsertAt(3,e.Value)
            return
        case "WinHttp Lib":
            LibsUpdate.InsertAt(4,e.Value)
            return
        case "WinHttpRequest Lib":
            LibsUpdate.InsertAt(5,e.Value)
            return
        default:
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
        LibsUpdate.Get(1) ? LibsUrl.Get(1):false,
        LibsUpdate.Get(2) ? LibsUrl.Get(2):false,
        LibsUpdate.Get(3) ? LibsUrl.Get(3):false,
        LibsUpdate.Get(4) ? LibsUrl.Get(4):false,
        LibsUpdate.Get(5) ? LibsUrl.Get(5):false
    )
    for v in updatelibs {
        if v != false {
            if !DirExist(A_MyDocuments . "\AutoHotkey\Lib\") {
                DirCreate(A_MyDocuments . "\AutoHotkey\Lib\")
            }
            d := StrSplit(v,"/") ; get the file name
            ToolTip Format("Downloading : {1}", d.Get(d.Length)) ; get the file name
            Sleep 2000
            try {
                Download(v,d.Get(d.Length)) ; Download the file
            } catch Error as e {
                MsgBox "Failed to download file: " . e.Message
                continue
            }
            if FileExist(A_MyDocuments . "\AutoHotkey\Lib\" . d.Get(d.Length)) { ; check if it exist
                FileDelete(A_MyDocuments . "\AutoHotkey\Lib\" . d.Get(d.Length)) ; if it does delete it 
            }
            if FileExist(d.Get(d.Length)) { ; check if the file was downloaded
                ToolTip "Moving File : " . d.Get(d.Length)
                Sleep 2000
                try {
                    FileMove(A_ScriptDir . "\" . d.Get(d.Length),A_MyDocuments . "\AutoHotkey\Lib\" . d.Get(d.Length)) ; if it was move it to the libs dir
                    ToolTip()
                } catch Error as e {
                    MsgBox "Failed to move file: " . e.Message
                    continue
                }
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
            local location := Format("{1}\AutoHotkey_{2}_setup.exe",A_ScriptDir,Version)
            Download("https://www.autohotkey.com/download/ahk-v2.exe",location) ; Download the excutable
        } catch TypeError as e {
            MsgBox e.Message
        }
        Sleep 100
        if FileExist(location) { ; check if file wass downloaded
            FileMove(location,DownloadLoc . "\AutoHotkey_" . Version . "_setup.exe")
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
    v := handler.Get("https://www.autohotkey.com/download/2.0/version.txt",4)
    if StrCompare(v,A_AhkVersion) == 0 {
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

; Check wifi access func
InternetCheck() {
    local flags := DllCall("wininet\InternetGetConnectedState", "Ptr*", 0, "Int", 0, "Int")
    return flags != 0
}