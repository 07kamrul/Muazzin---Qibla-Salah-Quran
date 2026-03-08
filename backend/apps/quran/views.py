from django.db.models import Q
from rest_framework.generics import ListAPIView, RetrieveAPIView
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Ayah, Surah
from .serializers import AyahSerializer, SurahDetailSerializer, SurahListSerializer


class SurahListView(ListAPIView):
    """GET /api/v1/quran/surahs/ — All 114 Surahs (metadata only)."""
    queryset         = Surah.objects.all()
    serializer_class = SurahListSerializer
    pagination_class = None  # Return all 114 at once


class SurahDetailView(RetrieveAPIView):
    """GET /api/v1/quran/surahs/{number}/ — Surah with all Ayahs."""
    queryset         = Surah.objects.prefetch_related('ayahs').all()
    serializer_class = SurahDetailSerializer
    lookup_field     = 'number'


class QuranSearchView(APIView):
    """GET /api/v1/quran/search/?q= — Full-text search across Ayahs."""

    def get(self, request):
        query = request.query_params.get('q', '').strip()

        if len(query) < 2:
            return Response(
                {'detail': 'Search query must be at least 2 characters.'},
                status=400,
            )

        ayahs = Ayah.objects.filter(
            Q(arabic_text__icontains=query)
            | Q(bangla_translation__icontains=query)
            | Q(english_translation__icontains=query)
        ).select_related('surah')[:50]

        return Response({'results': AyahSerializer(ayahs, many=True).data})
