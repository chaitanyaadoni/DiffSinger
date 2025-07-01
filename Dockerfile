# Dockerfile

FROM continuumio/miniconda3:latest

# 1) Install system libraries & curl
RUN apt-get update && \
    apt-get install -y \
      build-essential \
      libsndfile1 \
      libsndfile-dev \
      libhdf5-dev \
      libffi-dev \
      libssl-dev \
      libfreetype6-dev \
      libpng-dev \
      pkg-config \
      ffmpeg \
      curl && \
    rm -rf /var/lib/apt/lists/*

# 2) Copy pip requirements for caching
COPY requirements_2080.txt /tmp/requirements.txt

# 3) Create conda env & install heavy C‐ext packages from conda-forge
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

# 4) Use the new conda env for subsequent RUN steps
SHELL ["conda", "run", "-n", "diffsingerenv", "/bin/bash", "-lc"]

# 5) Debug: show the first 20 lines of the pip requirements
RUN head -n 20 /tmp/requirements.txt

# 6) Strip out only the packages now provided by conda
RUN sed -i '\
  /^audioread==/d; \
  /^grpcio==/d; \
  /^google-auth==/d; \
  /^google-auth-oauthlib==/d; \
  /^h5py==/d; \
  /^matplotlib==/d; \
  /^llvmlite==/d; \
  /^numpy==/d; \
  /^music21==/d' \
  /tmp/requirements.txt

# 7) Install the remaining (pure-Python) requirements
RUN pip install --no-build-isolation --no-deps -r /tmp/requirements.txt

# 8) Copy your code and set working directory
WORKDIR /workspace
COPY . /workspace

# 9) Default to bash
ENTRYPOINT ["bash", "-lc"]
