from django.urls import path
from .views import QuranSearchView, SurahDetailView, SurahListView

urlpatterns = [
    path('surahs/',                SurahListView.as_view(),   name='surah-list'),
    path('surahs/<int:number>/',   SurahDetailView.as_view(), name='surah-detail'),
    path('search/',                QuranSearchView.as_view(), name='quran-search'),
]
