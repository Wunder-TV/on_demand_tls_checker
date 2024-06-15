# container
There will be Image-Definitions with default configuration. Currently we provide "apache", "php", "shopware".
"Shopware" will basically be PHP with specific Version for specifc Shopware-Version. 

There is a ".gitlab-ci.yml"-file which will define the build processes. 

Images will be created within a pipeline-run, pushed to the GitLab provided image repository.

## php
currently we provide a php-based Image, we additionally install caddy, supervisord, nodejs, (shopware) default php-extensions.
The entrypoint is now supervisord, which manages php and caddy.

Usefull paths: 
- /etc/caddy/Caddyfile 
This is a usefull Caddyfile as of shopware requirements. It works, including Content-Policy.
We usually add / exchange this file in the specific projects. Defaults will be rolled out by Hosting-Team to /opt/onacy_container/tooling/default-dockerfiles. (For example: Shopware+BasicAuth)
```
  image: shopware_app:${BUILD_TAG}
  build:
    context: /opt/onacy_container/tooling/default-dockerfiles/Caddy/
    dockerfile: Dockerfile
    args:
      - IMAGEID=registry.gitlab.com/onacy/docker/container/php:php8.2_node18
      - CADDYFLAVOR=Shopware
      - APP_ENV=${CI_APP_ENV}
```
Please see reference projects or ask at Hosting :)

## php versions
at container/.gitlab-ci.yml you'll find the build-steps where our containers are build. 
We used the "parallel.matrix" section to manage multiple versions.

```
      - PHP_VERSION: "8.2" 
        NODE_VERSION: "18" 
        COMPOSER_VERSION: "2.4.4"
      - PHP_VERSION: "8.1"
        NODE_VERSION: "18" 
        COMPOSER_VERSION: "2.4.4"
```
The listed example will create two images. registry.gitlab.com/onacy/docker/container/php:php8.2_node18 and registry.gitlab.com/onacy/docker/container/php:php8.1_node18.

The Variables PHP_VERSION and NODE_VERSION also build the Imagename.