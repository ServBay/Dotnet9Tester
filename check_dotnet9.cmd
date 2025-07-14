@echo off

:: ============================================================================
:: SCRIPT SETUP
:: ============================================================================

:: Switch the command prompt's active code page to UTF-8.
:: This ensures all redirected output from echo, reg, wmic, etc., is in UTF-8,
:: matching the .NET application's output and readable by all modern editors.
chcp 65001 > nul

:: Use delayed expansion for safely handling variables inside loops/blocks.
setlocal enabledelayedexpansion

:: Create a unique name for a temporary file to capture command output.
set "TEMP_OUTPUT_FILE=%TEMP%\dotnet_diag_temp_%RANDOM%.txt"

:: Create a unique name for the final log file.
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /format:list') do set "datetime=%%I"
set "TIMESTAMP=!datetime:~0,8!-!datetime:~8,6!"
set "LOG_FILE=dotnet9_check_log_!TIMESTAMP!_!RANDOM!.txt"


:: ============================================================================
:: MAIN SCRIPT LOGIC - REBUILT FOR MAXIMUM ROBUSTNESS
:: ============================================================================

echo =================================================================
echo       ServBay .NET 9 Full Diagnostic Tool
echo =================================================================
echo.
echo This tool will perform a comprehensive check of your .NET 9 installation.
echo A detailed log will be saved to the file: !LOG_FILE!
echo.
pause
cls

:: --- Section 1: System Information ---
echo ===== 1. System Information =====
echo ===== 1. System Information ===== >> "!LOG_FILE!"
wmic os get Caption, OSArchitecture /format:list > "!TEMP_OUTPUT_FILE!" 2>&1
type "!TEMP_OUTPUT_FILE!" >> "!LOG_FILE!"
echo System info captured in log.
echo. >> "!LOG_FILE!"
echo.

:: --- Section 2: .NET Environment Info ---
echo ===== 2. .NET Environment Info (dotnet --info) =====
echo ===== 2. .NET Environment Info (dotnet --info) ===== >> "!LOG_FILE!"
dotnet --info > "!TEMP_OUTPUT_FILE!" 2>&1
type "!TEMP_OUTPUT_FILE!" >> "!LOG_FILE!"
echo `dotnet --info` command executed.
echo. >> "!LOG_FILE!"
echo.

:: --- Section 3: Critical Environment Variables ---
echo ===== 3. Critical Environment Variables =====
echo ===== 3. Critical Environment Variables ===== >> "!LOG_FILE!"
echo Checking for variables that can alter .NET's behavior...
(
    echo --- Environment Variables ---
    set DOTNET_ROOT
    set DOTNET_ROLL_FORWARD
    set DOTNET_MULTILEVEL_LOOKUP
    echo.
    echo --- PATH ---
    set PATH
) > "!TEMP_OUTPUT_FILE!" 2>&1
type "!TEMP_OUTPUT_FILE!" >> "!LOG_FILE!"
echo Environment variables captured in log.
echo. >> "!LOG_FILE!"
echo.

:: --- Section 4: Windows Registry Keys ---
echo ===== 4. Windows Registry Keys for .NET Runtimes (x64) =====
echo ===== 4. Windows Registry Keys for .NET Runtimes (x64) ===== >> "!LOG_FILE!"
echo Checking if runtimes are properly registered...
echo --- Base Runtime --- >> "!LOG_FILE!"
reg query "HKLM\SOFTWARE\dotnet\Setup\InstalledVersions\x64\sharedhost" > "!TEMP_OUTPUT_FILE!" 2>&1
type "!TEMP_OUTPUT_FILE!" >> "!LOG_FILE!"
echo. >> "!LOG_FILE!"
reg query "HKLM\SOFTWARE\WOW6432Node\dotnet\Setup\InstalledVersions\x64\hostfxr" > "!TEMP_OUTPUT_FILE!" 2>&1
type "!TEMP_OUTPUT_FILE!" >> "!LOG_FILE!"
echo. >> "!LOG_FILE!"
reg query "HKLM\SOFTWARE\WOW6432Node\dotnet\Setup\InstalledVersions\x64\sdk" > "!TEMP_OUTPUT_FILE!" 2>&1
type "!TEMP_OUTPUT_FILE!" >> "!LOG_FILE!"
echo. >> "!LOG_FILE!"
echo --- Desktop Runtime (Most Important) --- >> "!LOG_FILE!"
reg query "HKLM\SOFTWARE\WOW6432Node\dotnet\Setup\InstalledVersions\x64\sharedfx\Microsoft.AspNetCore.App" /s > "!TEMP_OUTPUT_FILE!" 2>&1
type "!TEMP_OUTPUT_FILE!" >> "!LOG_FILE!"
echo. >> "!LOG_FILE!"
reg query "HKLM\SOFTWARE\WOW6432Node\dotnet\Setup\InstalledVersions\x64\sharedfx\Microsoft.NETCore.App" /s > "!TEMP_OUTPUT_FILE!" 2>&1
type "!TEMP_OUTPUT_FILE!" >> "!LOG_FILE!"
echo. >> "!LOG_FILE!"
reg query "HKLM\SOFTWARE\WOW6432Node\dotnet\Setup\InstalledVersions\x64\sharedfx\Microsoft.WindowsDesktop.App" /s > "!TEMP_OUTPUT_FILE!" 2>&1
type "!TEMP_OUTPUT_FILE!" >> "!LOG_FILE!"
echo. >> "!LOG_FILE!"
echo Registry check complete.
echo.

:: --- Section 5: Test A: CLI Runtime ---
echo ===== 5. Test A: Standard .NET 9 CLI Runtime =====
echo ===== 5. Test A: Standard .NET 9 CLI Runtime ===== >> "!LOG_FILE!"
if not exist "cli\Dotnet9CliTester.exe" (
    echo ERROR: cli\Dotnet9CliTester.exe not found!
    echo ERROR: cli\Dotnet9CliTester.exe not found! >> "!LOG_FILE!"
) else (
    echo Running CLI test...
    call cli\Dotnet9CliTester.exe > "!TEMP_OUTPUT_FILE!" 2>&1
    set "EXIT_CODE=!ERRORLEVEL!"
    type "!TEMP_OUTPUT_FILE!" >> "!LOG_FILE!"
    if !EXIT_CODE! == 0 (
        echo RESULT: SUCCESS. The base .NET 9 runtime is OK.
    ) else (
        echo RESULT: FAILURE. The base .NET 9 runtime is missing or broken. (Exit Code: !EXIT_CODE!)
    )
)
echo. >> "!LOG_FILE!"
echo.

:: --- Section 6: Test B: Desktop Runtime ---
echo ===== 6. Test B: .NET 9 DESKTOP Runtime (CRITICAL TEST) =====
echo ===== 6. Test B: .NET 9 DESKTOP Runtime (CRITICAL TEST) ===== >> "!LOG_FILE!"
if not exist "desktop\Dotnet9DesktopTester.exe" (
    echo ERROR: desktop\Dotnet9DesktopTester.exe not found!
    echo ERROR: desktop\Dotnet9DesktopTester.exe not found! >> "!LOG_FILE!"
) else (
    echo Running Desktop test...
    call desktop\Dotnet9DesktopTester.exe > "!TEMP_OUTPUT_FILE!" 2>&1
    set "EXIT_CODE=!ERRORLEVEL!"
    type "!TEMP_OUTPUT_FILE!" >> "!LOG_FILE!"
    if !EXIT_CODE! == 0 (
        echo RESULT: SUCCESS. The .NET 9 Desktop Runtime is installed correctly.
    ) else (
        echo RESULT: FAILURE! The required .NET 9 Desktop Runtime is missing or broken. (Exit Code: !EXIT_CODE!)
    )
)
echo. >> "!LOG_FILE!"
echo.

:: --- Section 7: Test C: Roll-Forward Policy ---
echo ===== 7. Test C: Desktop Runtime with Roll-Forward Policy =====
echo ===== 7. Test C: Desktop Runtime with Roll-Forward Policy ===== >> "!LOG_FILE!"
echo This test checks if a newer installed version can be used automatically.
set "DOTNET_ROLL_FORWARD=LatestMajor"
echo Temporarily set DOTNET_ROLL_FORWARD to '!DOTNET_ROLL_FORWARD!'.
call desktop\Dotnet9DesktopTester.exe > "!TEMP_OUTPUT_FILE!" 2>&1
set "EXIT_CODE=!ERRORLEVEL!"
type "!TEMP_OUTPUT_FILE!" >> "!LOG_FILE!"
if !EXIT_CODE! == 0 (
    echo RESULT: SUCCESS with roll-forward.
) else (
    echo RESULT: FAILURE even with roll-forward. (Exit Code: !EXIT_CODE!)
)
echo. >> "!LOG_FILE!"
set "DOTNET_ROLL_FORWARD="
echo.

echo =================================================================
echo                      Diagnosis Complete
echo =================================================================
echo.
echo Please find the log file '!LOG_FILE!' in this directory and
echo send it to the ServBay support team for analysis.
echo.

:: --- Cleanup ---
if exist "!TEMP_OUTPUT_FILE!" del "!TEMP_OUTPUT_FILE!"
pause
endlocal
exit /b 0