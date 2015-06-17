@IF EXIST "%VS140COMNTOOLS%vsvars32.bat" goto vs2015
@IF EXIST "%VS120COMNTOOLS%vsvars32.bat" goto vs2013

:vs2015
@call "%VS140COMNTOOLS%vsvars32.bat"
@goto setupenv

:vs2013
@call "%VS120COMNTOOLS%vsvars32.bat"
@goto setupenv

:setupenv
@IF /I "%1" == "WindowsPhone" set VCVAR=x86_arm
@IF /I "%1" == "Windows"      set VCVAR=x86
@rem adding "store" forces %_app.dll runtime that aren't available

call "%VSINSTALLDIR%VC\vcvarsall.bat" %VCVAR%

IF /I NOT "%1" == "WindowsPhone"  goto run_bash

@IF NOT EXIST "%VCINSTALLDIR%vcvarsphoneall.bat" goto bad_vcvarsphoneall
call "%VCINSTALLDIR%vcvarsphoneall.bat" %VCVAR%

:run_bash
%WD%%MSYSCON% --hold always /usr/bin/bash scripts/main.sh %*
goto end

:bad_vcvarsphoneall
echo "%VCINSTALLDIR%bin\vcvarsphoneall.bat" needs to be moved into "%VCINSTALLDIR%vcvarsphoneall.bat"
@IF NOT EXIST "%VS140COMNTOOLS%vsvars32.bat" goto end
echo "%VCINSTALLDIR%bin\x86_arm\vcvarsphonex86_arm.bat" needs to call "%VS140COMNTOOLS%VCVarsPhoneQueryRegistry.bat" not "%~dp0VCVarsPhoneQueryRegistry.bat"
echo "%VS140COMNTOOLS%VCVarsPhoneQueryRegistry.bat" needs to look for v8.1 SDKs, not v8.0 ones
goto end

:end
