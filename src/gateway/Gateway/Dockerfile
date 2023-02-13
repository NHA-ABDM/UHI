FROM openjdk17
VOLUME /tmp
COPY target/gateway-app-0.0.1-SNAPSHOT.jar gateway-app-0.0.1-SNAPSHOT.jar
EXPOSE 8083
ENTRYPOINT ["java", "-jar","-Dspring.profiles.active=sandbox","/gateway-app-0.0.1-SNAPSHOT.jar"]