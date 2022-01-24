@echo off

if not defined AEM_SDK_DISPATCHER_TOOLS ( goto aem_sdk_dispatcher_tools_undefined )
echo.Usen AEM SDK Dispatcher Tools: %AEM_SDK_DISPATCHER_TOOLS%
echo.

echo.--- Build Dispatcher config ---
echo.
call mvn -Pfast -Dconga.environments=local-cloud -Dconga.nodes=aem-dispatcher -Dconga.cloudManager.dispatcherConfig.skip=false clean package
if errorlevel 1 goto build_failed

echo.--- Validate Dispatcher config ---
echo.
IF exist target\validator-ouput ( rmdir /s/q target\validator-ouput )
%AEM_SDK_DISPATCHER_TOOLS%\bin\validator.exe full -d target/validator-ouput target/local-cloud.aem-dispatcher.dispatcher-config.zip
if errorlevel 1 goto valiation_failed

echo.
echo.--- Start dispatcher in docker ---
echo.
echo.Expects AEM publish instance on: http://localhost:4503
echo.Access dispatcher on:            http://localhost:5503
echo.
call %AEM_SDK_DISPATCHER_TOOLS%\bin\docker_run.cmd target\validator-ouput host.docker.internal:4503 5503
if errorlevel 1 goto docker_failed

exit

:build_failed
echo.
echo.*** Build failed ***
echo.
pause
exit

:valiation_failed
echo.
echo.*** Validation failed ***
echo.
pause
exit

:docker_failed
echo.
echo.*** Docker startup failed ***
echo.
pause
exit

:aem_sdk_dispatcher_tools_undefined
echo.
echo.*** Environment variable not defined ***
echo.
echo.Please define AEM_SDK_DISPATCHER_TOOLS pointing to latest aem-sdk-dispatcher-tools-XXX-windows directory.
echo.
pause
exit
