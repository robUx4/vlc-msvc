call "C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" x86_arm

set Path=%Path%;C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE

IF /I "%1" == "WindowsPhone" set LIB=C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\lib\store\arm;C:\Program Files (x86)\Windows Phone Kits\8.1\lib\ARM;%LIB%
IF /I "%1" == "Windows" set LIB=C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\lib\store\arm;%LIB%


%WD%%MSYSCON% --hold always /usr/bin/bash scripts/main.sh %*
