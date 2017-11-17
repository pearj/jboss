FROM openjdk:7

ENV JBOSS_VERSION 7.1.1.Final
ENV JBOSS_SHA1 fcec1002dce22d3281cc08d18d0ce72006868b6f
ENV JBOSS_HOME /opt/jboss/jboss

USER root

RUN groupadd -r jboss -g 1000 && useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss && \
    chmod 755 /opt/jboss

# Set the working directory to jboss' user home directory
WORKDIR /opt/jboss

# Add the JBOSS distribution to /opt, and make jboss the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
RUN cd $HOME \
    && curl -O http://download.jboss.org/jbossas/$(echo $JBOSS_VERSION | cut -d'.' -f1,2)/jboss-as-$JBOSS_VERSION/jboss-as-$JBOSS_VERSION.tar.gz \
    && sha1sum jboss-as-$JBOSS_VERSION.tar.gz | grep $JBOSS_SHA1 \
    && tar xf jboss-as-$JBOSS_VERSION.tar.gz \
    && mv $HOME/jboss-as-$JBOSS_VERSION $JBOSS_HOME \
    && rm jboss-as-$JBOSS_VERSION.tar.gz \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME}

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss

# Expose the ports we're interested in
EXPOSE 8080

# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interface
CMD ["/opt/jboss/jboss/bin/standalone.sh", "-b", "0.0.0.0"]
