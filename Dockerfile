FROM openjdk:21.0.11
COPY . /usr/src/myapp
WORKDIR /usr/src/myapp
RUN ./mvnw clean package
CMD ./mvnw cargo:run -P tomcat90
