
FROM tomcat:9.0

# remove default apps
RUN rm -rf /usr/local/tomcat/webapps/*

# copy WAR file
COPY target/jpetstore.war /usr/local/tomcat/webapps/ROOT.war
