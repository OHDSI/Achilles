# A Docker container to run the OHDSI/Achilles analysis tool
FROM ubuntu:xenial

MAINTAINER Taha Abdul-Basser <ta2471@cumc.columbia.edu>

# Install java, R and required packages and clean up.
RUN echo deb http://ppa.launchpad.net/marutter/rrutter4.0/ubuntu xenial main >> /etc/apt/sources.list && \
    echo deb http://ppa.launchpad.net/c2d4u.team/c2d4u4.0+/ubuntu xenial main >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C9A7585B49D51698710F3A115E25F516B04C661B && \
    sed 's#http://.*archive\.ubuntu\.com/ubuntu/#mirror://mirrors.ubuntu.com/mirrors.txt#g' -i /etc/apt/sources.list && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated \
      r-base \
      r-cran-devtools \
      r-cran-httr \
      r-cran-rjson \
      r-cran-stringr \
      r-cran-rjava \
      r-cran-dbi \
      r-cran-ffbase \
      r-cran-urltools \
      libxml2-dev \
      littler \
      locales \
      openjdk-8-jdk \
    && rm -rf /var/lib/apt/lists/* \
    && R CMD javareconf

# Set default locale
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# Install OHDSI/ParallelLogger 
RUN R -e "install.packages( \
 c( \
  'XML', \
  'RJSONIO' \
 ), \ 
 repos='http://cran.rstudio.com/', \
) "

# Install Achilles requirements that need to be installed from source
RUN echo 'options(repos=structure(c(CRAN="https://cloud.r-project.org/")))' > /root/.Rprofile && \
    /usr/share/doc/littler/examples/install.r remotes && \
    /usr/share/doc/littler/examples/install.r docopt && \
    /usr/share/doc/littler/examples/install.r openxlsx && \
    /usr/share/doc/littler/examples/install.r httr && \
    /usr/share/doc/littler/examples/install.r rjson && \
    /usr/share/doc/littler/examples/install.r R.oo && \
    /usr/share/doc/littler/examples/install.r formatR && \
    /usr/share/doc/littler/examples/install.r R.utils && \
    /usr/share/doc/littler/examples/install.r snow && \
    /usr/share/doc/littler/examples/install.r mailR && \
    /usr/share/doc/littler/examples/install.r dplyr && \
    /usr/share/doc/littler/examples/install.r readr && \
    /usr/share/doc/littler/examples/installGithub.r \
      OHDSI/SqlRender \
      OHDSI/DatabaseConnectorJars \
      OHDSI/DatabaseConnector \
      OHDSI/ParallelLogger \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Configure workspace
WORKDIR /opt/app
ENV PATH /opt/app:$PATH
VOLUME /opt/app/output

# Add project files to container
COPY . /opt/app/

# Install Achilles from source
RUN R CMD INSTALL /opt/app \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
    && find /opt/app -mindepth 1 -not \( -wholename /opt/app/docker-run -or -wholename /opt/app/output \) -delete

# Define run script as default command
CMD ["docker-run"]
