<img src="https://wcm.io/images/favicon-16@2x.png"/> CONGA AEM Definitions Integration Tests Sample Application
================

This is an AEM project set up with the [wcm.io Maven Archetype for AEM][wcmio-maven-archetype-aem].


### Build and deploy

To build the application run

```
mvn clean install
```

To build and deploy the application to your local AEM instance use these scripts:

* `build-deploy.sh` - Build and deploy to author instance
* `build-deploy-publish.sh` - Build and deploy to publish instance

The first deployment may take a while until all updated OSGi bundles are installed.

After deployment you can open the sample content page in your browser:

* Author: http://localhost:4502/editor.html/content/aemdef-it-sample/en.html
* Publish: http://localhost:4503/content/aemdef-it-sample/en.html

You can deploy individual bundles or content packages to the local AEM instances by using:

* `mvn -Pfast cq:install` - Install and deploy bundle or content package to author instance
* `mvn -Pfast,publish cq:install` - Install and deploy bundle or content package to publish instance

### System requirements

* Java 11
* Apache Maven 3.6.0 or higher
* AEMaaCS SDK author/publish instance running on port 4502/4503
* Or: AEM 6.5 author/publish instance running on port 45025/45035
* To obtain the latest service packs via Maven you have to upload them manually to your Maven Artifact Manager following [these conventions][aem-binaries-conventions] for naming them.

It is recommended to set up the local AEM instances with `nosamplecontent` run mode.


### Project overview

Modules of this project:

* [parent](parent/): Parent POM with dependency management for the whole project. All 3rdparty artifact versions used in the project are defined here.
* [bundles/core](bundles/core/): OSGi bundle containing:
  * Java classes (e.g. Sling Models, Servlets, business logic) with unit tests
  * AEM components with their scripts and dialog definitions (included as `Sling-Initial-Content`)
  * i18n
  * HTML client libraries with JavaScript and CSS
* [content-packages/complete](content-packages/complete/): AEM content package containing all OSGi bundles of the application and their dependencies
* [content-packages/conf-content](content-packages/conf-content/): AEM content package with editable templates stored at `/conf`
* [content-packages/sample-content](content-packages/sample-content/): AEM content package containing sample content (for development and test purposes)
* [config-definition](config-definition/): Defines the CONGA roles and templates for this application. Also contains a `development` CONGA environment for deploying to local development instances.


[wcmio-maven-archetype-aem]: https://wcm.io/tooling/maven/archetypes/aem/
[wcmio-maven]: https://wcm.io/maven.html
[aem-binaries-conventions]: https://wcm-io.atlassian.net/wiki/x/AYC9Aw
