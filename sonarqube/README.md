# Sonarqube

This is a sonarqube image based on original community image with various preinstalled plugins.
It also defines a default healthcheck.

On first startup plugins from `/opt/sonarqube/docker/plugins/*.jar` are copied to `/opt/sonarqube/extensions/plugins/`
and a file named `/opt/sonarqube/extensions/plugins/initialised` is created to skip this step on future startups.
This way you can use a volume for `/opt/sonarqube/extensions` and changes on the plugins aren't reset on every startup.

The following plugins are preinstalled:
- sonar-apple-plugin (swift + objective-c)
- sonar-dependency-check-plugin (look for vulnerabilities in dependencies)
- sonar-shellcheck-plugin (shell support)
- sonar-yaml-plugin.jar plugin (yaml file support)
- sonarqube-community-branch-plugin (branch support)

----------

- docker hub: https://hub.docker.com/repository/docker/mbopm/sonarqube
- git: https://github.com/mbogner/docker-images