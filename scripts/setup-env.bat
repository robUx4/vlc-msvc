call "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86_arm

if "%1" NEQ "WindowsPhone" goto Start
set Path=%Path%;C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE
set LIB=C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\lib\store\arm;C:\Program Files (x86)\Windows Phone Kits\8.1\lib\ARM;%LIB%

:Start
start /Wait C:\msys32\usr\bin\sh -c "scripts/main.sh %*"
pause
exit
