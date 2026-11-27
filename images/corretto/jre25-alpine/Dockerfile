# Corretto 25 runtime on Alpine. Corretto publishes no runtime-only image for Alpine, so this one is built from the
# Corretto Alpine JDK, made to match Corretto's own headless runtime (amazoncorretto:25-al2023-headless).
# Both stages use the same Alpine release: the copied binaries need the system libraries they were built against.
FROM amazoncorretto:25-alpine3.24 AS jdk

# Remove exactly what the headless runtime leaves out: the developer tools (it keeps java, keytool and rmiregistry),
# jmods, headers, man pages, the X11 libraries and async-profiler. All modules and all other native libraries stay,
# so any app that runs on the JDK runs here.
# rm without -f: if Corretto moves or renames one of these files, the build fails instead of silently shipping it.
RUN cd /usr/lib/jvm/java-25-amazon-corretto \
 && find bin -type f ! -name java ! -name keytool ! -name rmiregistry -delete \
 && rm -r jmods include man \
 && rm lib/libawt_xawt.so lib/libjawt.so lib/libsplashscreen.so \
       lib/libasyncProfiler.so legal/async-profiler.md

FROM alpine:3.24
LABEL org.opencontainers.image.authors="outrage_breath.0t@icloud.com"

# The system packages the headless runtime has on Amazon Linux: fonts for AWT, which draws text without a display
# (images, PDFs, charts, Excel column widths), and ALSA for javax.sound.
RUN apk add --no-cache fontconfig font-dejavu font-noto alsa-lib

# The runtime and its default-jvm link, at the same paths and with the same environment as the amazoncorretto image.
COPY --from=jdk /usr/lib/jvm /usr/lib/jvm
ENV LANG=C.UTF-8 \
    JAVA_HOME=/usr/lib/jvm/default-jvm \
    PATH=$PATH:/usr/lib/jvm/default-jvm/bin

# java -version fails the build if the runtime cannot start on this Alpine release.
RUN java -version \
 && addgroup -g 1000 application \
 && adduser -D -u 1000 -G application -h /home/application -s /bin/sh application
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75 -XX:+ExitOnOutOfMemoryError -XX:-UseBASE64Intrinsics -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"

USER 1000:1000
WORKDIR /home/application
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
