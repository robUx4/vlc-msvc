@REM adjust the SDK depending on the target
@set CALL_DIR=%cd%

@IF /I "%1" == "WindowsPhone"   goto setup_WindowsPhone
@IF /I "%1" == "Windows"        goto setup_Windows
@IF /I "%1" == "Metrox64"       goto setup_Metrox64
@IF /I "%1" == "Metrox86"       goto setup_Metrox86
@IF /I "%1" == "Universal86"    goto setup_Universal86
@IF /I "%1" == "Universal64"    goto setup_Universal64
@IF /I "%1" == "UniversalARM"   goto setup_UniversalARM
@IF /I "%1" == "UniversalARM64" goto setup_UniversalARM64
@IF /I "%1" == "Win32"          goto setup_Win32
@IF /I "%1" == "Win64"          goto setup_Win64
@echo Unknown target "%1"
@exit -1


:setup_WindowsPhone
@set SDK_VER=8.1
@set RUNTIME_VER=store
@set RUNTIME_VER17=store
@set CMAKE_SYSTEM_PROCESSOR=ARM
@rem set CMAKE_SYSTEM_NAME=WindowsPhone
@goto select_vs

:setup_Windows
@set SDK_VER=8.1
@set RUNTIME_VER=store
@set RUNTIME_VER17=store
@set CMAKE_SYSTEM_PROCESSOR=ARM
@rem set CMAKE_SYSTEM_NAME=WindowsStore
@goto select_vs

:setup_Metrox64
@set SDK_VER=8.1
@set RUNTIME_VER=store
@set RUNTIME_VER17=store
@set CMAKE_SYSTEM_PROCESSOR=amd64
@rem set CMAKE_SYSTEM_NAME=WindowsStore
@goto select_vs

:setup_Metrox86
@set SDK_VER=8.1
@set RUNTIME_VER=store
@set RUNTIME_VER17=store
@set CMAKE_SYSTEM_PROCESSOR=x86
@rem set CMAKE_SYSTEM_NAME=WindowsStore
@goto select_vs


:setup_Universal86
@set SDK_VER=10.0.16299.0
@set RUNTIME_VER=store
@set RUNTIME_VER17=uwp
@set CMAKE_SYSTEM_PROCESSOR=x86
@rem set CMAKE_SYSTEM_NAME=WindowsStore
@goto select_vs17

:setup_UniversalARM
@set SDK_VER=10.0.16299.0
@set RUNTIME_VER=store
@set RUNTIME_VER17=uwp
@set CMAKE_SYSTEM_PROCESSOR=ARM
@rem set CMAKE_SYSTEM_NAME=WindowsStore
@goto select_vs17

:setup_UniversalARM64
@set SDK_VER=10.0.16299.0
@set RUNTIME_VER=store
@set RUNTIME_VER17=uwp
@set CMAKE_SYSTEM_PROCESSOR=ARM64
@rem set CMAKE_SYSTEM_NAME=WindowsStore
@goto select_vs17

:setup_Universal64
@set SDK_VER=10.0.16299.0
@set RUNTIME_VER=store
@set RUNTIME_VER17=uwp
@set CMAKE_SYSTEM_PROCESSOR=amd64
@rem set CMAKE_SYSTEM_NAME=WindowsStore
@goto select_vs17

:setup_Win32
@set SDK_VER=10.0.14393.0
@set CMAKE_SYSTEM_PROCESSOR=x86
@goto select_vs15

:setup_Win64
@set SDK_VER=10.0.14393.0
@set CMAKE_SYSTEM_PROCESSOR=amd64
@goto select_vs15


:select_vs
@IF EXIST "%VS120COMNTOOLS%vsvars32.bat" goto vs2013
@echo VS 2013 not found in VS120COMNTOOLS=%VS120COMNTOOLS%
@echo you can download it VS 2013 Community from https://visualstudio.microsoft.com/vs/older-downloads/
@exit -1

:select_vs15
@IF EXIST "%VS140COMNTOOLS%vsvars32.bat" goto vs2015
@echo VS 2015 not found in VS140COMNTOOLS=%VS140COMNTOOLS%
@goto select_vs

:select_vs17
@IF EXIST "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" goto vs2017
@echo VS 2017 not found using "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
@goto select_vs15


:vs2017
@rem TODO set VSVARS="%VS140COMNTOOLS%vcvarsqueryregistry.bat"
@echo Using VS 2017
@FOR /F "tokens=1 delims=" %%A in ('"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -property installationPath') do SET VS150COMNTOOLS=%%A
@set VSVARS="%VS150COMNTOOLS%\VC\Auxiliary\Build\vcvarsall.bat"
@set VS_RUNTIME=dynamic

@IF "%CMAKE_SYSTEM_PROCESSOR%"=="ARM"   set VS_ARCH_TARGET=x86_arm
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="x86"   set VS_ARCH_TARGET=x86
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="amd64" set VS_ARCH_TARGET=x86_amd64
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="ARM64" set VS_ARCH_TARGET=x86_arm64

@echo call %VSVARS% %VS_ARCH_TARGET% %RUNTIME_VER17% %SDK_VER%
call %VSVARS% %VS_ARCH_TARGET% %RUNTIME_VER17% %SDK_VER%
@goto setupenv

:vs2015
@rem TODO set VSVARS="%VS140COMNTOOLS%vcvarsqueryregistry.bat"
@echo Using VS 2015
@set VSVARS="%VS140COMNTOOLS%vsvars32.bat"
@set VCINSTALLDIR=%VS140COMNTOOLS%..\..\VC\
@set SDK_VARIANT=%RUNTIME_VER% %SDK_VER%
@set VS_RUNTIME=dynamic

@IF "%CMAKE_SYSTEM_PROCESSOR%"=="ARM"   set VS_ARCH_TARGET=amd64_arm
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="x86"   set VS_ARCH_TARGET=amd64_x86
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="amd64" set VS_ARCH_TARGET=amd64

@echo call %VSVARS% %SDK_VARIANT%
@call %VSVARS% %SDK_VARIANT%
@echo call "%VCINSTALLDIR%vcvarsall.bat" %VS_ARCH_TARGET% %RUNTIME_VER% %SDK_VER%
call "%VCINSTALLDIR%vcvarsall.bat" %VS_ARCH_TARGET% %RUNTIME_VER% %SDK_VER%
@goto setupenv

:vs2013
@echo Using VS 2013
@set VSVARS="%VS120COMNTOOLS%vsvars32.bat"
@set VCINSTALLDIR=%VS120COMNTOOLS%..\..\VC\
@set SDK_VARIANT=%RUNTIME_VER% %SDK_VER%
@set VS_RUNTIME=dynamic

@IF "%CMAKE_SYSTEM_PROCESSOR%"=="ARM"   set VS_ARCH_TARGET=amd64_arm
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="x86"   set VS_ARCH_TARGET=amd64_x86
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="amd64" set VS_ARCH_TARGET=amd64

@set VS_IS_2013=VS_IS_2013
@IF "%CMAKE_VS_PLATFORM_TOOLSET%"=="" set CMAKE_VS_PLATFORM_TOOLSET=vs120
@echo call %VSVARS% %SDK_VARIANT%
@call %VSVARS% %SDK_VARIANT%

@echo call "%VCINSTALLDIR%vcvarsall.bat" %VS_ARCH_TARGET%
call "%VCINSTALLDIR%vcvarsall.bat" %VS_ARCH_TARGET%
@goto setupenv


:setupenv
@IF /I "%1" == "WindowsPhone" goto setupenv_WindowsPhone81
@IF /I "%1" == "Windows"      goto setupenv_Windows
@IF /I "%1" == "Metrox64"     goto setupenv_Metrox64
@IF /I "%1" == "Metrox86"     goto setupenv_Metrox86
@goto call_main


:setupenv_WindowsPhone81
@call :GetWindowsPhoneKitDir81
@set LIB=%VCINSTALLDIR%lib\store\arm;%WindowsPhoneKitDir%lib\arm;%LIB%
@set LIBPATH=%VCINSTALLDIR%lib\store\arm;%WindowsPhoneKitDir%lib\arm;%LIB%
@call :setup_msbuild  HKLM > nul 2>&1
@goto call_main

:setupenv_Windows
@set LIB=%VCINSTALLDIR%lib\store\arm;%LIB%
@set LIBPATH=%VCINSTALLDIR%lib\store\arm;%LIB%
@call :setup_msbuild  HKLM > nul 2>&1
@goto call_main

:setupenv_Metrox64
@set LIB=%VCINSTALLDIR%lib\store\amd64;%LIB%
@set LIBPATH=%VCINSTALLDIR%lib\store\amd64;%LIB%
@call :setup_msbuild  HKLM > nul 2>&1
@goto call_main

:setupenv_Metrox86
@set LIB=%VCINSTALLDIR%lib\store;%LIB%
@set LIBPATH=%VCINSTALLDIR%lib\store;%LIB%
@call :setup_msbuild  HKLM > nul 2>&1
@goto call_main


:call_main
@cd %CALL_DIR%
@REM ~ echo cd %CALL_DIR%
@REM ~ echo BUILD_SHELL=%BUILD_SHELL%
@REM ~ echo wsl.exe scripts/main.sh %*
wsl.exe scripts/main.sh %*


@REM -----------------------------------------------------------------------
:GetWindowsPhoneKitDir81
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

:setup_msbuild
@for /F "tokens=1,2*" %%i in ('reg query "%1\SOFTWARE\WOW6432Node\Microsoft\MSBuild\12.0" /v "MSBuildOverrideTasksPath"') DO (
	@if "%%i"=="MSBuildOverrideTasksPath" (
		@set "PATH=%%k;%PATH%"
	)
)
@for /F "tokens=1,2*" %%i in ('reg query "%1\SOFTWARE\WOW6432Node\Microsoft\MSBuild\14.0" /v "MSBuildOverrideTasksPath"') DO (
	@if "%%i"=="MSBuildOverrideTasksPath" (
		@set "PATH=%%k;%PATH%"
	)
)
@exit /B 0

