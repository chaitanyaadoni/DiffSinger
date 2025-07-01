FROM continuumio/miniconda3:latest

# (1) system deps
RUN apt-get update && apt-get install -y \
      build-essential libsndfile1 libsndfile-dev \
      libhdf5-dev libffi-dev libssl-dev \
      libfreetype6-dev libpng-dev pkg-config \
      ffmpeg curl && rm -rf /var/lib/apt/lists/*

# (2) conda env + heavy libs
COPY requirements_2080.txt /tmp/requirements.txt
RUN conda create -n diffsingerenv python=3.8 numpy cython pip \
      audioread=2.1.9 h5py=3.1.0 grpcio=1.34.0 \
      google-auth=1.24.0 google-auth-oauthlib=0.4.2 \
      matplotlib=3.3.3 llvmlite=0.31.0 \
      -c conda-forge -y && conda clean --all --yes

SHELL ["conda","run","-n","diffsingerenv","/bin/bash","-lc"]

# (3) confirm your requirements
RUN head -n 20 /tmp/requirements.txt

# (4) strip out the C-exts + numpy
RUN sed -i '/^audioread==/d; /^grpcio==/d; \
           /^google-auth==/d; /^google-auth-oauthlib==/d; \
           /^h5py==/d; /^matplotlib==/d; /^llvmlite==/d; \
           /^numpy==/d' \
    /tmp/requirements.txt

# (5) install the rest (pure-Python only)
RUN pip install --no-build-isolation --no-deps -r /tmp/requirements.txt

# (5) install the rest
RUN pip install --no-build-isolation --no-deps -r /tmp/requirements.txt

# (6) copy code & entrypoint
WORKDIR /workspace
COPY . /workspace
ENTRYPOINT ["bash","-lc"]
