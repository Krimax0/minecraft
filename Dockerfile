FROM eclipse-temurin:21-jre

# Установка необходимых пакетов
RUN apt-get update && \
    apt-get install -y wget curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Создание рабочей директории
WORKDIR /minecraft

# Версия NeoForge
ENV NEOFORGE_VERSION=21.1.73
ENV MINECRAFT_VERSION=1.21.1

# Скачивание NeoForge установщика
RUN wget -O neoforge-installer.jar \
    https://maven.neoforged.net/releases/net/neoforged/neoforge/${MINECRAFT_VERSION}-${NEOFORGE_VERSION}/neoforge-${MINECRAFT_VERSION}-${NEOFORGE_VERSION}-installer.jar

# Установка NeoForge
RUN java -jar neoforge-installer.jar --installServer && \
    rm neoforge-installer.jar

# Скачивание authlib-injector для поддержки ely.by скинов
RUN wget -O authlib-injector.jar \
    https://github.com/yushijinhun/authlib-injector/releases/latest/download/authlib-injector.jar

# Переменные окружения
ENV JAVA_MEMORY=2G
ENV JAVA_ARGS="-Xmx\${JAVA_MEMORY} -Xms\${JAVA_MEMORY} -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200"

# Порт сервера
EXPOSE 25565

# Создание стартового скрипта
RUN echo '#!/bin/bash\n\
echo "eula=true" > eula.txt\n\
exec java ${JAVA_ARGS} \
-javaagent:authlib-injector.jar=https://ely.by/api/authlib-injector \
-jar @libraries/net/neoforged/neoforge/${MINECRAFT_VERSION}-${NEOFORGE_VERSION}/unix_args.txt \
nogui' > start.sh && chmod +x start.sh

CMD ["./start.sh"]