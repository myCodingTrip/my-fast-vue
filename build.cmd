npm run build
xcopy .\dist\* ..\my-fast\src\main\resources\static /E /H /Y
cd ..\my-fast
mvn clean package -DskipTests -Pprod
pause
