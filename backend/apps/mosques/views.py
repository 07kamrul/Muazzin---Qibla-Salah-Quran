from django.contrib.gis.geos import Point
from django.contrib.gis.db.models.functions import Distance
from django.contrib.gis.measure import D
from rest_framework import status
from rest_framework.response import Response
from rest_framework.throttling import ScopedRateThrottle
from rest_framework.views import APIView

from .models import JamatSubmission, Mosque
from .serializers import (
    JamatSubmissionSerializer,
    JamatUpdateSerializer,
    MosqueCreateSerializer,
    MosqueSerializer,
)


class MosqueListCreateView(APIView):
    """
    GET  /api/v1/mosques/?lat=&lng=&radius=  — Nearby mosques
    POST /api/v1/mosques/                    — Submit new mosque (auth required)
    """

    def get(self, request):
        lat    = request.query_params.get('lat')
        lng    = request.query_params.get('lng')
        radius = request.query_params.get('radius', 3)  # km

        if not lat or not lng:
            return Response(
                {'detail': 'lat and lng query parameters are required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            lat    = float(lat)
            lng    = float(lng)
            radius = float(radius)
        except ValueError:
            return Response(
                {'detail': 'lat, lng, and radius must be numeric.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        user_location = Point(lng, lat, srid=4326)

        mosques = (
            Mosque.objects
            .filter(location__distance_lte=(user_location, D(km=radius)))
            .annotate(distance=Distance('location', user_location))
            .order_by('distance')
        )

        # Auto-expand if fewer than 3 results
        if mosques.count() < 3 and radius < 10:
            mosques = (
                Mosque.objects
                .filter(location__distance_lte=(user_location, D(km=10)))
                .annotate(distance=Distance('location', user_location))
                .order_by('distance')
            )

        serializer = MosqueSerializer(mosques, many=True)
        return Response({'results': serializer.data})

    def post(self, request):
        if not request.user.is_authenticated:
            return Response(
                {'detail': 'Authentication required to submit a mosque.'},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        serializer = MosqueCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        d = serializer.validated_data

        mosque = Mosque.objects.create(
            name_bn             = d['name_bn'],
            name_en             = d.get('name_en', ''),
            location            = Point(d['longitude'], d['latitude'], srid=4326),
            district            = d['district'],
            upazila             = d.get('upazila', ''),
            division            = d.get('division', ''),
            address_bn          = d.get('address_bn', ''),
            address_en          = d.get('address_en', ''),
            facilities          = d.get('facilities', {}),
            verification_status = 'community',
            submitted_by        = request.user,
        )

        return Response(
            MosqueSerializer(mosque).data,
            status=status.HTTP_201_CREATED,
        )


class JamatUpdateView(APIView):
    """
    PATCH /api/v1/mosques/{pk}/jamat/ — Update jamat times for a mosque.
    Rate-limited; creates a JamatSubmission record.
    """

    throttle_classes = [ScopedRateThrottle]
    throttle_scope   = 'jamat_submit'

    def patch(self, request, pk):
        try:
            mosque = Mosque.objects.get(pk=pk)
        except Mosque.DoesNotExist:
            return Response(
                {'detail': 'Mosque not found.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        serializer = JamatUpdateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        times = {
            k: str(v) if v else None
            for k, v in serializer.validated_data.items()
        }

        # Record submission for moderation
        JamatSubmission.objects.create(
            mosque       = mosque,
            submitted_by = request.user if request.user.is_authenticated else None,
            times        = times,
        )

        # For community mosques apply immediately; verified mosques need moderation
        if mosque.verification_status != 'verified':
            mosque.jamat_times = {**mosque.jamat_times, **{k: v for k, v in times.items() if v}}
            mosque.save(update_fields=['jamat_times', 'updated_at'])

        return Response({'detail': 'Jamat times submitted.'}, status=status.HTTP_200_OK)
