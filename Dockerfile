FROM continuumio/miniconda3:latest

# 1) System deps
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

# 3) Create conda env & pre-install heavy C-extensions + pandas
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
      pandas=1.2.0 \
      -c conda-forge -y && \
    conda clean --all --yes

# 4) Use the new env
SHELL ["conda","run","-n","diffsingerenv","/bin/bash","-lc"]

# 5) Debug: peek at pip list
RUN head -n20 /tmp/requirements.txt

# 6) Strip out all conda-provided packages (incl. pandas)
RUN sed -i '\
  /^audioread==/d; \
  /^h5py==/d; \
  /^grpcio==/d; \
  /^google-auth==/d; \
  /^google-auth-oauthlib==/d; \
  /^matplotlib==/d; \
  /^llvmlite==/d; \
  /^numpy==/d; \
  /^pandas==/d' \
  /tmp/requirements.txt

# 7) Pip-install the remainder (pure-Python only)
RUN pip install --no-build-isolation --no-deps -r /tmp/requirements.txt

# 8) Copy code & set workdir
WORKDIR /workspace
COPY . /workspace

# 9) Default entrypoint
ENTRYPOINT ["bash","-lc"]
