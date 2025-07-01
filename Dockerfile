FROM continuumio/miniconda3:latest

# (1) system deps
RUN apt-get update && apt-get install -y \
      build-essential libsndfile1 libsndfile-dev \
      libhdf5-dev libffi-dev libssl-dev \
      libfreetype6-dev libpng-dev pkg-config \
      ffmpeg curl && rm -rf /var/lib/apt/lists/*

# (2) conda env + heavy libs
COPY requirements_2080.txt /tmp/requirements.txt
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
    miditoolkit=0.1.7 \
    -c conda-forge -y && \
    conda clean --all --yes

SHELL ["conda","run","-n","diffsingerenv","/bin/bash","-lc"]

# debug: show what’s left
RUN head -n20 /tmp/requirements.txt

# remove all the big C‐exts and NumPy‐dependent packages
RUN sed -i '\
  /^audioread==/d; \
  /^grpcio==/d; \
  /^google-auth==/d; \
  /^google-auth-oauthlib==/d; \
  /^h5py==/d; \
  /^matplotlib==/d; \
  /^llvmlite==/d; \
  /^numpy==/d; \
  /^music21==/d; \
  /^miditoolkit==/d' \
  /tmp/requirements.txt

# now pip will only see pure‐Python modules
RUN pip install --no-build-isolation --no-deps -r /tmp/requirements.txt

# (6) copy code & entrypoint
WORKDIR /workspace
COPY . /workspace
ENTRYPOINT ["bash","-lc"]
