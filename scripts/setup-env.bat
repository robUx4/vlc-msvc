rem call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86_arm
rem call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86_arm store

IF /I "%1" == "WindowsPhone" set VLC_ARCH=ARM
IF /I "%1" == "Windows"      set VLC_ARCH=x86

call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" %VLC_ARCH%
rem store forces %_app.dll runtime that isn't available #wtf

rem set Path=%Path%;C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE;C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE

rem IF /I "%1" == "WindowsPhone" set LIB=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\lib\store\arm;C:\Program Files (x86)\Windows Phone Kits\8.1\lib\ARM;%LIB%
rem IF /I "%1" == "Windows" set LIB=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\lib\store\arm;%LIB%


%WD%%MSYSCON% --hold always /usr/bin/bash scripts/main.sh %*
