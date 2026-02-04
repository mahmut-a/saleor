#!/bin/bash

# Migrations
python manage.py migrate --no-input

# Superuser oluştur (varsa hata vermez)
python manage.py shell <<EOF
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(email='admin@varto.com').exists():
    User.objects.create_superuser(
        email='admin@varto.com',
        password='${ADMIN_PASSWORD:-admin123}',
        is_staff=True,
        is_active=True
    )
    print('✅ Superuser created: admin@varto.com')
else:
    print('ℹ️ Superuser already exists')
EOF

# Populate sample data (opsiyonel)
python manage.py populatedb --createsuperuser || true

# Start server
exec gunicorn --bind 0.0.0.0:8000 --worker-tmp-dir /dev/shm saleor.wsgi:application
