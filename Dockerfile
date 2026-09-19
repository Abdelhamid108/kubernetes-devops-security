FROM eclipse-temurin:17.0.20_8-jre-alpine-3.24

EXPOSE 8080

ARG JAR_FILE=target/*.jar

RUN addgroup -S -g 10001 pipeline &&  adduser -S -u 10001 -G pipeline k8s-pipeline

COPY --chown=10001:10001 ${JAR_FILE} /home/k8s-pipeline/app.jar

USER 10001:10001

ENTRYPOINT ["java", "-jar", "/home/k8s-pipeline/app.jar"]