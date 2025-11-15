FROM eclipse-temurin:21-jre

# Установка необходимых пакетов
RUN apt-get update && \
    apt-get install -y wget curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Создание рабочей директории
WORKDIR /minecraft

# Версия NeoForge (актуальная для 1.21.1)
ENV MINECRAFT_VERSION=1.21.1
ENV NEOFORGE_VERSION=21.1.77

# Скачивание NeoForge установщика
RUN wget -O neoforge-installer.jar \
    "https://maven.neoforged.net/releases/net/neoforged/neoforge/${MINECRAFT_VERSION}-${NEOFORGE_VERSION}/neoforge-${MINECRAFT_VERSION}-${NEOFORGE_VERSION}-installer.jar"

# Установка NeoForge сервера
RUN java -jar neoforge-installer.jar --installServer && \
    rm neoforge-installer.jar

# Скачивание authlib-injector для поддержки ely.by скинов
RUN wget -O authlib-injector.jar \
    https://github.com/yushijinhun/authlib-injector/releases/latest/download/authlib-injector.jar

# Переменные окружения для Java
ENV JAVA_MEMORY=2G

# Порт сервера
EXPOSE 25565

# Создание стартового скрипта
RUN echo '#!/bin/bash\n\
echo "eula=true" > eula.txt\n\
exec java -Xmx${JAVA_MEMORY} -Xms${JAVA_MEMORY} \\\n\
-XX:+UseG1GC \\\n\
-XX:+ParallelRefProcEnabled \\\n\
-XX:MaxGCPauseMillis=200 \\\n\
-XX:+UnlockExperimentalVMOptions \\\n\
-XX:+DisableExplicitGC \\\n\
-XX:G1NewSizePercent=30 \\\n\
-XX:G1MaxNewSizePercent=40 \\\n\
-XX:G1HeapRegionSize=8M \\\n\
-XX:G1ReservePercent=20 \\\n\
-XX:G1HeapWastePercent=5 \\\n\
-XX:G1MixedGCCountTarget=4 \\\n\
-XX:InitiatingHeapOccupancyPercent=15 \\\n\
-XX:G1MixedGCLiveThresholdPercent=90 \\\n\
-javaagent:authlib-injector.jar=https://ely.by/api/authlib-injector \\\n\
@libraries/net/neoforged/neoforge/${MINECRAFT_VERSION}-${NEOFORGE_VERSION}/unix_args.txt \\\n\
nogui' > start.sh && chmod +x start.sh

CMD ["./start.sh"]