# Dockerfile

FROM continuumio/miniconda3:latest

# 1) Install system libraries
RUN apt-get update && \
    apt-get install -y \
      build-essential \
      libsndfile1 libsndfile-dev \
      libhdf5-dev libffi-dev libssl-dev \
      libfreetype6-dev libpng-dev pkg-config \
      ffmpeg curl && \
    rm -rf /var/lib/apt/lists/*

# 2) Copy pip requirements
COPY requirements_2080.txt /tmp/requirements.txt

# 3) Install mamba into the base env for faster, more reliable solves
RUN conda install --quiet --yes -n base -c conda-forge mamba

# 4) Create the conda env & pre-install all heavy C-extensions with mamba
RUN mamba create -n diffsingerenv \
      python=3.8 \
      numpy \
      cython \
      pip \
      audioread=2.1.9 \
      h5py=3.1.0 \
      grpcio=1.34.0 \
      google-auth=1.24.0 \
      google-auth-oauthlib=0.4.2 \
      matplotlib=3.3.3 \
      llvmlite=0.31.0 \
      pandas=1.2.0 \
      pillow=8.2.0 \
      -c conda-forge -y && \
    conda clean --all --yes

# 5) Switch into that env for all following RUNs
SHELL ["conda","run","-n","diffsingerenv","/bin/bash","-lc"]

# 6) (Optional) Debug: peek at the first 20 lines of requirements
RUN head -n20 /tmp/requirements.txt

# 7) Strip out the conda-managed packages and numpy/pandas/pillow lines
RUN sed -i '\
  /^audioread==/d; \
  /^h5py==/d; \
  /^grpcio==/d; \
  /^google-auth==/d; \
  /^google-auth-oauthlib==/d; \
  /^matplotlib==/d; \
  /^llvmlite==/d; \
  /^numpy==/d; \
  /^pandas==/d; \
  /^pillow==/d' \
  /tmp/requirements.txt

# 8) Install the remaining pure-Python dependencies
RUN pip install --no-deps -r /tmp/requirements.txt

# 9) Copy your code & set the working directory
WORKDIR /workspace
COPY . /workspace

# 10) Default entrypoint
ENTRYPOINT ["bash","-lc"]
