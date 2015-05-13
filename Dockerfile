# A Docker container to run the OHDSI/Achilles analysis tool
FROM r-base:3.1.2

MAINTAINER Aaron Browne <brownea@email.chop.edu>

# Remove Debain 'jessie' package pinning by r-base.
RUN echo '' > /etc/apt/apt.conf.d/default

# Install java and clean up.
RUN apt-get update && \
    apt-get install -y \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    openjdk-6-jdk \
    && rm -rf /var/lib/apt/lists/* \
    && R CMD javareconf

# Install Achilles requirements
RUN install2.r --error \
    devtools \
    httr \
    rjson \
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
RUN R CMD INSTALL /opt/app \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Define run script as default command
CMD ["docker-run"]
