FROM eclipse-temurin:21-jdk
WORKDIR /app
COPY target/jpetstore.war
app.war
CMD ["java", "-jar", "app.war"]
