from django.urls import path
from .views import JamatUpdateView, MosqueListCreateView

urlpatterns = [
    path('',            MosqueListCreateView.as_view(), name='mosque-list-create'),
    path('<uuid:pk>/jamat/', JamatUpdateView.as_view(),  name='jamat-update'),
]
