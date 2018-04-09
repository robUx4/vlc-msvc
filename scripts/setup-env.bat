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
@set WIN32_WINNT=0x603
@set WINAPI_FAMILY=WINAPI_FAMILY_PHONE_APP
@rem set CMAKE_SYSTEM_NAME=WindowsPhone
@goto select_vs

:setup_Windows
@set SDK_VER=8.1
@set RUNTIME_VER=store
@set RUNTIME_VER17=store
@set CMAKE_SYSTEM_PROCESSOR=ARM
@rem set CMAKE_SYSTEM_NAME=WindowsStore
@set WIN32_WINNT=0x603
@set WINAPI_FAMILY=WINAPI_FAMILY_PC_APP
@goto select_vs

:setup_Metrox64
@set SDK_VER=8.1
@set RUNTIME_VER=store
@set RUNTIME_VER17=store
@set CMAKE_SYSTEM_PROCESSOR=amd64
@rem set CMAKE_SYSTEM_NAME=WindowsStore
@set WIN32_WINNT=0x603
@set WINAPI_FAMILY=WINAPI_FAMILY_PC_APP
@goto select_vs

:setup_Metrox86
@set SDK_VER=8.1
@set RUNTIME_VER=store
@set RUNTIME_VER17=store
@set CMAKE_SYSTEM_PROCESSOR=x86
@rem set CMAKE_SYSTEM_NAME=WindowsStore
@set WIN32_WINNT=0x603
@set WINAPI_FAMILY=WINAPI_FAMILY_PC_APP
@goto select_vs


:setup_Universal86
@set SDK_VER=10.0.16299.0
@rem set SDK_VER=10.0.14366.0
@set RUNTIME_VER=store
@set RUNTIME_VER17=uwp
@set CMAKE_SYSTEM_PROCESSOR=x86
@rem set CMAKE_SYSTEM_NAME=WindowsStore
@set WIN32_WINNT=0x0A00
@set WINAPI_FAMILY=WINAPI_FAMILY_PC_APP
@goto select_vs15

:setup_UniversalARM
@set SDK_VER=10.0.16299.0
@rem set SDK_VER=10.0.14366.0
@set RUNTIME_VER=store
@set RUNTIME_VER17=uwp
@set CMAKE_SYSTEM_PROCESSOR=ARM
@rem set CMAKE_SYSTEM_NAME=WindowsStore
@set WIN32_WINNT=0x0A00
@set WINAPI_FAMILY=WINAPI_FAMILY_PC_APP
@goto select_vs15

:setup_UniversalARM64
@set SDK_VER=10.0.16299.0
@rem set SDK_VER=10.0.14366.0
@set RUNTIME_VER=store
@set RUNTIME_VER17=uwp
@set CMAKE_SYSTEM_PROCESSOR=ARM64
@rem set CMAKE_SYSTEM_NAME=WindowsStore
@set WIN32_WINNT=0x0A00
@set WINAPI_FAMILY=WINAPI_FAMILY_PC_APP
@goto select_vs17

:setup_Universal64
@set SDK_VER=10.0.16299.0
@rem set SDK_VER=10.0.14366.0
@set RUNTIME_VER=store
@set RUNTIME_VER17=uwp
@set CMAKE_SYSTEM_PROCESSOR=amd64
@rem set CMAKE_SYSTEM_NAME=WindowsStore
@set WIN32_WINNT=0x0A00
@set WINAPI_FAMILY=WINAPI_FAMILY_PC_APP
@goto select_vs15

:setup_Win32
@set SDK_VER=10.0.10586.0
@rem set SDK_VER=10.0.14366.0
@set CMAKE_SYSTEM_PROCESSOR=x86
@set WIN32_WINNT=0x0A00
@set WINAPI_FAMILY=WINAPI_FAMILY_DESKTOP_APP
@goto select_vs15

:setup_Win64
@set SDK_VER=10.0.10586.0
@rem set SDK_VER=10.0.14366.0
@set CMAKE_SYSTEM_PROCESSOR=amd64
@set WIN32_WINNT=0x0A00
@set WINAPI_FAMILY=WINAPI_FAMILY_DESKTOP_APP
@goto select_vs15


:select_vs
@IF EXIST "%VS120COMNTOOLS%vsvars32.bat" goto vs2013
@echo VS 2013 not found
@exit -1

:select_vs15
@IF EXIST "%VS140COMNTOOLS%vsvars32.bat" goto vs2015
@echo VS 2015 not found
@goto select_vs

:select_vs17
@IF EXIST "%VS2017INSTALLDIR%\VC\Auxiliary\Build\vcvars64.bat" goto vs2017
@echo VS 2017 not found
@goto select_vs15


:vs2017
@rem TODO set VSVARS="%VS140COMNTOOLS%vcvarsqueryregistry.bat"
@set VSVARS="%VS2017INSTALLDIR%\VC\Auxiliary\Build\vcvars64.bat"
@set VCINSTALLDIR=%VS140COMNTOOLS%..\..\VC\
@set SDK_VARIANT=%RUNTIME_VER% %SDK_VER%
@set VS_RUNTIME=dynamic

@IF "%CMAKE_SYSTEM_PROCESSOR%"=="ARM"   set VS_ARCH_TARGET=amd64_arm
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="x86"   set VS_ARCH_TARGET=amd64_x86
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="amd64" set VS_ARCH_TARGET=amd64
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="ARM64" set VS_ARCH_TARGET=amd64_arm64

@echo call %VSVARS% %VS_ARCH_TARGET% %RUNTIME_VER17% %SDK_VER% -vcvars_ver=14.11.25503
call %VSVARS% %VS_ARCH_TARGET% %RUNTIME_VER17% %SDK_VER% -vcvars_ver=14.11.25503
@goto setupenv

:vs2015
@rem TODO set VSVARS="%VS140COMNTOOLS%vcvarsqueryregistry.bat"
@set VSVARS="%VS140COMNTOOLS%vsvars32.bat"
@set VCINSTALLDIR=%VS140COMNTOOLS%..\..\VC\
@set SDK_VARIANT=%RUNTIME_VER% %SDK_VER%
@set VS_RUNTIME=dynamic
@set VS_TARGET_ARM=amd64_arm
@set VS_TARGET_x86=amd64_x86
@set VS_TARGET_AMD64=amd64
@echo call %VSVARS% %SDK_VARIANT%
@call %VSVARS% %SDK_VARIANT%
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="ARM" @echo call "%VCINSTALLDIR%vcvarsall.bat" %VS_TARGET_ARM% %RUNTIME_VER% %SDK_VER%
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="ARM" call "%VCINSTALLDIR%vcvarsall.bat" %VS_TARGET_ARM% %RUNTIME_VER% %SDK_VER%

@IF "%CMAKE_SYSTEM_PROCESSOR%"=="x86" @echo call "%VCINSTALLDIR%vcvarsall.bat" %VS_TARGET_x86% %RUNTIME_VER% %SDK_VER%
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="x86" call "%VCINSTALLDIR%vcvarsall.bat" %VS_TARGET_x86% %RUNTIME_VER% %SDK_VER%

@IF "%CMAKE_SYSTEM_PROCESSOR%"=="amd64" @echo call "%VCINSTALLDIR%vcvarsall.bat" %VS_TARGET_AMD64% %RUNTIME_VER% %SDK_VER%
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="amd64" call "%VCINSTALLDIR%vcvarsall.bat" %VS_TARGET_AMD64% %RUNTIME_VER% %SDK_VER%
@goto setupenv

:vs2013
@set VSVARS="%VS120COMNTOOLS%vsvars32.bat"
@set VCINSTALLDIR=%VS120COMNTOOLS%..\..\VC\
@set SDK_VARIANT=%RUNTIME_VER% %SDK_VER%
@set VS_RUNTIME=dynamic
@set VS_TARGET_ARM=x86_arm
@set VS_TARGET_x86=x86
@set VS_IS_2013=VS_IS_2013
@IF "%CMAKE_VS_PLATFORM_TOOLSET%"=="" set CMAKE_VS_PLATFORM_TOOLSET=vs120
@echo call %VSVARS% %SDK_VARIANT%
@call %VSVARS% %SDK_VARIANT%
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="ARM" @echo call "%VCINSTALLDIR%vcvarsall.bat" %VS_TARGET_ARM%
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="ARM" call "%VCINSTALLDIR%vcvarsall.bat" %VS_TARGET_ARM%

@IF "%CMAKE_SYSTEM_PROCESSOR%"=="x86" @echo call "%VCINSTALLDIR%vcvarsall.bat" %VS_TARGET_x86%
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="x86" call "%VCINSTALLDIR%vcvarsall.bat" %VS_TARGET_x86%

@IF "%CMAKE_SYSTEM_PROCESSOR%"=="amd64" @echo call "%VCINSTALLDIR%vcvarsall.bat" %VS_TARGET_AMD64%
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="amd64" call "%VCINSTALLDIR%vcvarsall.bat" %VS_TARGET_AMD64%
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
%WD%%MSYSCON% --hold always /usr/bin/bash scripts/main.sh %*


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

