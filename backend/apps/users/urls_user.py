"""User profile routes: /api/v1/users/..."""
from django.urls import path
from .views import UserMeView

urlpatterns = [
    path('me/', UserMeView.as_view(), name='user-me'),
]
