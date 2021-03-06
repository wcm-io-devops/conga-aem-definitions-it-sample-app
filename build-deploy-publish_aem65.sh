#!/bin/bash
# #%L
#  wcm.io
#  %%
#  Copyright (C) 2022 wcm.io
#  %%
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  #L%

# Call with "help" parameter to display syntax information

MAVEN_PROFILES="fast,publish,aem65"
CONGA_NODE="aem-publish"
CONGA_ENVIRONMENT="local-aem65"

if [[ $0 == *":\\"* ]]; then
  DISPLAY_PAUSE_MESSAGE=true
fi

./build-deploy.sh --maven.profiles=${MAVEN_PROFILES} --conga.node=${CONGA_NODE} --conga.environment=${CONGA_ENVIRONMENT} --display.pause.message=${DISPLAY_PAUSE_MESSAGE} "$@"
