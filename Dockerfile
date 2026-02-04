FROM python:3.11-slim

# System dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Saleor dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy Saleor code
COPY . .

# Collect static files
RUN SECRET_KEY=build-time python manage.py collectstatic --no-input

# Port
EXPOSE 8000

# Start command
CMD python manage.py migrate && \
    python manage.py runserver 0.0.0.0:8000
