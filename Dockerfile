FROM openjdk:21
EXPOSE 8080
ADD target/devops_integration.jar devops_integration.jar
ENTRYPOINT ["java", "-jar", "/devops_integration.jar"]
