from django.conf import settings
from django.db import models


class DeviceToken(models.Model):
    PLATFORM_CHOICES = [('android', 'Android'), ('ios', 'iOS')]

    user      = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='device_tokens',
        null=True,
        blank=True,  # allow guest (unauthenticated) device registration
    )
    fcm_token  = models.TextField(unique=True)
    platform   = models.CharField(max_length=10, choices=PLATFORM_CHOICES, default='android')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'device_tokens'
        ordering = ['-updated_at']

    def __str__(self):
        return f'{self.platform} token for {self.user or "guest"}'
