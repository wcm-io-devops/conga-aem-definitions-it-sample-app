@echo off

SET CONGA_ENVIRONMENT="cloud"
SET CONGA_NODE="aem-publish"

call mvn -Pfast -Dconga.environments=%CONGA_ENVIRONMENT% -Dconga.nodeDirectory=target/configuration/%CONGA_ENVIRONMENT%/%CONGA_NODE% -Dconga.cloudManager.dispatcherConfig.skip=false clean package

%AEM_SDK_DISPATCHER_TOOLS%\bin\validator.exe full target/cloud.aem-dispatcher.dispatcher-config.zip

pause
