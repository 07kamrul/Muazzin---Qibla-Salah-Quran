import uuid

from django.conf import settings
from django.contrib.gis.db import models as gis_models
from django.db import models


class Mosque(models.Model):
    VERIFICATION_CHOICES = [
        ('verified',   'Verified'),
        ('community',  'Community'),
        ('unverified', 'Unverified'),
    ]

    id                  = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name_bn             = models.CharField(max_length=200)
    name_en             = models.CharField(max_length=200, blank=True)

    # PostGIS geometry point (longitude, latitude)
    location            = gis_models.PointField(geography=True, spatial_index=True)

    district            = models.CharField(max_length=100)
    upazila             = models.CharField(max_length=100, blank=True)
    division            = models.CharField(max_length=100, blank=True)
    address_bn          = models.TextField(blank=True)
    address_en          = models.TextField(blank=True)

    # Jamat times stored as JSON: {fajr, dhuhr, asr, maghrib, isha, jumuah}
    jamat_times         = models.JSONField(default=dict, blank=True)

    # Facilities stored as JSON: {womens_section, wudu, ac, parking, wheelchair}
    facilities          = models.JSONField(default=dict, blank=True)

    verification_status = models.CharField(
        max_length=20,
        choices=VERIFICATION_CHOICES,
        default='unverified',
    )

    submitted_by        = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='submitted_mosques',
    )

    osm_id              = models.CharField(max_length=50, blank=True, unique=True, null=True)

    created_at          = models.DateTimeField(auto_now_add=True)
    updated_at          = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'mosques'
        ordering = ['name_bn']

    @property
    def latitude(self):
        return self.location.y

    @property
    def longitude(self):
        return self.location.x

    def __str__(self):
        return self.name_bn


class JamatSubmission(models.Model):
    STATUS_CHOICES = [
        ('pending',  'Pending'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
    ]

    mosque       = models.ForeignKey(
        Mosque,
        on_delete=models.CASCADE,
        related_name='jamat_submissions',
    )
    submitted_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
    )
    times        = models.JSONField()  # {fajr, dhuhr, asr, maghrib, isha, jumuah}
    status       = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    created_at   = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'jamat_submissions'
        ordering = ['-created_at']

    def __str__(self):
        return f'Jamat submission for {self.mosque} ({self.status})'
