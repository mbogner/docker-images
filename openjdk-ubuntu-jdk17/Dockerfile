FROM ubuntu:24.04
LABEL org.opencontainers.image.authors="outrage_breath.0t@icloud.com"

RUN useradd --home-dir /home/app -ms /bin/bash app && \
    ln -sf /usr/share/zoneinfo/Europe/Vienna /etc/localtime && \
    sed -i -e 's/archive.ubuntu.com/at.archive.ubuntu.com/g' /etc/apt/sources.list && \
    apt update && apt install -y \
      git \
      openjdk-17-jdk \
      openssh-client \
    && apt clean && apt autoclean && rm -rf /var/lib/apt/lists/*

WORKDIR /home/app
USER app
RUN mkdir -p ~/.ssh && chmod 700 ~/.ssh

EXPOSE 8080
CMD ["java", "-jar", "app.jar"]