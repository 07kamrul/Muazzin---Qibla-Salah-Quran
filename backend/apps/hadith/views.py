from datetime import date

from rest_framework.generics import ListAPIView, RetrieveAPIView
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Hadith
from .serializers import HadithSerializer


class HadithListView(ListAPIView):
    """GET /api/v1/hadiths/ — All 365 hadiths."""
    queryset         = Hadith.objects.all()
    serializer_class = HadithSerializer
    pagination_class = None  # Return all 365 at once for offline sync


class HadithDailyView(APIView):
    """GET /api/v1/hadiths/daily/ — Today's Hadith by day-of-year."""

    def get(self, request):
        today      = date.today()
        day_of_year = today.timetuple().tm_yday  # 1–365

        try:
            hadith = Hadith.objects.get(day_of_year=day_of_year)
        except Hadith.DoesNotExist:
            # Wrap around (e.g. leap year day 366 → day 1)
            hadith = Hadith.objects.order_by('day_of_year').first()
            if not hadith:
                return Response({'detail': 'No hadiths in database.'}, status=404)

        return Response(HadithSerializer(hadith).data)


class HadithDetailView(RetrieveAPIView):
    """GET /api/v1/hadiths/{id}/ — Single hadith."""
    queryset         = Hadith.objects.all()
    serializer_class = HadithSerializer
