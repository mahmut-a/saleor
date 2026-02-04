FROM ghcr.io/saleor/saleor:3.20

WORKDIR /app

# Admin user script (is_staff ve is_active kaldırıldı)
RUN echo 'import os, django\n\
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "saleor.settings")\n\
django.setup()\n\
from django.contrib.auth import get_user_model\n\
User = get_user_model()\n\
email = os.getenv("ADMIN_EMAIL", "admin@varto.com")\n\
password = os.getenv("ADMIN_PASSWORD", "admin123")\n\
if not User.objects.filter(email=email).exists():\n\
    User.objects.create_superuser(email=email, password=password)\n\
    print(f"✅ Admin created: {email}")\n\
else:\n\
    print(f"ℹ️ Admin exists: {email}")' > /app/create_admin.py

EXPOSE 8000

ENV PYTHONUNBUFFERED=1

CMD ["sh", "-c", "\
    echo '🚂 Railway Deployment' && \
    echo 'Running migrations...' && \
    python manage.py migrate --noinput && \
    echo 'Creating admin user...' && \
    python /app/create_admin.py && \
    echo 'Starting server on port 8000...' && \
    python manage.py runserver 0.0.0.0:8000"]
