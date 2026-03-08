from django.urls import path
from .views import PrayerTimesView

urlpatterns = [
    path('', PrayerTimesView.as_view(), name='prayer-times'),
]
