FROM continuumio/miniconda3:latest

# 1) Install system libs & curl
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
      matplotlib=3.3.3 \
      llvmlite=0.31.0 \
      -c conda-forge -y && \
    conda clean --all --yes


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

# 6) Install the remaining Python deps (all others)
RUN pip install --no-deps -r /tmp/requirements.txt

# 7) Copy the code & set workdir
WORKDIR /workspace
COPY . /workspace

ENTRYPOINT ["bash", "-lc"]
