# 使用轻量级 Alpine 作为基础镜像
FROM python:3.10-alpine

# 设置环境变量
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/app/venv/bin:$PATH"

# 设置工作目录
WORKDIR /app

# 一次性安装系统依赖、编译环境并清理缓存
# alpine 使用 apk 管理包，ffmpeg 包含在社区仓库中
RUN apk add --no-cache \
    ffmpeg \
    git \
    libstdc++ \
    glib \
    # 编译依赖（安装完后会删除以缩小体积）
    && apk add --no-cache --virtual .build-deps \
    gcc \
    musl-dev \
    python3-dev \
    linux-headers \
    # 创建虚拟环境以隔离依赖
    && python -m venv /app/venv \
    && pip install --no-cache-dir --upgrade pip

# 复制依赖文件
COPY requirements.txt .

# 安装 Python 依赖并移除编译工具
RUN pip install --no-cache-dir -r requirements.txt \
    && apk del .build-deps

# 复制项目代码
COPY . .

# 复制并设置入口脚本
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8000
VOLUME ["/data"]

ENTRYPOINT ["/entrypoint.sh"]

# 使用 venv 中的 uvicorn 启动
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
