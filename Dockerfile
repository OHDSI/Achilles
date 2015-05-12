# A Docker container to run the OHDSI/Achilles analysis tool
FROM r-base:3.1.2

MAINTAINER Aaron Browne <brownea@email.chop.edu>

# Remove Debain 'jessie' package pinning by r-base.
RUN echo '' > /etc/apt/apt.conf.d/default

# Install java and clean up.
ENV JAVA_DEBIAN_VERSION 6b34-1.13.6-1
RUN apt-get update && \
    apt-get install -y \
    libcurl4-openssl-dev \
    openjdk-6-jdk="$JAVA_DEBIAN_VERSION" \
    && rm -rf /var/lib/apt/lists/* \
    && R CMD javareconf

# Install Achilles requirements
RUN install2.r --error \
    devtools \
    httr \
    && installGithub.r \
    OHDSI/SqlRender \
    OHDSI/DatabaseConnector \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Configure workspace
WORKDIR /opt/app
ENV PATH /opt/app:$PATH
VOLUME /opt/app/output

# Add project files to container
COPY . /opt/app/
RUN chmod +x /opt/app/docker-run

# Install Achilles from source
RUN R COMMAND INSTALL /opt/app \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Define run script as default command
CMD ["docker-run"]
