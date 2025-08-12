@echo off
setlocal enabledelayedexpansion
title Hopmon Patching Tool

REM Path configuration
set TOOLS_DIR=tools
set PATCHES_EN=patches_en
set PATCHES_PL=patches_pl
set CHECKSUMS_EN=checksums_en
set CHECKSUMS_PL=checksums_pl
set HPATCHZ=%TOOLS_DIR%\hpatchz.exe


REM Check if Hopmon.exe exists
if not exist "Hopmon.exe" (
	echo [ERROR] Hopmon.exe not found in this directory.
	pause
	exit /b 1
)

REM Check if Hopmon.exe version is correct
echo [INFO] Checking if Hopmon.exe version is correct
for /f "tokens=1" %%A in ('type "%CHECKSUMS_EN%\Hopmon.exe.sha256"') do set EXPECTED_HASH=%%A
for /f "tokens=1" %%H in ('certutil -hashfile "Hopmon.exe" SHA256 ^| findstr /R /V "hash CertUtil"') do set ACTUAL_HASH=%%H

if /I "!EXPECTED_HASH!" neq "!ACTUAL_HASH!" (
    echo [ERROR] Hopmon.exe checksum doesn't match.
    echo Expected: !EXPECTED_HASH!
    echo Actual: !ACTUAL_HASH!
    pause
    exit /b 1
)
echo [INFO] Base file is valid
echo.

REM Pick language version
:choose_lang
echo ===========================
echo Pick your desired language:
echo ===========================
echo [1] English
echo [2] Polski
set /p LANG_CHOICE=Choice: 
if "%LANG_CHOICE%"=="1" set LANG=EN
if "%LANG_CHOICE%"=="2" set LANG=PL
if not defined LANG goto choose_lang

REM Pick patch set
:choose_patch
echo ============================
echo Pick your desired patch set:
echo ============================
if "%LANG%"=="EN" (
    echo [1] music - changes midi playback to mp3
    echo [2] resolution - increases resolution and bit depth
    echo [3] combined - all of above
) else (
    echo [1] baza - bazowa wersja polska bez ˆatek
    echo [2] muzyka - zmienia odtwarzanie z midi na mp3
    echo [3] rozdzielczo˜† - zwi©ksza rozdzielczo˜† i gˆ©bi© bitow¥
    echo [4] poˆ¥czone - wszystko powy¾sze
)
set /p PATCH_CHOICE=Choice: 

if "%LANG%"=="EN" (
    if "%PATCH_CHOICE%"=="1" set PATCH=music
    if "%PATCH_CHOICE%"=="2" set PATCH=resolution
    if "%PATCH_CHOICE%"=="3" set PATCH=combined
) else (
    if "%PATCH_CHOICE%"=="1" set PATCH=base
    if "%PATCH_CHOICE%"=="2" set PATCH=music
    if "%PATCH_CHOICE%"=="3" set PATCH=resolution
    if "%PATCH_CHOICE%"=="4" set PATCH=combined
)
if not defined PATCH goto choose_patch

REM Patching process
if "%LANG%"=="EN" (
    set DIFF_FILE=!PATCHES_EN!\hopmon_!PATCH!.patch
    set OUTPUT_FILE=Hopmon_!PATCH!_patch.exe
    echo [INFO] Applying specified patch...
    "!HPATCHZ!" Hopmon.exe "!DIFF_FILE!" "!OUTPUT_FILE!"
) else (
    if "%PATCH%"=="base" (
        set DIFF_FILE=!PATCHES_PL!\hopmon_pl_base.patch
        set OUTPUT_FILE=Hopmon_PL_base.exe
        echo [INFO] Zmienianie wersji j©zykowej...
        "!HPATCHZ!" Hopmon.exe "!DIFF_FILE!" "!OUTPUT_FILE!"
    ) else (
        REM First we need to patch en to pl
		echo [INFO] Zmienianie wersji j©zykowej...
        set TEMP_FILE=Hopmon_PL_base_tmp.exe
        "!HPATCHZ!" Hopmon.exe "!PATCHES_PL!\hopmon_pl_base.patch" "!TEMP_FILE!"
        REM Then we can apply patch to pl
		echo [INFO] Stosowanie wybranej ˆatki...
        set DIFF_FILE=!PATCHES_PL!\hopmon_pl_!PATCH!.patch
        set OUTPUT_FILE=Hopmon_PL_!PATCH!_patch.exe
        "!HPATCHZ!" "!TEMP_FILE!" "!DIFF_FILE!" "!OUTPUT_FILE!"
        del "!TEMP_FILE!"
    )
)

REM Checksum Check
echo [INFO] Verifying checksum...
if "%LANG%"=="EN" (
    set SUM_FILE=!CHECKSUMS_EN!\Hopmon_!PATCH!_patch.exe.sha256
) else (
    set SUM_FILE=!CHECKSUMS_PL!\Hopmon_PL_!PATCH!_patch.exe.sha256
)

if not exist "%SUM_FILE%" (
    echo [ERROR] Cannot find checksum for specified patch: !SUM_FILE!
    pause
    exit /b 1
)

for /f "tokens=1" %%A in ('type "%SUM_FILE%"') do set EXPECTED_HASH=%%A
for /f "tokens=1" %%H in ('certutil -hashfile "%OUTPUT_FILE%" SHA256 ^| findstr /R /V "hash CertUtil"') do set ACTUAL_HASH=%%H

if /I "!EXPECTED_HASH!" neq "!ACTUAL_HASH!" (
    echo [ERROR] "!OUTPUT_FILE!" checksum doesn't match.
    echo Expected: !EXPECTED_HASH!
    echo Actual: !ACTUAL_HASH!
    pause
    exit /b 1
)

echo [INFO]: %OUTPUT_FILE% file sucessfully generated!
pause
exit /b 0
