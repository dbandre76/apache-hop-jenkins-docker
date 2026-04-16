FROM apache/hop-web:2.11.0

USER root

COPY web.xml /usr/local/tomcat/webapps/ROOT/WEB-INF/web.xml

COPY tomcat-users.xml /usr/local/tomcat/conf/tomcat-users.xml

#RUN chown -R hop:hop /project /config

#RUN chmod -R 775 /project /config


USER hop

RUN mkdir /usr/local/tomcat/webapps/ROOT/project

RUN chown -R hop:hop /usr/local/tomcat/webapps/ROOT/project /usr/local/tomcat/webapps/ROOT/config

