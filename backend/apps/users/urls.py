"""Auth routes: /api/v1/auth/..."""
from django.urls import path
from .views import OTPRequestView, OTPVerifyView

urlpatterns = [
    path('otp/',        OTPRequestView.as_view(), name='otp-request'),
    path('otp/verify/', OTPVerifyView.as_view(),  name='otp-verify'),
]
