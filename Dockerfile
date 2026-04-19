# ---------- Stage 1: Build libpostal ----------
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    autoconf \
    automake \
    libtool \
    pkg-config \
    build-essential \
    git \
    python3 \
    python3-pip

# Install libpostal
RUN git clone https://github.com/openvenues/libpostal.git

WORKDIR /libpostal

RUN ./bootstrap.sh && \
    ./configure --datadir=/libpostal_data && \
    make -j$(nproc) && \
    make install && \
    ldconfig

# ---------- Stage 2: Runtime ----------
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    libsnappy-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy libpostal
COPY --from=builder /usr/local /usr/local
COPY --from=builder /libpostal_data /libpostal_data

ENV LD_LIBRARY_PATH=/usr/local/lib
ENV LIBPOSTAL_DATA_DIR=/libpostal_data

# App setup
WORKDIR /app
COPY app /app

RUN pip3 install --no-cache-dir -r requirements.txt

# Run FastAPI
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
