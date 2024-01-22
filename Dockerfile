ARG BASE_VERSION
#  ----------------------------------  Base image
FROM ghcr.io/jodconverter/jodconverter-runtime:$BASE_VERSION as jodconverter-app-base
ENV JAR_FILE_NAME=app.war
ENV JAR_FILE_BASEDIR=/opt/app
ENV LOG_BASE_DIR=/var/log
ENV NONPRIVUSER=jodconverter
ENV NONPRIVGROUP=jodconverter

COPY ./bin/docker-entrypoint.sh /docker-entrypoint.sh

RUN mkdir -p ${JAR_FILE_BASEDIR} /etc/app \
  && touch /etc/app/application.properties /var/log/app.log /var/log/app.err \
  && chmod +x /docker-entrypoint.sh \
  && chown $NONPRIVUSER:$NONPRIVGROUP /var/log/app.log /var/log/app.err

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["--spring.config.additional-location=optional:/etc/app/"]

#  ----------------------------------  build our jodconvert builder, so source code with build tools
FROM bellsoft/liberica-openjdk-debian:17 as builder
RUN apt-get update \
  && apt-get -y install git \
  && git clone https://github.com/cuipengfei/jodconverter-samples /tmp/jodconverter-samples \
  ## fixing https://github.com/jodconverter/jodconverter-samples/issues/2
  && chmod +x /tmp/jodconverter-samples/gradlew \
  && mkdir /dist

#  ----------------------------------  rest build
FROM builder as jodconverter-build-rest
WORKDIR /tmp/jodconverter-samples
RUN ./gradlew -x test :samples:spring-boot-rest:build \
  && cp samples/spring-boot-rest/build/libs/spring-boot-rest.war /dist/jodconverter-rest.war

#  ----------------------------------  REST prod image
FROM jodconverter-app-base as rest

# support more fonts
COPY cjk-fonts/* /usr/share/fonts/cjk/
COPY condensed-fonts/* /usr/share/fonts/condensed/
COPY ms-sub-fonts/* /usr/share/fonts/ms-sub-fonts/

# add user profile config files
COPY ./profile/LibreOffice/4/user /tmp/jodconverter/user

COPY --from=jodconverter-build-rest /dist/jodconverter-rest.war ${JAR_FILE_BASEDIR}/${JAR_FILE_NAME}