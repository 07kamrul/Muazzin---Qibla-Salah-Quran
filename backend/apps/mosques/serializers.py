from rest_framework import serializers

from .models import JamatSubmission, Mosque


class MosqueSerializer(serializers.ModelSerializer):
    latitude    = serializers.SerializerMethodField()
    longitude   = serializers.SerializerMethodField()
    distance_km = serializers.SerializerMethodField()

    class Meta:
        model  = Mosque
        fields = [
            'id', 'name_bn', 'name_en',
            'latitude', 'longitude',
            'district', 'upazila', 'division',
            'address_bn', 'address_en',
            'jamat_times', 'facilities',
            'verification_status',
            'distance_km',
        ]

    def get_latitude(self, obj):
        return obj.location.y

    def get_longitude(self, obj):
        return obj.location.x

    def get_distance_km(self, obj):
        # Annotated by view via PostGIS distance query
        dist = getattr(obj, 'distance', None)
        if dist is None:
            return None
        # dist is a Distance object (metres) from geodjango
        return round(dist.km, 3)


class MosqueCreateSerializer(serializers.Serializer):
    name_bn    = serializers.CharField(max_length=200)
    name_en    = serializers.CharField(max_length=200, required=False, allow_blank=True)
    latitude   = serializers.FloatField()
    longitude  = serializers.FloatField()
    district   = serializers.CharField(max_length=100)
    upazila    = serializers.CharField(max_length=100, required=False, allow_blank=True)
    division   = serializers.CharField(max_length=100, required=False, allow_blank=True)
    address_bn = serializers.CharField(required=False, allow_blank=True)
    address_en = serializers.CharField(required=False, allow_blank=True)
    facilities = serializers.DictField(child=serializers.BooleanField(), required=False)


class JamatUpdateSerializer(serializers.Serializer):
    fajr    = serializers.TimeField(required=False, allow_null=True)
    dhuhr   = serializers.TimeField(required=False, allow_null=True)
    asr     = serializers.TimeField(required=False, allow_null=True)
    maghrib = serializers.TimeField(required=False, allow_null=True)
    isha    = serializers.TimeField(required=False, allow_null=True)
    jumuah  = serializers.TimeField(required=False, allow_null=True)


class JamatSubmissionSerializer(serializers.ModelSerializer):
    class Meta:
        model  = JamatSubmission
        fields = ['id', 'mosque', 'times', 'status', 'created_at']
        read_only_fields = ['id', 'status', 'created_at']
