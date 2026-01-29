FROM python:3.10-slim-bullseye

WORKDIR /app
ENV PATH="/app/venv/bin:$PATH"

# Debian slim 已经非常小，且 armv7 兼容性极佳
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg git libglib2.0-0 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN python -m venv /app/venv
COPY requirements.txt .
# Debian 的 armv7 wheel 非常全，通常不需要编译
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
ENTRYPOINT ["/entrypoint.sh"]
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
