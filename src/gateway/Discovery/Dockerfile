FROM openjdk17
VOLUME /tmp
COPY target/discovery-0.0.1-SNAPSHOT.jar discovery-0.0.1-SNAPSHOT.jar
EXPOSE 9191
ENTRYPOINT ["java", "-jar","-Dspring.profiles.active=sandbox","/discovery-0.0.1-SNAPSHOT.jar"]