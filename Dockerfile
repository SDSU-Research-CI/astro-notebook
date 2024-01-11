FROM gitlab-registry.nrp-nautilus.io/prp/jupyter-stack/scipy:v1.3

# Switch back to notebook user
USER $NB_USER
WORKDIR /home/${NB_USER}

# Install astropy, astroquery, and photutils
RUN conda install -y -c conda-forge -n base \
    astropy \
    astroquery \
    photutils
