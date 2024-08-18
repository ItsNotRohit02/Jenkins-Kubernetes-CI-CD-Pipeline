FROM tomcat:8-jre11

LABEL "Project"="Docker-WebApp"
LABEL "Author"="ItsNotRohit02"

RUN rm -rf /usr/local/tomcat/webapps/*

COPY target/Sample-v10.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]