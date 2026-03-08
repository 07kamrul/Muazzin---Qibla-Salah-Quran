from django.contrib import admin
from django.urls import include, path
from rest_framework_simplejwt.views import TokenRefreshView

urlpatterns = [
    path('admin/', admin.site.urls),

    # JWT token refresh
    path('api/v1/auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    # App routes
    path('api/v1/auth/', include('apps.users.urls')),
    path('api/v1/users/', include('apps.users.urls_user')),
    path('api/v1/notifications/', include('apps.notifications.urls')),
    path('api/v1/mosques/', include('apps.mosques.urls')),
    path('api/v1/hadiths/', include('apps.hadith.urls')),
    path('api/v1/quran/', include('apps.quran.urls')),
    path('api/v1/prayer-times/', include('apps.prayer_times.urls')),
]
