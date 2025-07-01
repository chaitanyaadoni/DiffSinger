# Dockerfile

FROM continuumio/miniconda3:latest

# 1) System dependencies
RUN apt-get update && \
    apt-get install -y \
      build-essential \
      libsndfile1 libsndfile-dev \
      libhdf5-dev libffi-dev libssl-dev \
      libfreetype6-dev libpng-dev pkg-config \
      ffmpeg curl && \
    rm -rf /var/lib/apt/lists/*

# 2) Copy your pip requirements
COPY requirements_2080.txt /tmp/requirements.txt

# 3) Create the conda env + install all heavy C-extensions (incl. music21)
RUN conda create -n diffsingerenv \
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
      music21=5.7.2 \
      -c conda-forge -y && \
    conda clean --all --yes

# 4) Switch into that env for all next RUNs
SHELL ["conda","run","-n","diffsingerenv","/bin/bash","-lc"]

# 5) Strip out the conda-managed packages from pip’s list
RUN sed -i '\
  /^audioread==/d; \
  /^h5py==/d; \
  /^grpcio==/d; \
  /^google-auth==/d; \
  /^google-auth-oauthlib==/d; \
  /^matplotlib==/d; \
  /^llvmlite==/d; \
  /^numpy==/d; \
  /^music21==/d' \
  /tmp/requirements.txt

# 6) Now install only the remaining (pure-Python) deps
RUN pip install --no-deps -r /tmp/requirements.txt

# 7) Copy in your code & set the workdir
WORKDIR /workspace
COPY . /workspace

# 8) Default to bash
ENTRYPOINT ["bash","-lc"]
