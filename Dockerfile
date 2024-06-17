FROM gitlab-registry.nrp-nautilus.io/prp/jupyter-stack/scipy:v1.3

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
ENV PYTHONPATH=/home/${NB_USER}/PTS

COPY environment.yml environment.yml

RUN conda env update -n base -f environment.yml --prune \
 && rm environment.yml

# # Install python dependencies
# RUN conda install -y -c conda-forge -n base \
#     astropy \
#     astroquery \
#     photutils \
#     emcee \
#     corner \
#     fsps \
#     lxml \
#     reportlab
