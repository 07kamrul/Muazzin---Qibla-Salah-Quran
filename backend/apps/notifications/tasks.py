"""Celery tasks for push notifications."""
import logging

from celery import shared_task

from .firebase import send_fcm
from .models import DeviceToken

logger = logging.getLogger(__name__)


@shared_task(bind=True, max_retries=3, default_retry_delay=30)
def send_prayer_notification(self, prayer_name: str, prayer_time: str, user_id=None):
    """Send prayer notification to all registered devices (or a specific user)."""
    qs = DeviceToken.objects.all()
    if user_id:
        qs = qs.filter(user_id=user_id)

    title = f"🕌 {prayer_name} Prayer"
    body  = f"It's time for {prayer_name} prayer — {prayer_time}"

    sent = 0
    for device in qs:
        success = send_fcm(
            token=device.fcm_token,
            title=title,
            body=body,
            data={'prayer': prayer_name, 'time': prayer_time},
        )
        if success:
            sent += 1

    logger.info('Prayer notification sent to %d devices', sent)
    return sent


@shared_task(bind=True, max_retries=3, default_retry_delay=30)
def send_daily_hadith_notification(self, hadith_text: str):
    """Send daily Hadith notification at 8 AM to all registered devices."""
    title = "📖 Hadith of the Day"
    body  = hadith_text[:200]  # FCM body limit

    sent = 0
    for device in DeviceToken.objects.all():
        success = send_fcm(token=device.fcm_token, title=title, body=body)
        if success:
            sent += 1

    logger.info('Daily Hadith notification sent to %d devices', sent)
    return sent
