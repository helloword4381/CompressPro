; ══════════════════════════════════════════════════════════
;  CompressPro Installer (NSIS)
;  Build:  makensis setup.nsi
;  Output: CompressPro_Setup.exe
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

!define PRODUCT_NAME "CompressPro"
!define PRODUCT_VERSION "1.0.0"
!define PRODUCT_PUBLISHER "CompressPro"
!define PRODUCT_WEB_SITE "https://github.com/compresspro"

; ─── 安装选项注册表路径 (存用户选择，卸载时读取) ───
!define REG_ROOT "Software\Microsoft\Windows\CurrentVersion\Uninstall\CompressPro"
!define REG_INSTALL "Software\CompressPro"

; ─── 界面 ───
!define MUI_ABORTWARNING
; Optional bitmaps (header.bmp / welcome.bmp) go here

; ─── 页面 ───
; Welcome page uses default image
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\LICENSE"
!insertmacro MUI_PAGE_COMPONENTS      ; ← 组件选择页（核心 + 右键菜单 + 格式关联）
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_RUN "$INSTDIR\CompressPro.exe"
!define MUI_FINISHPAGE_RUN_TEXT "启动 CompressPro"
!define MUI_FINISHPAGE_SHOWREADME ""
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; ─── 语言 (只用英文避免编码问题) ───
!insertmacro MUI_LANGUAGE "English"

; ══════════════════════════════════════════════════════════
;  组件定义
; ══════════════════════════════════════════════════════════

; 主程序（必选）
Section "CompressPro Core" SEC_CORE
    SectionIn RO
    SetOutPath "$INSTDIR"

    ; 复制程序文件
    File "..\src\CompressPro.Gui\bin\Release\net8.0-windows\CompressPro.exe"
    File "..\src\CompressPro.Gui\bin\Release\net8.0-windows\*.dll"
    File "..\src\CompressPro.Gui\bin\Release\net8.0-windows\*.json"

    ; 写卸载信息
    WriteUninstaller "$INSTDIR\Uninstall.exe"
    WriteRegStr HKLM "${REG_ROOT}" "DisplayName" "CompressPro - Archive Utility"
    WriteRegStr HKLM "${REG_ROOT}" "DisplayVersion" "${PRODUCT_VERSION}"
    WriteRegStr HKLM "${REG_ROOT}" "Publisher" "${PRODUCT_PUBLISHER}"
    WriteRegStr HKLM "${REG_ROOT}" "UninstallString" "$INSTDIR\Uninstall.exe"
    WriteRegStr HKLM "${REG_ROOT}" "DisplayIcon" "$INSTDIR\CompressPro.exe"
    WriteRegDWORD HKLM "${REG_ROOT}" "NoModify" 1
    WriteRegDWORD HKLM "${REG_ROOT}" "NoRepair" 1
    WriteRegStr HKLM "${REG_ROOT}" "InstallLocation" "$INSTDIR"
    WriteRegStr HKLM "${REG_ROOT}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
    ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
    WriteRegDWORD HKLM "${REG_ROOT}" "EstimatedSize" "$0"

    ; 快捷方式
    CreateDirectory "$SMPROGRAMS\CompressPro"
    CreateShortCut "$SMPROGRAMS\CompressPro\CompressPro.lnk" "$INSTDIR\CompressPro.exe"
    CreateShortCut "$SMPROGRAMS\CompressPro\Uninstall CompressPro.lnk" "$INSTDIR\Uninstall.exe"
    CreateShortCut "$DESKTOP\CompressPro.lnk" "$INSTDIR\CompressPro.exe"

    ; 记录安装路径
    WriteRegStr HKLM "${REG_INSTALL}" "InstallDir" "$INSTDIR"
SectionEnd

; ─── 右键菜单 ───
Section "Context Menu (right-click)" SEC_CONTEXT
    ; 存卸载标记
    WriteRegDWORD HKLM "${REG_INSTALL}" "InstalledContext" 1

    ; "Open with CompressPro" - all files
    WriteRegStr HKCR "*\shell\CompressPro" "" "Open with CompressPro"
    WriteRegStr HKCR "*\shell\CompressPro" "Icon" "$INSTDIR\CompressPro.exe,0"
    WriteRegStr HKCR "*\shell\CompressPro\command" "" '"$INSTDIR\CompressPro.exe" "open" "%1"'

    ; "Extract to..." - archives
    WriteRegStr HKCR "CompressPro.7z\shell\extract" "" "Extract to..."
    WriteRegStr HKCR "CompressPro.7z\shell\extract" "Icon" "$INSTDIR\CompressPro.exe,0"
    WriteRegStr HKCR "CompressPro.7z\shell\extract\command" "" '"$INSTDIR\CompressPro.exe" "extract" "%1"'

    ; "Extract here" - archives
    WriteRegStr HKCR "CompressPro.7z\shell\extracthere" "" "Extract Here"
    WriteRegStr HKCR "CompressPro.7z\shell\extracthere" "Icon" "$INSTDIR\CompressPro.exe,0"
    WriteRegStr HKCR "CompressPro.7z\shell\extracthere\command" "" '"$INSTDIR\CompressPro.exe" "extracthere" "%1"'

    ; "Add to archive..." - any files/folders
    WriteRegStr HKCR "AllFilesystemObjects\shell\CompressProAdd" "" "Add to CompressPro archive..."
    WriteRegStr HKCR "AllFilesystemObjects\shell\CompressProAdd" "Icon" "$INSTDIR\CompressPro.exe,0"
    WriteRegStr HKCR "AllFilesystemObjects\shell\CompressProAdd\command" "" '"$INSTDIR\CompressPro.exe" "add" "%1"'
SectionEnd

; ─── 文件关联 ───
SectionGroup /e "File Associations" SEC_GROUP_ASSOC

    Section ".7z" SEC_7Z
        WriteRegDWORD HKLM "${REG_INSTALL}" "Assoc_7z" 1
        WriteRegStr HKCR ".7z" "" "CompressPro.7z"
        WriteRegStr HKCR "CompressPro.7z" "" "7-Zip Archive"
        WriteRegStr HKCR "CompressPro.7z\DefaultIcon" "" "$INSTDIR\CompressPro.exe,1"
        WriteRegStr HKCR "CompressPro.7z\shell\open\command" "" '"$INSTDIR\CompressPro.exe" "open" "%1"'
    SectionEnd

    Section ".zip" SEC_ZIP
        WriteRegDWORD HKLM "${REG_INSTALL}" "Assoc_Zip" 1
        WriteRegStr HKCR ".zip" "" "CompressPro.Zip"
        WriteRegStr HKCR "CompressPro.Zip" "" "ZIP Archive"
        WriteRegStr HKCR "CompressPro.Zip\DefaultIcon" "" "$INSTDIR\CompressPro.exe,2"
        WriteRegStr HKCR "CompressPro.Zip\shell\open\command" "" '"$INSTDIR\CompressPro.exe" "open" "%1"'
    SectionEnd

    Section ".rar" SEC_RAR
        WriteRegDWORD HKLM "${REG_INSTALL}" "Assoc_Rar" 1
        WriteRegStr HKCR ".rar" "" "CompressPro.Rar"
        WriteRegStr HKCR "CompressPro.Rar" "" "RAR Archive"
        WriteRegStr HKCR "CompressPro.Rar\DefaultIcon" "" "$INSTDIR\CompressPro.exe,3"
        WriteRegStr HKCR "CompressPro.Rar\shell\open\command" "" '"$INSTDIR\CompressPro.exe" "open" "%1"'
    SectionEnd

    Section ".tar / .tar.gz / .tar.bz2" SEC_TAR
        WriteRegDWORD HKLM "${REG_INSTALL}" "Assoc_Tar" 1
        WriteRegStr HKCR ".tar" "" "CompressPro.Tar"
        WriteRegStr HKCR "CompressPro.Tar\DefaultIcon" "" "$INSTDIR\CompressPro.exe,4"
        WriteRegStr HKCR "CompressPro.Tar\shell\open\command" "" '"$INSTDIR\CompressPro.exe" "open" "%1"'
        WriteRegStr HKCR ".gz" "" "CompressPro.Gz"
        WriteRegStr HKCR ".tgz" "" "CompressPro.Tgz"
        WriteRegStr HKCR ".bz2" "" "CompressPro.Bz2"
    SectionEnd

    Section ".iso / .cab / .wim" SEC_OTHER
        WriteRegDWORD HKLM "${REG_INSTALL}" "Assoc_Other" 1
        WriteRegStr HKCR ".iso" "" "CompressPro.Iso"
        WriteRegStr HKCR ".cab" "" "CompressPro.Cab"
        WriteRegStr HKCR ".wim" "" "CompressPro.Wim"
        WriteRegStr HKCR ".vhd" "" "CompressPro.Vhd"
    SectionEnd

SectionGroupEnd

; ─── 安装后刷新 ───
Section -PostInstall
    ; 通知 Explorer 刷新图标/关联
    System::Call 'shell32.dll::SHChangeNotify(l, l, i, i) v (0x08000000, 0, 0, 0)'
SectionEnd

; ══════════════════════════════════════════════════════════
;  卸载
; ══════════════════════════════════════════════════════════

Section "Uninstall"
    ; ── 删除程序文件 ──
    ReadRegStr $INSTDIR HKLM "${REG_INSTALL}" "InstallDir"
    Delete "$INSTDIR\CompressPro.exe"
    Delete "$INSTDIR\*.dll"
    Delete "$INSTDIR\*.json"
    RMDir /r "$INSTDIR"

    ; ── 删除右键菜单 ──
    ReadRegDWORD $0 HKLM "${REG_INSTALL}" "InstalledContext"
    IntCmp $0 1 done_context
        DeleteRegKey HKCR "*\shell\CompressPro"
        DeleteRegKey HKCR "CompressPro.7z\shell\extract"
        DeleteRegKey HKCR "CompressPro.7z\shell\extracthere"
        DeleteRegKey HKCR "AllFilesystemObjects\shell\CompressProAdd"
    done_context:

    ; ── 删除文件关联 (不查注册表，直接清所有可能项) ──
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

    ; ── 删除卸载信息 ──
    DeleteRegKey HKLM "${REG_ROOT}"
    DeleteRegKey HKLM "${REG_INSTALL}"

    ; ── 删除快捷方式 ──
    Delete "$SMPROGRAMS\CompressPro\CompressPro.lnk"
    Delete "$SMPROGRAMS\CompressPro\Uninstall CompressPro.lnk"
    RMDir "$SMPROGRAMS\CompressPro"
    Delete "$DESKTOP\CompressPro.lnk"

    ; ── 刷新 Explorer ──
    System::Call 'shell32.dll::SHChangeNotify(l, l, i, i) v (0x08000000, 0, 0, 0)'
SectionEnd
