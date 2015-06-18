@IF EXIST "%VS120COMNTOOLS%vsvars32.bat" goto vs2013
@IF EXIST "%VS140COMNTOOLS%vsvars32.bat" goto vs2015
@echo VS 2015 or VS 2013 not found
@exit -1

:vs2015
@set VSVARS="%VS140COMNTOOLS%vsvars32.bat"
@goto setupenv

:vs2013
@set VSVARS="%VS120COMNTOOLS%vsvars32.bat"
@goto setupenv

:setupenv
@IF /I "%1" == "WindowsPhone" goto setup_WindowsPhone
@IF /I "%1" == "WindowsRT"    goto setup_WindowsRT
@IF /I "%1" == "Windows"      goto setup_Windows


:setup_WindowsPhone
call %VSVARS% store
@IF NOT EXIST "%VCINSTALLDIR%vcvarsphoneall.bat" goto bad_vcvarsphoneall
call "%VCINSTALLDIR%vcvarsphoneall.bat" x86_arm
@set LIB=%VCINSTALLDIR%lib\store\arm;%LIB%
@set LIBPATH=%VCINSTALLDIR%lib\store\arm;%LIB%
@goto run_bash

:setup_WindowsRT
call %VSVARS%
@IF NOT EXIST "%VCINSTALLDIR%vcvarsphoneall.bat" goto bad_vcvarsphoneall
call "%VCINSTALLDIR%vcvarsphoneall.bat" x86_arm
@set LIB=%VCINSTALLDIR%lib\store\arm;%LIB%
@set LIBPATH=%VCINSTALLDIR%lib\store\arm;%LIB%
@goto run_bash

:setup_Windows
call %VSVARS%
call "%VSINSTALLDIR%VC\vcvarsall.bat" x86
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
