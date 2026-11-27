# Corretto

Slightly updated amazoncorretto based images with jre and jdk based on amazon linux and alpine.

All define a variable which is picked up by java inside the container:

```shell
JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75 -XX:+ExitOnOutOfMemoryError -XX:-UseBASE64Intrinsics -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"
```

Applications run as user `application` (1000:1000) with home directory `/home/application` (=workdir).

Typical Java applications run on port `8080` so this container exposes `8080` by default.

Of course those values can be overridden in derived work.

Why amazoncorretto? Because amazon is using this for their own infrastructure and they are very fast with patching
security issues.