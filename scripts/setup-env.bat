@IF EXIST "%VS140COMNTOOLS%vsvars32.bat" goto vs2015
@IF EXIST "%VS120COMNTOOLS%vsvars32.bat" goto vs2013
@echo VS 2015 or VS 2013 not found
@exit -1

:vs2015
@set VSVARS="%VS140COMNTOOLS%vsvars32.bat"
@set STORE_VARIANT=store 8.1
@set CMAKE_VS=Visual Studio 14 2015
@set VS_TARGET_ARM=amd64_arm
@set VS_TARGET_X86=amd64_x86
@set VS_TOOLSET=vs140
@goto setupenv

:vs2013
@set VSVARS="%VS120COMNTOOLS%vsvars32.bat"
@set STORE_VARIANT=
@set CMAKE_VS=Visual Studio 12 2013
@set VS_TARGET_ARM=x86_arm
@set VS_TARGET_X86=x86
@set VS_TOOLSET=vs120
@goto setupenv

:setupenv
call %VSVARS% %STORE_VARIANT%
@IF /I "%1" == "WindowsPhone" goto setup_WindowsPhone
@IF /I "%1" == "Windows"      goto setup_Windows
@IF /I "%1" == "Metrox86"     goto setup_Metrox86


@REM -----------------------------------------------------------------------
:GetWindowsPhoneKitDir
@set WindowsPhoneKitDir=
@call :GetWindowsPhoneKitDirHelper32 HKLM > nul 2>&1
@if errorlevel 1 call :GetWindowsPhoneKitDirHelper32 HKCU > nul 2>&1
@if errorlevel 1 call :GetWindowsPhoneKitDirHelper64 HKLM > nul 2>&1
@if errorlevel 1 call :GetWindowsPhoneKitDirHelper64 HKCU > nul 2>&1
@exit /B 0

:GetWindowsPhoneKitDirHelper32
@for /F "tokens=1,2*" %%i in ('reg query "%1\SOFTWARE\Microsoft\Microsoft SDKs\WindowsPhoneApp\v8.1" /v "InstallationFolder"') DO (
	@if "%%i"=="InstallationFolder" (
		@SET WindowsPhoneKitDir=%%k
	)
)
@if "%WindowsPhoneKitDir%"=="" exit /B 1
@exit /B 0

:GetWindowsPhoneKitDirHelper64
@for /F "tokens=1,2*" %%i in ('reg query "%1\SOFTWARE\Wow6432Node\Microsoft\Microsoft SDKs\WindowsPhoneApp\v8.1" /v "InstallationFolder"') DO (
	@if "%%i"=="InstallationFolder" (
		@SET WindowsPhoneKitDir=%%k
	)
)
@if "%WindowsPhoneKitDir%"=="" exit /B 1
@exit /B 0

:setup_WindowsPhone
call "%VSINSTALLDIR%VC\vcvarsall.bat" %VS_TARGET_ARM%
@rem we may use amd64_arm with VS15 for better speed ?
@call :GetWindowsPhoneKitDir
@set LIB=%VCINSTALLDIR%lib\store\arm;%WindowsPhoneKitDir%lib\arm;%LIB%
@set LIBPATH=%VCINSTALLDIR%lib\store\arm;%WindowsPhoneKitDir%lib\arm;%LIB%
@set CMAKE_TARGET=-G "%CMAKE_VS% ARM" -DCMAKE_SYSTEM_NAME=WindowsPhone -DCMAKE_SYSTEM_VERSION=8.1 -DCMAKE_VS_PLATFORM_TOOLSET=%VS_TOOLSET%_wp81
@rem bogus VS 2015 RC   IF NOT EXIST "%VCINSTALLDIR%vcvarsphoneall.bat" goto bad_vcvarsphoneall
@rem bogus VS 2015 RC   call "%VCINSTALLDIR%vcvarsphoneall.bat" x86_arm
@goto run_bash

:setup_Windows
call "%VSINSTALLDIR%VC\vcvarsall.bat" %VS_TARGET_ARM%
@rem we may use amd64_arm with VS15 for better speed ?
@set LIB=%VCINSTALLDIR%lib\store\arm;%LIB%
@set LIBPATH=%VCINSTALLDIR%lib\store\arm;%LIB%
@set CMAKE_TARGET=-G "%CMAKE_VS% ARM" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=8.1 -DCMAKE_VS_PLATFORM_TOOLSET=%VS_TOOLSET%
@rem bogus VS 2015 RC   IF NOT EXIST "%VCINSTALLDIR%vcvarsphoneall.bat" goto bad_vcvarsphoneall
@rem bogus VS 2015 RC   call "%VCINSTALLDIR%vcvarsphoneall.bat" x86_arm
@goto run_bash

:setup_Metrox86
call "%VSINSTALLDIR%VC\vcvarsall.bat" %VS_TARGET_X86%
@rem we may use amd64_x86 with VS15 for better speed ?
@set LIB=%VCINSTALLDIR%lib\store;%LIB%
@set LIBPATH=%VCINSTALLDIR%lib\store;%LIB%
@set CMAKE_TARGET=-G "%CMAKE_VS%" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=8.1 -DCMAKE_VS_PLATFORM_TOOLSET=%VS_TOOLSET%
@rem bogus VS 2015 RC   IF NOT EXIST "%VCINSTALLDIR%vcvarsphoneall.bat" goto bad_vcvarsphoneall
@rem bogus VS 2015 RC   call "%VCINSTALLDIR%vcvarsphoneall.bat" x86
@goto run_bash


:run_bash
%WD%%MSYSCON% --hold always /usr/bin/bash scripts/main.sh %*
@goto :eof

:bad_vcvarsphoneall
@echo "%VCINSTALLDIR%bin\vcvarsphoneall.bat" needs to be moved into "%VCINSTALLDIR%vcvarsphoneall.bat"
@IF NOT EXIST "%VS140COMNTOOLS%vsvars32.bat" goto :eof
@echo "%VCINSTALLDIR%bin\x86_arm\vcvarsphonex86_arm.bat" needs to call "%VS140COMNTOOLS%VCVarsPhoneQueryRegistry.bat" not "%~dp0VCVarsPhoneQueryRegistry.bat"
@echo "%VS140COMNTOOLS%VCVarsPhoneQueryRegistry.bat" needs to look for WindowsPhoneApp\v8.1 SDKs, not WindowsPhone\v8.0 ones
@goto :eof
