# 第一阶段：编译阶段 (Builder)
FROM python:3.10-alpine AS builder

WORKDIR /app

# 安装编译依赖
RUN apk add --no-cache \
    gcc \
    g++ \
    musl-dev \
    python3-dev \
    libffi-dev \
    linux-headers

# 创建虚拟环境并安装依赖
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# 第二阶段：运行阶段 (Final)
FROM python:3.10-alpine

WORKDIR /app

# 只安装运行时必需的库 (FFmpeg)
RUN apk add --no-cache ffmpeg libstdc++

# 从编译阶段拷贝安装好的 Python 环境
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# 拷贝项目代码
COPY . .

EXPOSE 18000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "18000"]
