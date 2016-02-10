@REM adjust the SDK depending on the target
@IF /I "%1" == "WindowsPhone" goto setup_WindowsPhone
@IF /I "%1" == "Windows"      goto setup_Windows
@IF /I "%1" == "Metrox86"     goto setup_Metrox86
@echo Unknown target "%1"
@exit -1


:setup_WindowsPhone
@set SDK_VER=8.1
@set CMAKE_SYSTEM_PROCESSOR=ARM
@set CMAKE_VS_PLATFORM_TOOLSET=vs120_wp81
@rem set CMAKE_SYSTEM_NAME=WindowsPhone
@goto select_vs

:setup_Windows
@set SDK_VER=8.1
@set CMAKE_SYSTEM_PROCESSOR=ARM
@set CMAKE_SYSTEM_NAME=WindowsStore
@goto select_vs

:setup_Metrox86
@set SDK_VER=8.1
@set CMAKE_SYSTEM_PROCESSOR=x86
@set CMAKE_SYSTEM_NAME=WindowsStore
@goto select_vs


:select_vs
@REM automatically select the best available compiler
@IF EXIST "%VS120COMNTOOLS%vsvars32.bat" goto vs2013
@IF EXIST "%VS140COMNTOOLS%vsvars32.bat" goto vs2015
@echo VS 2015 or VS 2013 not found
@exit -1


:vs2015
@set VSVARS="%VS140COMNTOOLS%vsvars32.bat"
@set SDK_VARIANT=store %SDK_VER%
@set CMAKE_VS=Visual Studio 14 2015
@set VS_RUNTIME=dynamic
@set VS_TARGET_ARM=amd64_arm
@set VS_TARGET_x86=amd64_x86
@IF "%CMAKE_VS_PLATFORM_TOOLSET%"=="" set CMAKE_VS_PLATFORM_TOOLSET=vs140
@goto setupenv

:vs2013
@set VSVARS="%VS120COMNTOOLS%vsvars32.bat"
@set SDK_VARIANT=
@set CMAKE_VS=Visual Studio 12 2013
@set VS_RUNTIME=dynamic
@set VS_TARGET_ARM=x86_arm
@set VS_TARGET_x86=x86
@IF "%CMAKE_VS_PLATFORM_TOOLSET%"=="" set CMAKE_VS_PLATFORM_TOOLSET=vs120
@goto setupenv


:setupenv
call %VSVARS% %SDK_VARIANT%
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="ARM" call "%VSINSTALLDIR%VC\vcvarsall.bat" %VS_TARGET_ARM%
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="ARM" echo call "%VSINSTALLDIR%VC\vcvarsall.bat" %VS_TARGET_ARM%

@IF "%CMAKE_SYSTEM_PROCESSOR%"=="x86" call "%VSINSTALLDIR%VC\vcvarsall.bat" %VS_TARGET_x86%
@IF "%CMAKE_SYSTEM_PROCESSOR%"=="x86" echo call "%VSINSTALLDIR%VC\vcvarsall.bat" %VS_TARGET_x86%

@IF "%CMAKE_SYSTEM_PROCESSOR%"=="ARM" set CMAKE_VS=%CMAKE_VS% ARM
@set CMAKE_SYSTEM_VERSION=%SDK_VER%
@set CMAKE_TARGET=-G "%CMAKE_VS%" -DCMAKE_SYSTEM_VERSION=%CMAKE_SYSTEM_VERSION% -DCMAKE_VS_PLATFORM_TOOLSET=%CMAKE_VS_PLATFORM_TOOLSET% -DCMAKE_SYSTEM_PROCESSOR=%CMAKE_SYSTEM_PROCESSOR%
%WD%%MSYSCON% --hold always /usr/bin/bash scripts/main.sh %*
