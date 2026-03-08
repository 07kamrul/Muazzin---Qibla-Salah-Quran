from rest_framework import serializers
from .models import PrayerTimeCache


class PrayerTimesSerializer(serializers.Serializer):
    """Serializes a dict returned by the calculator (not a model)."""
    date     = serializers.DateField()
    fajr     = serializers.DateTimeField()
    shuruq   = serializers.DateTimeField()
    dhuhr    = serializers.DateTimeField()
    asr      = serializers.DateTimeField()
    maghrib  = serializers.DateTimeField()
    isha     = serializers.DateTimeField()
    tahajjud = serializers.DateTimeField()
    ishraq   = serializers.DateTimeField()
    duha     = serializers.DateTimeField()
