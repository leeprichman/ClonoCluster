# docker build . -t leeprichman/clonocluster
FROM r-base:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV TERM linux
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        default-jre \
        git \
        gnupg \
        libcurl4-openssl-dev \
        libssl-dev \
        libxml2-dev \
        parallel \
        r-base \
        r-base-dev \
        r-recommended \
        software-properties-common \
        subversion \
        tcsh \
    && rm -rf /var/lib/apt/lists/*

## https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen en_US.utf8 \
	&& /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM linux


RUN Rscript --vanilla -e \
    'install.packages(c("magrittr", "testthat", "Seurat", "data.table", "devtools"), repos = "http://cran.us.r-project.org")'

WORKDIR /root
RUN mkdir ClonoCluster
COPY . ./ClonoCluster

RUN Rscript --vanilla -e \
    'devtools::install("ClonoCluster", dependencies = TRUE)'

CMD ["bash"]
