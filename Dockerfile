FROM eclipse-temurin:11.0.32_9-jre-alpine-3.24

EXPOSE 8080

ARG JAR_FILE=target/*.jar

RUN addgroup -S pipeline && adduser -S k8s-pipeline -G pipeline

COPY  ${JAR_FILE} home/k8s-pipeline/app.jar

USER k8s-pipeline

ENTRYPOINT ["java","-jar","home/k8s-pipeline/app.jar"]
