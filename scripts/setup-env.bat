@REM adjust the SDK depending on the target
@IF /I "%1" == "WindowsPhone" goto setup_WindowsPhone
@IF /I "%1" == "Windows"      goto setup_Windows
@IF /I "%1" == "Metrox86"     goto setup_Metrox86
@IF /I "%1" == "Universal86"  goto setup_Universal86
@IF /I "%1" == "Universal64"  goto setup_Universal64
@IF /I "%1" == "UniversalARM"  goto setup_UniversalARM
@echo Unknown target "%1"
@exit -1


:setup_WindowsPhone
@set SDK_VER=8.1
@set CMAKE_SYSTEM_PROCESSOR=ARM
@set CMAKE_VS_PLATFORM_TOOLSET=vs120_wp81
@set WIN32_WINNT=0x603
@set WINAPI_FAMILY=WINAPI_FAMILY_PHONE_APP
@rem set CMAKE_SYSTEM_NAME=WindowsPhone
@rem set WINAPI_FAMILY=WINAPI_FAMILY_PHONE_APP
@goto select_vs

:setup_Windows
@set SDK_VER=8.1
@set CMAKE_SYSTEM_PROCESSOR=ARM
@rem set CMAKE_SYSTEM_NAME=WindowsStore
@set WIN32_WINNT=0x603
@set WINAPI_FAMILY=WINAPI_FAMILY_APP
@goto select_vs

:setup_Metrox86
@set SDK_VER=8.1
@set CMAKE_SYSTEM_PROCESSOR=x86
@rem set CMAKE_SYSTEM_NAME=WindowsStore
@set WIN32_WINNT=0x603
@set WINAPI_FAMILY=WINAPI_FAMILY_APP
@goto select_vs


:setup_Universal86
@set SDK_VER=10.0.10586.0
@set CMAKE_SYSTEM_PROCESSOR=x86
@rem set CMAKE_SYSTEM_NAME=WindowsStore
@set WIN32_WINNT=0x0A00
@set WINAPI_FAMILY=WINAPI_FAMILY_APP
@goto select_vs

:setup_UniversalARM
@set SDK_VER=10.0.10586.0
@set CMAKE_SYSTEM_PROCESSOR=ARM
@rem set CMAKE_SYSTEM_NAME=WindowsStore
@set WIN32_WINNT=0x0A00
@set WINAPI_FAMILY=WINAPI_FAMILY_APP
@goto select_vs

:setup_Universal64
@set SDK_VER=10.0.10586.0
@set CMAKE_SYSTEM_PROCESSOR=amd64
@rem set CMAKE_SYSTEM_NAME=WindowsStore
@set WIN32_WINNT=0x0A00
@set WINAPI_FAMILY=WINAPI_FAMILY_APP
@goto select_vs


:select_vs
@REM automatically select the best available compiler
@IF EXIST "%VS140COMNTOOLS%vsvars32.bat" goto vs2015
@IF EXIST "%VS120COMNTOOLS%vsvars32.bat" goto vs2013
@echo VS 2015 or VS 2013 not found
@exit -1


:vs2015
@rem TODO set VSVARS="%VS140COMNTOOLS%vcvarsqueryregistry.bat"
@set VSVARS="%VS140COMNTOOLS%vsvars32.bat"
@set SDK_VARIANT=store %SDK_VER%
@set CMAKE_VS=Visual Studio 14 2015
@set VS_RUNTIME=dynamic
@set VS_TARGET_ARM=amd64_arm store %SDK_VER%
@set VS_TARGET_x86=amd64_x86 store %SDK_VER%
@set VS_TARGET_AMD64=amd64 store %SDK_VER%
@IF "%CMAKE_VS_PLATFORM_TOOLSET%"=="" set CMAKE_VS_PLATFORM_TOOLSET=vs140
@goto setupenv

:vs2013
@set VSVARS="%VS120COMNTOOLS%vsvars32.bat"
@set SDK_VARIANT=
@set CMAKE_VS=Visual Studio 12 2013
@set VS_RUNTIME=dynamic
@set VS_TARGET_ARM=x86_arm
@set VS_TARGET_x86=x86
@set VS_IS_2013=VS_IS_2013
@IF "%CMAKE_VS_PLATFORM_TOOLSET%"=="" set CMAKE_VS_PLATFORM_TOOLSET=vs120
@goto setupenv


:setupenv
call %VSVARS% %SDK_VARIANT%
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="ARM" call "%VSINSTALLDIR%VC\vcvarsall.bat" %VS_TARGET_ARM%
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="ARM" echo call "%VSINSTALLDIR%VC\vcvarsall.bat" %VS_TARGET_ARM%

@IF "%CMAKE_SYSTEM_PROCESSOR%"=="x86" call "%VSINSTALLDIR%VC\vcvarsall.bat" %VS_TARGET_x86%
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="x86" echo call "%VSINSTALLDIR%VC\vcvarsall.bat" %VS_TARGET_x86%

@IF "%CMAKE_SYSTEM_PROCESSOR%"=="amd64" call "%VSINSTALLDIR%VC\vcvarsall.bat" %VS_TARGET_AMD64%
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="amd64" echo call "%VSINSTALLDIR%VC\vcvarsall.bat" %VS_TARGET_AMD64%

@IF "%CMAKE_SYSTEM_PROCESSOR%"=="ARM" set CMAKE_VS=%CMAKE_VS% ARM
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="amd64" set CMAKE_VS=%CMAKE_VS% Win64
@set CMAKE_SYSTEM_VERSION=%SDK_VER%
@rem set CMAKE_TARGET=-G "%CMAKE_VS%" -DCMAKE_SYSTEM_NAME=%CMAKE_SYSTEM_NAME% -DCMAKE_SYSTEM_VERSION=%CMAKE_SYSTEM_VERSION% -DCMAKE_VS_PLATFORM_TOOLSET=%CMAKE_VS_PLATFORM_TOOLSET% -DCMAKE_SYSTEM_PROCESSOR=%CMAKE_SYSTEM_PROCESSOR%
@set CMAKE_TARGET=-G "%CMAKE_VS%" -DCMAKE_SYSTEM_VERSION=%CMAKE_SYSTEM_VERSION% -DCMAKE_VS_PLATFORM_TOOLSET=%CMAKE_VS_PLATFORM_TOOLSET% -DCMAKE_SYSTEM_PROCESSOR=%CMAKE_SYSTEM_PROCESSOR%
%WD%%MSYSCON% --hold always /usr/bin/bash scripts/main.sh %*
