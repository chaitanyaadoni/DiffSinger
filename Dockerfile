# Dockerfile

FROM continuumio/miniconda3:latest

# 1) Install system libs & curl
RUN apt-get update && \
    apt-get install -y \
      build-essential \
      libsndfile1 \
      ffmpeg \
      curl && \
    rm -rf /var/lib/apt/lists/*

# 2) Copy just requirements so we get layer caching
COPY requirements_2080.txt /tmp/requirements.txt

# 3) Create conda env with Python + core deps
RUN conda create -n diffsingerenv python=3.8 numpy cython pip -y && \
    conda clean --all --yes

# 4) Switch into that environment
SHELL ["conda", "run", "-n", "diffsingerenv", "/bin/bash", "-lc"]

# 5) Upgrade pip/setuptools/wheel
RUN pip install --upgrade pip setuptools wheel

# 6) Install the rest of your Python deps (with build isolation enabled)
RUN pip install -r /tmp/requirements.txt

# 7) Copy your code & set working dir
WORKDIR /workspace
COPY . /workspace

ENTRYPOINT ["bash", "-lc"]
