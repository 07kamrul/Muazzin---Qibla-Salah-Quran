from django.contrib import admin
from .models import PrayerTimeCache


@admin.register(PrayerTimeCache)
class PrayerTimeCacheAdmin(admin.ModelAdmin):
    list_display  = ['lat_key', 'lng_key', 'date', 'fajr', 'dhuhr', 'maghrib', 'isha']
    list_filter   = ['date']
    search_fields = ['lat_key', 'lng_key']
    ordering      = ['-date', 'lat_key', 'lng_key']
    readonly_fields = ['created_at']
