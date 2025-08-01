call "%~dp0..\Installer\buildVariables.cmd" %*

REM @ECHO OFF

REM echo %*
REM IF "%~4" == "" ( set "openssl_version=3.4.0" ) ELSE ( set "openssl_version=%~4" )
REM IF "%~3" == "" ( set "qt6_version=6.3.1" ) ELSE ( set "qt6_version=%~3" )
REM IF "%~2" == "" ( set "qt_version=5.15.16" ) ELSE ( set "qt_version=%~2" )

IF "%openssl_version:~0,3%" == "1.1" ( set "sslMajorVersion=1_1" ) ELSE ( set "sslMajorVersion=3" )

IF %1 == x86 (
  set archPath=Win32
  call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars32.bat"
  set qtPath=%~dp0..\..\Qt\%qt_version%\msvc2022
  set instPath=%~dp0\SbiePlus_x86
)
IF %1 == x64 (
  set archPath=x64
  call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
REM  set qtPath=%~dp0..\..\Qt\%qt6_version%\msvc2022_64
  set qtPath=%~dp0..\..\Qt\%qt_version%\msvc2022_64
  set instPath=%~dp0\SbiePlus_x64
)
IF %1 == ARM64 (
  set archPath=ARM64
  call "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsamd64_arm64.bat"
  set qtPath=%~dp0..\..\Qt\%qt6_version%\msvc2022_arm64
  set instPath=%~dp0\SbiePlus_a64
  set "sslMajorVersion=1_1"
)

set redistPath=%VCToolsRedistDir%\%1\Microsoft.VC143.CRT
REM set redistPath="C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Redist\MSVC\%VCToolsVersion%\%1\Microsoft.VC143.CRT"

@echo on

set srcPath=%~dp0..\SandboxiePlus\Bin\%archPath%\Release
set sbiePath=%~dp0..\Sandboxie\Bin\%archPath%\SbieRelease

echo inst: %instPath%
echo arch: %archPath%
echo redistr: %redistPath%
echo source: %srcPath%
echo source: %sbiePath%

mkdir %instPath%

ECHO Copying VC Runtime files
copy "%redistPath%\*" %instPath%\


ECHO Copying Qt libraries

if "%qt_version:~0,1%" == "5" (
    echo Copying Qt5 libraries...
    IF NOT %archPath% == ARM64 (
        REM If not ARM64 (e.g., x86 or x64)
        echo Copying Qt5Core.dll
        copy %qtPath%\bin\Qt5Core.dll %instPath%\
        echo Copying Qt5Gui.dll
        copy %qtPath%\bin\Qt5Gui.dll %instPath%\
        echo Copying Qt5Network.dll
        copy %qtPath%\bin\Qt5Network.dll %instPath%\
        echo Copying Qt5Widgets.dll
        copy %qtPath%\bin\Qt5Widgets.dll %instPath%\
        echo Copying Qt5WinExtras.dll
        copy %qtPath%\bin\Qt5WinExtras.dll %instPath%\
        echo Copying Qt5Qml.dll
        copy %qtPath%\bin\Qt5Qml.dll %instPath%\
    ) ELSE (
        REM If ARM64, using Qt6
        echo Copying Qt6Core.dll
        copy %qtPath%\bin\Qt6Core.dll %instPath%\
        echo Copying Qt6Gui.dll
        copy %qtPath%\bin\Qt6Gui.dll %instPath%\
        echo Copying Qt6Network.dll
        copy %qtPath%\bin\Qt6Network.dll %instPath%\
        echo Copying Qt6Widgets.dll
        copy %qtPath%\bin\Qt6Widgets.dll %instPath%\
        echo Copying Qt6Qml.dll
        copy %qtPath%\bin\Qt6Qml.dll %instPath%\
    )
) else (
    REM If not Qt5, assuming Qt6
    echo Copying Qt6 libraries...
    echo Copying Qt6Core.dll
    copy %qtPath%\bin\Qt6Core.dll %instPath%\
    echo Copying Qt6Gui.dll
    copy %qtPath%\bin\Qt6Gui.dll %instPath%\
    echo Copying Qt6Network.dll
    copy %qtPath%\bin\Qt6Network.dll %instPath%\
    echo Copying Qt6Widgets.dll
    copy %qtPath%\bin\Qt6Widgets.dll %instPath%\
    echo Copying Qt6Qml.dll
    copy %qtPath%\bin\Qt6Qml.dll %instPath%\
)

echo Done copying libraries.

mkdir %instPath%\platforms
copy %qtPath%\plugins\platforms\qdirect2d.dll %instPath%\platforms\
copy %qtPath%\plugins\platforms\qminimal.dll %instPath%\platforms\
copy %qtPath%\plugins\platforms\qoffscreen.dll %instPath%\platforms\
copy %qtPath%\plugins\platforms\qwindows.dll %instPath%\platforms\

mkdir %instPath%\styles
copy %qtPath%\plugins\styles\qwindowsvistastyle.dll %instPath%\styles\
rem Qt 6.7+
copy %qtPath%\plugins\styles\qmodernwindowsstyle.dll %instPath%\styles\

IF %archPath% == ARM64 (
mkdir %instPath%\tls
copy %qtPath%\plugins\tls\qcertonlybackend.dll %instPath%\tls\
copy %qtPath%\plugins\tls\qopensslbackend.dll %instPath%\tls\
copy %qtPath%\plugins\tls\qschannelbackend.dll %instPath%\tls\
)

IF %archPath% == x64 (
    if "%qt_version:~0,1%" == "6" (
        mkdir %instPath%\tls
        copy %qtPath%\plugins\tls\qopensslbackend.dll %instPath%\tls\
    )
)

ECHO Copying OpenSSL libraries
IF %archPath% == Win32 (
  copy /y %~dp0OpenSSL\Win_x86\bin\libssl-%sslMajorVersion%.dll %instPath%\
  copy /y %~dp0OpenSSL\Win_x86\bin\libcrypto-%sslMajorVersion%.dll %instPath%\
)
IF NOT %archPath% == Win32 (
  copy /y %~dp0OpenSSL\Win_%archPath%\bin\libssl-%sslMajorVersion%-%archPath%.dll %instPath%\
  copy /y %~dp0OpenSSL\Win_%archPath%\bin\libcrypto-%sslMajorVersion%-%archPath%.dll %instPath%\
)


ECHO Copying 7zip library
copy /y %~dp07-Zip\7-Zip-%archPath%\7z.dll %instPath%\


ECHO Copying SandMan project and libraries
copy %srcPath%\MiscHelpers.dll %instPath%\
copy %srcPath%\MiscHelpers.pdb %instPath%\
copy %srcPath%\QSbieAPI.dll %instPath%\
copy %srcPath%\QSbieAPI.pdb %instPath%\
copy %srcPath%\QtSingleApp.dll %instPath%\
copy %srcPath%\QtSingleApp.pdb %instPath%\
copy %srcPath%\UGlobalHotkey.dll %instPath%\
copy %srcPath%\UGlobalHotkey.pdb %instPath%\
copy %srcPath%\SandMan.exe %instPath%\
copy %srcPath%\SandMan.pdb %instPath%\

ECHO Copying SandMan translations

mkdir %instPath%\translations\
rem copy /y %~dp0..\SandboxiePlus\SandMan\sandman_*.qm %instPath%\translations\
copy /y %~dp0..\SandboxiePlus\Build_SandMan_%archPath%\release\sandman_*.qm %instPath%\translations\
copy /y %~dp0\qttranslations\qm\qt_*.qm %instPath%\translations\
copy /y %~dp0\qttranslations\qm\qtbase_*.qm %instPath%\translations\
copy /y %~dp0\qttranslations\qm\qtmultimedia_*.qm %instPath%\translations\

IF NOT %archPath% == ARM64 (
REM IF %archPath% == Win32 (
copy /y %qtPath%\translations\qtscript_*.qm %instPath%\translations\
copy /y %qtPath%\translations\qtxmlpatterns_*.qm %instPath%\translations\
)

"C:\Program Files\7-Zip\7z.exe" a %instPath%\translations.7z %instPath%\translations\*
rmdir /S /Q %instPath%\translations\

"C:\Program Files\7-Zip\7z.exe" a %instPath%\troubleshooting.7z %~dp0..\SandboxiePlus\SandMan\Troubleshooting\*

ECHO Copying Sandboxie

copy /y %sbiePath%\SbieSvc.exe %instPath%\
copy /y %sbiePath%\SbieSvc.pdb %instPath%\
copy /y %sbiePath%\SbieDll.dll %instPath%\
copy /y %sbiePath%\SbieDll.pdb %instPath%\

copy /y %sbiePath%\SbieDrv.sys %instPath%\
copy /y %sbiePath%\SbieDrv.pdb %instPath%\

copy /y %sbiePath%\SbieCtrl.exe %instPath%\
copy /y %sbiePath%\SbieCtrl.pdb %instPath%\
copy /y %sbiePath%\Start.exe %instPath%\
copy /y %sbiePath%\Start.pdb %instPath%\
copy /y %sbiePath%\kmdutil.exe %instPath%\
copy /y %sbiePath%\kmdutil.pdb %instPath%\
copy /y %sbiePath%\SbieIni.exe %instPath%\
copy /y %sbiePath%\SbieIni.pdb %instPath%\
copy /y %sbiePath%\SbieMsg.dll %instPath%\
copy /y %sbiePath%\SboxHostDll.dll %instPath%\
copy /y %sbiePath%\SboxHostDll.pdb %instPath%\

copy /y %sbiePath%\SandboxieBITS.exe %instPath%\
copy /y %sbiePath%\SandboxieBITS.pdb %instPath%\
copy /y %sbiePath%\SandboxieCrypto.exe %instPath%\
copy /y %sbiePath%\SandboxieCrypto.pdb %instPath%\
copy /y %sbiePath%\SandboxieDcomLaunch.exe %instPath%\
copy /y %sbiePath%\SandboxieDcomLaunch.pdb %instPath%\
copy /y %sbiePath%\SandboxieRpcSs.exe %instPath%\
copy /y %sbiePath%\SandboxieRpcSs.pdb %instPath%\
copy /y %sbiePath%\SandboxieWUAU.exe %instPath%\
copy /y %sbiePath%\SandboxieWUAU.pdb %instPath%\

IF %archPath% == x64 (
  mkdir %instPath%\32\
  copy /y %~dp0..\Sandboxie\Bin\Win32\SbieRelease\SbieSvc.exe %instPath%\32\
  copy /y %~dp0..\Sandboxie\Bin\Win32\SbieRelease\SbieSvc.pdb %instPath%\32\
  copy /y %~dp0..\Sandboxie\Bin\Win32\SbieRelease\SbieDll.dll %instPath%\32\
  copy /y %~dp0..\Sandboxie\Bin\Win32\SbieRelease\SbieDll.pdb %instPath%\32\

  copy /y %~dp0..\SandboxiePlus\x64\Release\SbieShellExt.dll %instPath%\
  copy /y %~dp0..\SandboxiePlus\x64\Release\SbieShellPkg.msix %instPath%\
)
IF %archPath% == ARM64 (
  mkdir %instPath%\32\
  copy /y %~dp0..\Sandboxie\Bin\Win32\SbieRelease\SbieSvc.exe %instPath%\32\
  copy /y %~dp0..\Sandboxie\Bin\Win32\SbieRelease\SbieSvc.pdb %instPath%\32\
  copy /y %~dp0..\Sandboxie\Bin\Win32\SbieRelease\SbieDll.dll %instPath%\32\
  copy /y %~dp0..\Sandboxie\Bin\Win32\SbieRelease\SbieDll.pdb %instPath%\32\

  mkdir %instPath%\64\
  copy /y %~dp0..\Sandboxie\Bin\ARM64EC\SbieRelease\SbieDll.dll %instPath%\64\
  copy /y %~dp0..\Sandboxie\Bin\ARM64EC\SbieRelease\SbieDll.pdb %instPath%\64\

  copy /y %~dp0..\SandboxiePlus\ARM64\Release\SbieShellExt.dll %instPath%\
  copy /y %~dp0..\SandboxiePlus\ARM64\Release\SbieShellPkg.msix %instPath%\
)


copy /y %~dp0..\Sandboxie\install\Templates.ini %instPath%\

copy /y %~dp0..\Sandboxie\install\Manifest0.txt %instPath%\
copy /y %~dp0..\Sandboxie\install\Manifest1.txt %instPath%\
copy /y %~dp0..\Sandboxie\install\Manifest2.txt %instPath%\

copy /y %~dp0..\Sandboxie\install\SbieSettings.ini %instPath%\

ECHO Copying Sandboxie Tools

copy /y %~dp0..\SandboxieTools\%archPath%\Release\ImBox.exe %instPath%\
copy /y %~dp0..\SandboxieTools\%archPath%\Release\ImBox.pdb %instPath%\
copy /y %~dp0..\SandboxieTools\%archPath%\Release\UpdUtil.exe %instPath%\
copy /y %~dp0..\SandboxieTools\%archPath%\Release\UpdUtil.pdb %instPath%\



