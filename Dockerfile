FROM ghcr.io/saleor/saleor:3.20

WORKDIR /app

# Create admin script
RUN echo 'import os, django\n\
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "saleor.settings")\n\
django.setup()\n\
from django.contrib.auth import get_user_model\n\
User = get_user_model()\n\
email = os.getenv("ADMIN_EMAIL", "admin@varto.com")\n\
password = os.getenv("ADMIN_PASSWORD", "admin123")\n\
if not User.objects.filter(email=email).exists():\n\
    User.objects.create_superuser(email=email, password=password, is_staff=True, is_active=True)\n\
    print(f"✅ Admin created: {email}")\n\
else:\n\
    print(f"ℹ️ Admin exists: {email}")' > /app/create_admin.py

EXPOSE 8000

ENV PYTHONUNBUFFERED=1

# Start command
CMD ["sh", "-c", "\
    echo '=== Saleor Starting ===' && \
    python manage.py migrate --noinput && \
    echo '=== Creating Admin ===' && \
    python /app/create_admin.py && \
    echo '=== Starting Server ===' && \
    python manage.py runserver 0.0.0.0:8000\
"]
