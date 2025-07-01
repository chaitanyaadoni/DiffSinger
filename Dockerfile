# Dockerfile

FROM continuumio/miniconda3:latest

# Install system libs & curl
RUN apt-get update && \
    apt-get install -y build-essential libsndfile1 ffmpeg curl && \
    rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements_2080.txt /tmp/

# Create conda env with pre-installed NumPy/Cython/pip
RUN conda create -n diffsingerenv python=3.8 numpy cython pip -y && \
    conda clean --all --yes

# Switch to that env for all subsequent RUNs
SHELL ["conda", "run", "-n", "diffsingerenv", "/bin/bash", "-lc"]

# Install the rest of your Python deps
RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-build-isolation -r /tmp/requirements_2080.txt

# Copy code
WORKDIR /workspace
COPY . /workspace

ENTRYPOINT ["bash", "-lc"]


