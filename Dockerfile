FROM eclipse-temurin:11.0.32_9-jre-alpine-3.24
EXPOSE 8080
ARG JAR_FILE=target/*.jar
ADD ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
