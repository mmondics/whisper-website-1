FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04

# Install Python 3.9, pip, and ffmpeg
RUN apt-get update && \
    apt-get install -y python3.9 python3-pip ffmpeg && \
    ln -sf python3.9 /usr/bin/python && \
    ln -sf pip3 /usr/bin/pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install uv tool (pip wrapper)
RUN pip install uv

COPY requirements.txt /app
COPY src/ /app

# Install Torch + audio
RUN pip install torch==1.13.1+cu117 \
    torchvision==0.14.1+cu117 \
    torchaudio==0.13.1+cu117 \
    -f https://download.pytorch.org/whl/torch_stable.html

# Install other dependencies
RUN uv pip install --system -r requirements.txt

CMD bash -c 'CUDA_SO=$(find /usr/lib/wsl/drivers -name libcuda.so.1 | head -n1) && \
             ln -sf "$CUDA_SO" /usr/lib/x86_64-linux-gnu/libcuda.so && \
             ldconfig && \
             exec uvicorn main:app --host 0.0.0.0 --port 80'