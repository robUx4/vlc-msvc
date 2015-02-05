call "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86_arm

set Path=%Path%;C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE

IF /I "%1" == "WindowsPhone" set LIB=C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\lib\store\arm;C:\Program Files (x86)\Windows Phone Kits\8.1\lib\ARM;%LIB%
IF /I "%1" == "Windows" set LIB=C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\lib\store\arm;%LIB%

IF EXIST C:\msys32\usr\bin\sh.exe (
	set SH_EXEC=C:\msys32\usr\bin\sh
) ELSE (
	set SH_EXEC=C:\msys64\usr\bin\sh
)

start /Wait %SH_EXEC% -c "scripts/main.sh %* pause"
