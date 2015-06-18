@IF EXIST "%VS140COMNTOOLS%vsvars32.bat" goto vs2015
@IF EXIST "%VS120COMNTOOLS%vsvars32.bat" goto vs2013
@echo VS 2015 or VS 2013 not found
@exit -1

:vs2015
@set VSVARS="%VS140COMNTOOLS%vsvars32.bat"
@set STORE_VARIANT=store
@goto setupenv

:vs2013
@set VSVARS="%VS120COMNTOOLS%vsvars32.bat"
@set STORE_VARIANT=
@goto setupenv

:setupenv
@IF /I "%1" == "WindowsPhone" goto setup_WindowsPhone
@IF /I "%1" == "WindowsRT"    goto setup_WindowsRT
@IF /I "%1" == "Windows"      goto setup_Windows


:setup_WindowsPhone
call %VSVARS% %STORE_VARIANT%
call "%VSINSTALLDIR%VC\vcvarsall.bat" x86_arm %STORE_VARIANT%
@IF NOT EXIST "%VCINSTALLDIR%vcvarsphoneall.bat" goto bad_vcvarsphoneall
@call "%VCINSTALLDIR%vcvarsphoneall.bat" x86_arm
@goto run_bash

:setup_WindowsRT
call %VSVARS%
call "%VSINSTALLDIR%VC\vcvarsall.bat" x86_arm
@IF NOT EXIST "%VCINSTALLDIR%vcvarsphoneall.bat" goto bad_vcvarsphoneall
@call "%VCINSTALLDIR%vcvarsphoneall.bat" x86_arm
@goto run_bash

:setup_Windows
call %VSVARS%
call "%VSINSTALLDIR%VC\vcvarsall.bat" x86
@goto run_bash


:run_bash
%WD%%MSYSCON% --hold always /usr/bin/bash scripts/main.sh %*
@goto end

:bad_vcvarsphoneall
@echo "%VCINSTALLDIR%bin\vcvarsphoneall.bat" needs to be moved into "%VCINSTALLDIR%vcvarsphoneall.bat"
@IF NOT EXIST "%VS140COMNTOOLS%vsvars32.bat" goto end
@echo "%VCINSTALLDIR%bin\x86_arm\vcvarsphonex86_arm.bat" needs to call "%VS140COMNTOOLS%VCVarsPhoneQueryRegistry.bat" not "%~dp0VCVarsPhoneQueryRegistry.bat"
@echo "%VS140COMNTOOLS%VCVarsPhoneQueryRegistry.bat" needs to look for v8.1 SDKs, not v8.0 ones
@goto end

:end
