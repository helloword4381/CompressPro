; ══════════════════════════════════════════════════════════
;  CompressPro NSIS 安装脚本
;  功能: 安装主程序 + 右键菜单 + 文件关联 + 卸载
;  编译: makensis setup.nsi
; ══════════════════════════════════════════════════════════

!include "MUI2.nsh"
!include "FileFunc.nsh"
!include "WinVer.nsh"

; ─── 基本信息 ───
Name "CompressPro"
OutFile "CompressPro_Setup.exe"
InstallDir "$PROGRAMFILES64\CompressPro"
InstallDirRegKey HKLM "Software\CompressPro" "InstallDir"
RequestExecutionLevel admin

; ─── 版本 ───
!define PRODUCT_NAME "CompressPro"
!define PRODUCT_VERSION "1.0.0"
!define PRODUCT_PUBLISHER "CompressPro"
!define PRODUCT_WEB_SITE "https://github.com/compresspro"

; ─── 界面 ───
!define MUI_ABORTWARNING
!define MUI_ICON "..\src\CompressPro.Gui\Resources\app.ico"
!define MUI_UNICON "..\src\CompressPro.Gui\Resources\app.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "welcome.bmp"

; ─── 页面 ───
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\LICENSE"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$INSTDIR\CompressPro.exe"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\README.txt"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "English"

; ─── 安装段 ───
Section "Install" SecInstall
    SetOutPath "$INSTDIR"

    ; 复制主程序
    File "..\src\CompressPro.Gui\bin\Release\net8.0-windows\CompressPro.exe"
    File "..\src\CompressPro.Gui\bin\Release\net8.0-windows\*.dll"
    File "..\src\CompressPro.Gui\bin\Release\net8.0-windows\*.json"

    ; 复制 7z.dll (从外部依赖)
    File "..\external\7z.dll"

    ; ─── 右键菜单 (注册表) ───

    ; 1. "用 CompressPro 打开" (所有文件)
    WriteRegStr HKCR "*\shell\CompressPro" "" "用 CompressPro 打开"
    WriteRegStr HKCR "*\shell\CompressPro" "Icon" "$INSTDIR\CompressPro.exe,0"
    WriteRegStr HKCR "*\shell\CompressPro\command" "" '"$INSTDIR\CompressPro.exe" "open" "%1"'

    ; 2. "解压到..." (压缩包专有)
    WriteRegStr HKCR "7-Zip.7z\shell\CompressProExtract" "" "解压到..."
    WriteRegStr HKCR "7-Zip.7z\shell\CompressProExtract" "Icon" "$INSTDIR\CompressPro.exe,0"
    WriteRegStr HKCR "7-Zip.7z\shell\CompressProExtract\command" "" '"$INSTDIR\CompressPro.exe" "extract" "%1"'

    ; 3. "添加到压缩包..." (任意文件/文件夹)
    WriteRegStr HKCR "AllFilesystemObjects\shell\CompressProAdd" "" "添加到 CompressPro 压缩包..."
    WriteRegStr HKCR "AllFilesystemObjects\shell\CompressProAdd" "Icon" "$INSTDIR\CompressPro.exe,0"
    WriteRegStr HKCR "AllFilesystemObjects\shell\CompressProAdd\command" "" '"$INSTDIR\CompressPro.exe" "add" "%1"'

    ; 4. "解压到当前目录" (压缩包右键)
    WriteRegStr HKCR "7-Zip.7z\shell\CompressProExtractHere" "" "解压到当前目录"
    WriteRegStr HKCR "7-Zip.7z\shell\CompressProExtractHere" "Icon" "$INSTDIR\CompressPro.exe,0"
    WriteRegStr HKCR "7-Zip.7z\shell\CompressProExtractHere\command" "" '"$INSTDIR\CompressPro.exe" "extracthere" "%1"'

    ; ─── 文件关联 ───
    WriteRegStr HKCR ".7z" "" "CompressPro.7z"
    WriteRegStr HKCR "CompressPro.7z" "" "7-Zip Archive"
    WriteRegStr HKCR "CompressPro.7z\DefaultIcon" "" "$INSTDIR\CompressPro.exe,1"
    WriteRegStr HKCR "CompressPro.7z\shell\open\command" "" '"$INSTDIR\CompressPro.exe" "open" "%1"'

    WriteRegStr HKCR ".zip" "" "CompressPro.Zip"
    WriteRegStr HKCR "CompressPro.Zip" "" "ZIP Archive"
    WriteRegStr HKCR "CompressPro.Zip\DefaultIcon" "" "$INSTDIR\CompressPro.exe,2"
    WriteRegStr HKCR "CompressPro.Zip\shell\open\command" "" '"$INSTDIR\CompressPro.exe" "open" "%1"'

    WriteRegStr HKCR ".rar" "" "CompressPro.Rar"
    WriteRegStr HKCR "CompressPro.Rar" "" "RAR Archive"
    WriteRegStr HKCR "CompressPro.Rar\DefaultIcon" "" "$INSTDIR\CompressPro.exe,3"
    WriteRegStr HKCR "CompressPro.Rar\shell\open\command" "" '"$INSTDIR\CompressPro.exe" "open" "%1"'

    ; ─── 卸载信息 ───
    WriteUninstaller "$INSTDIR\Uninstall.exe"

    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CompressPro" \
        "DisplayName" "CompressPro - 轻量压缩解压工具"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CompressPro" \
        "DisplayVersion" "${PRODUCT_VERSION}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CompressPro" \
        "Publisher" "${PRODUCT_PUBLISHER}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CompressPro" \
        "UninstallString" "$INSTDIR\Uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CompressPro" \
        "DisplayIcon" "$INSTDIR\CompressPro.exe"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CompressPro" \
        "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CompressPro" \
        "NoRepair" 1
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CompressPro" \
        "InstallLocation" "$INSTDIR"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CompressPro" \
        "URLInfoAbout" "${PRODUCT_WEB_SITE}"

    ; 计算安装大小
    ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CompressPro" \
        "EstimatedSize" "$0"

    ; ─── 快捷方式 ───
    CreateDirectory "$SMPROGRAMS\CompressPro"
    CreateShortCut "$SMPROGRAMS\CompressPro\CompressPro.lnk" "$INSTDIR\CompressPro.exe"
    CreateShortCut "$SMPROGRAMS\CompressPro\卸载 CompressPro.lnk" "$INSTDIR\Uninstall.exe"
    CreateShortCut "$DESKTOP\CompressPro.lnk" "$INSTDIR\CompressPro.exe"

    ; ─── 环境变量 (自动添加到 PATH 可选) ───
    ; WriteRegStr HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment" \
    ;     "Path" "$INSTDIR;$PATH"
SectionEnd

; ─── 卸载段 ───
Section "Uninstall"
    ; 删除文件
    Delete "$INSTDIR\CompressPro.exe"
    Delete "$INSTDIR\*.dll"
    Delete "$INSTDIR\*.json"
    Delete "$INSTDIR\*.pdb"
    Delete "$INSTDIR\Uninstall.exe"
    RMDir "$INSTDIR"

    ; 删除右键菜单
    DeleteRegKey HKCR "*\shell\CompressPro"
    DeleteRegKey HKCR "7-Zip.7z\shell\CompressProExtract"
    DeleteRegKey HKCR "7-Zip.7z\shell\CompressProExtractHere"
    DeleteRegKey HKCR "AllFilesystemObjects\shell\CompressProAdd"

    ; 删除文件关联
    DeleteRegKey HKCR "CompressPro.7z"
    DeleteRegKey HKCR "CompressPro.Zip"
    DeleteRegKey HKCR "CompressPro.Rar"

    ; 删除卸载信息
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CompressPro"
    DeleteRegKey HKLM "Software\CompressPro"

    ; 删除快捷方式
    Delete "$SMPROGRAMS\CompressPro\CompressPro.lnk"
    Delete "$SMPROGRAMS\CompressPro\卸载 CompressPro.lnk"
    RMDir "$SMPROGRAMS\CompressPro"
    Delete "$DESKTOP\CompressPro.lnk"

    ; 刷新桌面图标 (通知 Explorer)
    System::Call 'shell32.dll::SHChangeNotify(l, l, i, i) v (0x08000000, 0, 0, 0)'
SectionEnd
