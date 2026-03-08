from django.urls import path
from .views import RegisterDeviceTokenView

urlpatterns = [
    path('register/', RegisterDeviceTokenView.as_view(), name='notification-register'),
]
