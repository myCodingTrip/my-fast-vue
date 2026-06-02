@echo off
call npm run build
xcopy .\dist\* ..\my-fast\src\main\resources\static /E /H /Y
pause
