FROM python:3.10-slim-bullseye

WORKDIR /app
# Force the virtualenv path
ENV PATH="/app/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    git \
    libglib2.0-0 \
    # Added for potential C-extension compilation on armv7
    gcc \
    python3-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python -m venv /app/venv

# Install Python requirements
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy project code
COPY . .

# Ensure entrypoint is executable (if you have one)
# If you don't have entrypoint.sh, comment out the line below and change ENTRYPOINT to CMD
RUN chmod +x entrypoint.sh || true

EXPOSE 8000

# Using uvicorn to start the FastAPI app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
