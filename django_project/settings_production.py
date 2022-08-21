from settings import *
import os

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('DB_NAME','app'),
        'USER': os.environ.get('DB_USER','app'),
        'PASSWORD': os.environ.get('DB_PASSWORD','app'),
        'HOST': os.environ.get('DB_HOST', 'db'),
        'PORT': os.environ.get('DB_PORT', '5432')
        # 'OPTIONS': {
        #     # 'service': 'vkcs_service',
        #     # 'passfile': '.passfile',
        # }
    }
}
