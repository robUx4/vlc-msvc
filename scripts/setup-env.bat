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

IF /I "%1" == "WindowsPhone" call "%VCINSTALLDIR%\bin\vcvarsphoneall.bat" %VCVAR%

%WD%%MSYSCON% --hold always /usr/bin/bash scripts/main.sh %*
