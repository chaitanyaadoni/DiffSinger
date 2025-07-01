FROM continuumio/miniconda3:latest

# 1) Install system libs & curl
RUN apt-get update && \
    apt-get install -y \
      build-essential \
      libsndfile1 \
      libsndfile-dev \
      libhdf5-dev \
      libffi-dev \
      libssl-dev \
      ffmpeg \
      curl && \
    rm -rf /var/lib/apt/lists/*

# 2) Copy requirements early for caching
COPY requirements_2080.txt /tmp/requirements.txt

 # 3) Create conda env & install heavy deps via conda-forge
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
        -c conda-forge -y && \
      conda clean --all --yes
 
  # 4) Switch into that env
 SHELL ["conda","run","-n","diffsingerenv","/bin/bash","-lc"]
 

# 5) Upgrade pip tools
RUN pip install --upgrade pip setuptools wheel

# 6) Install remaining deps
RUN pip install --no-deps -r /tmp/requirements.txt

# 7) Copy the code & set workdir
WORKDIR /workspace
COPY . /workspace

ENTRYPOINT ["bash", "-lc"]
