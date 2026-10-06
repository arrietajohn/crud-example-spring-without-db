FROM maven:3.9.9-eclipse-temurin-21-alpine AS build

ARG JAVA_RELEASE=21

WORKDIR /workspace
COPY pom.xml ./
RUN mvn --batch-mode --no-transfer-progress dependency:go-offline

COPY src ./src
RUN mvn --batch-mode --no-transfer-progress -Djava.version=${JAVA_RELEASE} clean package

FROM eclipse-temurin:21-jre-alpine

RUN addgroup --system spring && adduser --system spring --ingroup spring
USER spring:spring

WORKDIR /application
COPY --from=build /workspace/target/*.jar application.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/application/application.jar"]
