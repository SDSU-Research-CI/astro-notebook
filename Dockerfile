ARG BASE_IMAGE=quay.io/jupyter/scipy-notebook:2024-07-29

FROM ${BASE_IMAGE}

# Switch to root for linux installs
USER root
WORKDIR /opt

# Install linux dependencies
RUN apt-get update -y \
 && sudo apt-get install -y \
    cmake

# Setup for SKIRT
RUN mkdir SKIRT \
 && cd SKIRT \
 && mkdir release run git

RUN  cd /opt/SKIRT \
 && git clone https://github.com/SKIRT/SKIRT9.git git \
 && cd /opt/SKIRT/git \
 && chmod +rx configSKIRT.sh \
 && chmod +rx makeSKIRT.sh

# Install SKIRT
RUN cd /opt/SKIRT/git \
 && ./makeSKIRT.sh

RUN cd /opt/SKIRT/git \
 && ./downloadResources.sh --force

# Setup for PTS
WORKDIR /opt

RUN mkdir PTS \
 && cd PTS \
 && mkdir run pts

RUN cd /opt/PTS \
 && git clone https://github.com/SKIRT/PTS9.git pts

RUN echo -e "alias pts=\"python -m pts.do\"" >> /etc/skel/.bashrc

# Switch back to notebook user
USER $NB_USER
WORKDIR /home/${NB_USER}

# Set jovyan environment variables
ENV PATH=$HOME/SKIRT/release/SKIRT/main:$PATH
ENV PYTHONPATH=/opt/PTS

# Install python dependencies
RUN mamba install -y -c conda-forge -n base \
    astropy \
    astroquery \
    photutils \
    emcee \
    corner \
    lxml \
    reportlab

RUN source activate base \
 && pip install fsps
