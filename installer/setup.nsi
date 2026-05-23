; ══════════════════════════════════════════════════════════
;  CompressPro 安装程序 (NSIS)
;  编译: makensis setup.nsi
;  输出: CompressPro_Setup.exe
; ══════════════════════════════════════════════════════════

!include "MUI2.nsh"
!include "FileFunc.nsh"

; ─── 基本信息 ───
Name "CompressPro"
OutFile "CompressPro_Setup.exe"
InstallDir "$PROGRAMFILES64\CompressPro"
InstallDirRegKey HKLM "Software\CompressPro" "InstallDir"
RequestExecutionLevel admin

!define PRODUCT_VERSION "1.0.0"
!define REG_UNINSTALL "Software\Microsoft\Windows\CurrentVersion\Uninstall\CompressPro"
!define REG_COMPRESS  "Software\CompressPro"

; ─── 应用文件目录（相对于 installer\） ───
!define APP_DIR "..\publish-app"

; ─── 页面 ───
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\LICENSE"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$INSTDIR\CompressPro.exe"
!define MUI_FINISHPAGE_RUN_TEXT "启动 CompressPro"
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; ─── 语言 ───
!insertmacro MUI_LANGUAGE "SimpChinese"

; ══════════════════════════════════════════════════════════
;  安装段
; ══════════════════════════════════════════════════════════

; ─── 主程序（必选） ───
Section "CompressPro 主程序" SEC_CORE
    SectionIn RO
    SetOutPath "$INSTDIR"

    File "${APP_DIR}\CompressPro.exe"
    File "${APP_DIR}\*.dll"
    File "${APP_DIR}\*.json"
    File "${APP_DIR}\*.pdb"
    File "${APP_DIR}\CompressPro.runtimeconfig.json"

    WriteUninstaller "$INSTDIR\Uninstall.exe"

    ; 卸载信息
    WriteRegStr HKLM "${REG_UNINSTALL}" "DisplayName" "CompressPro 压缩解压工具"
    WriteRegStr HKLM "${REG_UNINSTALL}" "DisplayVersion" "${PRODUCT_VERSION}"
    WriteRegStr HKLM "${REG_UNINSTALL}" "Publisher" "CompressPro"
    WriteRegStr HKLM "${REG_UNINSTALL}" "UninstallString" "$INSTDIR\Uninstall.exe"
    WriteRegStr HKLM "${REG_UNINSTALL}" "DisplayIcon" "$INSTDIR\CompressPro.exe"
    WriteRegDWORD HKLM "${REG_UNINSTALL}" "NoModify" 1
    WriteRegDWORD HKLM "${REG_UNINSTALL}" "NoRepair" 1
    WriteRegStr HKLM "${REG_UNINSTALL}" "InstallLocation" "$INSTDIR"
    WriteRegStr HKLM "${REG_UNINSTALL}" "URLInfoAbout" "https://github.com/compresspro"
    ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
    WriteRegDWORD HKLM "${REG_UNINSTALL}" "EstimatedSize" "$0"

    ; 快捷方式
    CreateDirectory "$SMPROGRAMS\CompressPro"
    CreateShortCut "$SMPROGRAMS\CompressPro\CompressPro.lnk" "$INSTDIR\CompressPro.exe"
    CreateShortCut "$SMPROGRAMS\CompressPro\卸载 CompressPro.lnk" "$INSTDIR\Uninstall.exe"
    CreateShortCut "$DESKTOP\CompressPro.lnk" "$INSTDIR\CompressPro.exe"

    WriteRegStr HKLM "${REG_COMPRESS}" "InstallDir" "$INSTDIR"
SectionEnd

; ─── 右键菜单 ───
Section "右键菜单" SEC_CONTEXT
    WriteRegDWORD HKLM "${REG_COMPRESS}" "InstalledContext" 1

    WriteRegStr HKCR "*\shell\CompressPro" "" "用 CompressPro 打开"
    WriteRegStr HKCR "*\shell\CompressPro" "Icon" "$INSTDIR\CompressPro.exe,0"
    WriteRegStr HKCR "*\shell\CompressPro\command" "" '"$INSTDIR\CompressPro.exe" "open" "%1"'

    WriteRegStr HKCR "CompressPro.7z\shell\extract" "" "解压到..."
    WriteRegStr HKCR "CompressPro.7z\shell\extract" "Icon" "$INSTDIR\CompressPro.exe,0"
    WriteRegStr HKCR "CompressPro.7z\shell\extract\command" "" '"$INSTDIR\CompressPro.exe" "extract" "%1"'

    WriteRegStr HKCR "CompressPro.7z\shell\extracthere" "" "解压到当前目录"
    WriteRegStr HKCR "CompressPro.7z\shell\extracthere" "Icon" "$INSTDIR\CompressPro.exe,0"
    WriteRegStr HKCR "CompressPro.7z\shell\extracthere\command" "" '"$INSTDIR\CompressPro.exe" "extracthere" "%1"'

    WriteRegStr HKCR "AllFilesystemObjects\shell\CompressProAdd" "" "添加到 CompressPro 压缩包..."
    WriteRegStr HKCR "AllFilesystemObjects\shell\CompressProAdd" "Icon" "$INSTDIR\CompressPro.exe,0"
    WriteRegStr HKCR "AllFilesystemObjects\shell\CompressProAdd\command" "" '"$INSTDIR\CompressPro.exe" "add" "%1"'
SectionEnd

; ─── 文件关联 ───
SectionGroup /e "文件格式关联"

    Section ".7z" SEC_7Z
        WriteRegDWORD HKLM "${REG_COMPRESS}" "Assoc_7z" 1
        WriteRegStr HKCR ".7z" "" "CompressPro.7z"
        WriteRegStr HKCR "CompressPro.7z" "" "7-Zip 压缩包"
        WriteRegStr HKCR "CompressPro.7z\DefaultIcon" "" "$INSTDIR\CompressPro.exe,1"
        WriteRegStr HKCR "CompressPro.7z\shell\open\command" "" '"$INSTDIR\CompressPro.exe" "open" "%1"'
    SectionEnd

    Section ".zip" SEC_ZIP
        WriteRegDWORD HKLM "${REG_COMPRESS}" "Assoc_Zip" 1
        WriteRegStr HKCR ".zip" "" "CompressPro.Zip"
        WriteRegStr HKCR "CompressPro.Zip" "" "ZIP 压缩包"
        WriteRegStr HKCR "CompressPro.Zip\DefaultIcon" "" "$INSTDIR\CompressPro.exe,2"
        WriteRegStr HKCR "CompressPro.Zip\shell\open\command" "" '"$INSTDIR\CompressPro.exe" "open" "%1"'
    SectionEnd

    Section ".rar" SEC_RAR
        WriteRegDWORD HKLM "${REG_COMPRESS}" "Assoc_Rar" 1
        WriteRegStr HKCR ".rar" "" "CompressPro.Rar"
        WriteRegStr HKCR "CompressPro.Rar" "" "RAR 压缩包"
        WriteRegStr HKCR "CompressPro.Rar\DefaultIcon" "" "$INSTDIR\CompressPro.exe,3"
        WriteRegStr HKCR "CompressPro.Rar\shell\open\command" "" '"$INSTDIR\CompressPro.exe" "open" "%1"'
    SectionEnd

    Section ".tar / .tar.gz / .tar.bz2" SEC_TAR
        WriteRegDWORD HKLM "${REG_COMPRESS}" "Assoc_Tar" 1
        WriteRegStr HKCR ".tar" "" "CompressPro.Tar"
        WriteRegStr HKCR "CompressPro.Tar\DefaultIcon" "" "$INSTDIR\CompressPro.exe,4"
        WriteRegStr HKCR "CompressPro.Tar\shell\open\command" "" '"$INSTDIR\CompressPro.exe" "open" "%1"'
        WriteRegStr HKCR ".gz" "" "CompressPro.Gz"
        WriteRegStr HKCR ".tgz" "" "CompressPro.Tgz"
        WriteRegStr HKCR ".bz2" "" "CompressPro.Bz2"
    SectionEnd

    Section ".iso / .cab / .wim" SEC_OTHER
        WriteRegDWORD HKLM "${REG_COMPRESS}" "Assoc_Other" 1
        WriteRegStr HKCR ".iso" "" "CompressPro.Iso"
        WriteRegStr HKCR ".cab" "" "CompressPro.Cab"
        WriteRegStr HKCR ".wim" "" "CompressPro.Wim"
        WriteRegStr HKCR ".vhd" "" "CompressPro.Vhd"
    SectionEnd

SectionGroupEnd

; ─── 安装后刷新 ───
Section -Post
    System::Call 'shell32.dll::SHChangeNotify(l, l, i, i) v (0x08000000, 0, 0, 0)'
SectionEnd

; ══════════════════════════════════════════════════════════
;  卸载
; ══════════════════════════════════════════════════════════

Section "Uninstall"
    ReadRegStr $INSTDIR HKLM "${REG_COMPRESS}" "InstallDir"

    ; 删除程序
    Delete "$INSTDIR\CompressPro.exe"
    Delete "$INSTDIR\*.dll"
    Delete "$INSTDIR\*.json"
    RMDir /r "$INSTDIR"

    ; 删除右键菜单
    ReadRegDWORD $0 HKLM "${REG_COMPRESS}" "InstalledContext"
    IntCmp $0 1 done_ctx
    DeleteRegKey HKCR "*\shell\CompressPro"
    DeleteRegKey HKCR "CompressPro.7z\shell\extract"
    DeleteRegKey HKCR "CompressPro.7z\shell\extracthere"
    DeleteRegKey HKCR "AllFilesystemObjects\shell\CompressProAdd"
    done_ctx:

    ; 删除文件关联
    DeleteRegKey HKCR ".7z"
    DeleteRegKey HKCR ".zip"
    DeleteRegKey HKCR ".rar"
    DeleteRegKey HKCR ".tar"
    DeleteRegKey HKCR ".gz"
    DeleteRegKey HKCR ".tgz"
    DeleteRegKey HKCR ".bz2"
    DeleteRegKey HKCR ".iso"
    DeleteRegKey HKCR ".cab"
    DeleteRegKey HKCR ".wim"
    DeleteRegKey HKCR ".vhd"

    DeleteRegKey HKCR "CompressPro.7z"
    DeleteRegKey HKCR "CompressPro.Zip"
    DeleteRegKey HKCR "CompressPro.Rar"
    DeleteRegKey HKCR "CompressPro.Tar"
    DeleteRegKey HKCR "CompressPro.Gz"
    DeleteRegKey HKCR "CompressPro.Tgz"
    DeleteRegKey HKCR "CompressPro.Bz2"
    DeleteRegKey HKCR "CompressPro.Iso"
    DeleteRegKey HKCR "CompressPro.Cab"
    DeleteRegKey HKCR "CompressPro.Wim"
    DeleteRegKey HKCR "CompressPro.Vhd"

    ; 删除卸载信息
    DeleteRegKey HKLM "${REG_UNINSTALL}"
    DeleteRegKey HKLM "${REG_COMPRESS}"

    ; 删除快捷方式
    Delete "$SMPROGRAMS\CompressPro\CompressPro.lnk"
    Delete "$SMPROGRAMS\CompressPro\卸载 CompressPro.lnk"
    RMDir "$SMPROGRAMS\CompressPro"
    Delete "$DESKTOP\CompressPro.lnk"

    System::Call 'shell32.dll::SHChangeNotify(l, l, i, i) v (0x08000000, 0, 0, 0)'
SectionEnd
