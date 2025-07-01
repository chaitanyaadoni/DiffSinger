# Dockerfile

FROM continuumio/miniconda3:latest

# 1) Install system libraries & curl
RUN apt-get update && \
    apt-get install -y \
      build-essential \
      libsndfile1 \
      ffmpeg \
      curl && \
    rm -rf /var/lib/apt/lists/*

# 2) Copy requirements for layer caching
COPY requirements_2080.txt /tmp/requirements.txt

# 3) Create conda env with python, core deps & audioread from conda-forge
RUN conda create -n diffsingerenv \
      python=3.8 \
      numpy \
      cython \
      pip \
      -y && \
    # Install audioread via conda-forge to avoid pip build errors
    conda install -n diffsingerenv -c conda-forge audioread -y && \
    conda clean --all --yes

# 4) Switch to that environment
SHELL ["conda", "run", "-n", "diffsingerenv", "/bin/bash", "-lc"]

# 5) Upgrade pip tooling
RUN pip install --upgrade pip setuptools wheel

# 6) Install the rest of your Python deps (excluding audioread)
#    --no-deps ensures pip won't try to rebuild audioread
RUN pip install --no-deps -r /tmp/requirements.txt

# 7) Copy in your code & set the working directory
WORKDIR /workspace
COPY . /workspace

ENTRYPOINT ["bash", "-lc"]
