from django.urls import path
from .views import HadithDailyView, HadithDetailView, HadithListView

urlpatterns = [
    path('',        HadithListView.as_view(),  name='hadith-list'),
    path('daily/',  HadithDailyView.as_view(), name='hadith-daily'),
    path('<int:pk>/', HadithDetailView.as_view(), name='hadith-detail'),
]
