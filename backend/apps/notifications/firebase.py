"""Firebase Admin SDK initialisation (lazy, runs once on app startup)."""
import logging
import os

logger = logging.getLogger(__name__)

_initialized = False


def init_firebase():
    global _initialized
    if _initialized:
        return

    try:
        import firebase_admin
        from firebase_admin import credentials
        from django.conf import settings

        cred_path = settings.FIREBASE_SERVICE_ACCOUNT_JSON
        if os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
            _initialized = True
            logger.info('Firebase Admin SDK initialised.')
        else:
            logger.warning(
                'Firebase service account JSON not found at %s. '
                'FCM push notifications will be disabled.',
                cred_path,
            )
    except Exception as exc:  # pragma: no cover
        logger.error('Failed to initialise Firebase: %s', exc)


def send_fcm(token: str, title: str, body: str, data: dict | None = None) -> bool:
    """Send a single FCM message. Returns True on success."""
    try:
        import firebase_admin.messaging as fcm

        message = fcm.Message(
            notification=fcm.Notification(title=title, body=body),
            data={k: str(v) for k, v in (data or {}).items()},
            token=token,
            android=fcm.AndroidConfig(priority='high'),
            apns=fcm.APNSConfig(
                headers={'apns-priority': '10'},
                payload=fcm.APNSPayload(
                    aps=fcm.Aps(sound='default'),
                ),
            ),
        )
        fcm.send(message)
        return True
    except Exception as exc:
        logger.error('FCM send error: %s', exc)
        return False
