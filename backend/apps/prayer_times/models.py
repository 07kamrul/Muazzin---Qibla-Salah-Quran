from django.db import models


class PrayerTimeCache(models.Model):
    """Cached prayer times keyed on rounded coordinates + date."""

    # Round to 2 decimal places (~1.1 km grid) to maximise cache hits
    lat_key  = models.DecimalField(max_digits=7,  decimal_places=2)
    lng_key  = models.DecimalField(max_digits=8,  decimal_places=2)
    date     = models.DateField()

    fajr     = models.DateTimeField()
    shuruq   = models.DateTimeField()
    dhuhr    = models.DateTimeField()
    asr      = models.DateTimeField()
    maghrib  = models.DateTimeField()
    isha     = models.DateTimeField()
    tahajjud = models.DateTimeField()
    ishraq   = models.DateTimeField()
    duha     = models.DateTimeField()

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table        = 'prayer_time_cache'
        unique_together = ('lat_key', 'lng_key', 'date')
        ordering        = ['date']
        indexes         = [
            models.Index(fields=['lat_key', 'lng_key', 'date']),
        ]

    def __str__(self):
        return f'PrayerCache({self.lat_key},{self.lng_key},{self.date})'
