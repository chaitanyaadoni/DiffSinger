# Use Miniconda (includes conda, Python)
FROM continuumio/miniconda3:latest

# Install system libraries & gsutil
RUN apt-get update && \
    apt-get install -y build-essential libsndfile1 ffmpeg google-cloud-cli && \
    rm -rf /var/lib/apt/lists/*

# Copy only requirements first to cache layers
COPY requirements_2080.txt /tmp/

# Create conda env with pre-installed NumPy/Cython/Pip
RUN conda create -n diffsingerenv python=3.8 numpy cython pip -y && \
    conda clean --all --yes

# Activate env and install rest of Python deps
SHELL ["conda", "run", "-n", "diffsingerenv", "/bin/bash", "-lc"]
RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-build-isolation -r /tmp/requirements_2080.txt

# Copy the rest of your code
WORKDIR /workspace
COPY . /workspace

# Default entrypoint does nothing; we’ll override in CI
ENTRYPOINT ["bash", "-lc"]

