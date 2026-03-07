# 🕌 Muazzin — Qibla, Salah, Quran

> Mosque & Prayer Time · Qibla Direction · Nearest Namaz Spot Finder
> **Business Requirements v1.0 | Designed for Bangladesh**

---

## Overview

Muazzin is a mobile-first Islamic utility application built for Muslim users in Bangladesh. It combines:

- **Prayer Times** — Hanafi/Karachi method, accurate to BD coordinates
- **Qibla Direction** — Animated compass with WMM magnetic declination correction
- **Nearest Mosque** — PostGIS radius search with crowd-sourced Jamat times
- **Azan Notifications** — Per-prayer toggles, pre-prayer alerts, DND bypass
- **Quran Reader** — Arabic + Bangla + English, fully offline
- **Daily Hadith** — 365 curated authentic Hadiths, 8 AM notification
- **Ramadan Module** — Sehri/Iftar alerts, 30-day calendar, Laylatul Qadr highlights
- **Offline-First** — Core features work without internet after first load

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter (Android + iOS) |
| Backend | Django 4.2 + Django REST Framework |
| Database | PostgreSQL + PostGIS |
| Prayer Calculation | adhan-dart (Hanafi/Karachi, local — zero API cost) |
| Maps | OpenStreetMap + flutter_map (free, no API key) |
| Push Notifications | Firebase Cloud Messaging (FCM) free tier |
| Offline Storage | SQLite via sqflite + SharedPreferences |
| Auth | Email + OTP via django-allauth + simplejwt (guest mode default) |
| Async Tasks | Celery + Redis |
| CDN | Cloudflare free tier |
| Reverse Geocoding | Nominatim (OpenStreetMap, free) |
| Mosque Data | OpenStreetMap Overpass API (free) |
| Hijri Date | hijri Flutter package |
| Magnetic Declination | NOAA WMM2025 bundled coefficients |

---

## Project Structure

```
Muazzin - Qibla, Salah, Quran/
├── mobile/                   # Flutter app (Android + iOS)
│   ├── lib/
│   │   ├── core/             # Constants, theme, utils, extensions
│   │   ├── data/             # Models, repositories, datasources
│   │   ├── domain/           # Services (prayer, qibla, location, notifications)
│   │   ├── presentation/     # Screens, providers (Riverpod), widgets
│   │   └── l10n/             # ARB localization files (bn + en)
│   ├── assets/
│   │   ├── hadith/           # hadiths.json (365 bundled hadiths)
│   │   ├── audio/            # Bundled Azan audio (Mishary Rashid)
│   │   └── fonts/            # NotoSansBengali, AmiriQuran
│   └── pubspec.yaml
└── backend/                  # Django + DRF API
    ├── apps/
    │   ├── prayer_times/     # Prayer calculation & district caching
    │   ├── mosques/          # PostGIS mosque database + Jamat crowd-sourcing
    │   ├── hadith/           # 365-hadith database + daily rotation
    │   ├── quran/            # 114 Surahs + Ayahs (Arabic/Bangla/English)
    │   ├── users/            # Custom User model + Email OTP auth
    │   └── notifications/    # FCM push notifications + Celery tasks
    ├── muazzin/              # Django project settings
    ├── docker-compose.yml
    ├── Dockerfile
    └── requirements.txt
```

---

## Getting Started

### Mobile (Flutter)

```bash
cd mobile
flutter pub get
flutter run
```

**Required:** Flutter SDK ≥ 3.2.0, Dart ≥ 3.2.0

Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from Firebase Console to enable FCM.

### Backend (Django)

**With Docker (recommended):**
```bash
cd backend
cp .env.example .env
# Edit .env with your credentials
docker-compose up --build
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py createsuperuser
```

**Without Docker:**
```bash
cd backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# Edit .env
python manage.py migrate
python manage.py runserver
```

---

## Prayer Calculation — Hanafi/Karachi Method

| Parameter | Value |
|---|---|
| Fajr Angle | 18° below horizon |
| Isha Angle | 18° below horizon |
| Madhab | Hanafi — Asr at shadow = 2× object height |
| Timezone | Asia/Dhaka (UTC+6, no DST) |
| Library | adhan-dart (Flutter) / astral (Django) |

Additional times: **Tahajjud** (last ⅓ of night), **Ishraq** (Shuruq + 20 min), **Duha** (Shuruq + 45 min)

---

## Development Roadmap

| Phase | Deliverables | Timeline |
|---|---|---|
| Phase 1 (MVP) | Prayer times, Qibla, location, Azan notifications, Daily Hadith, offline | Month 1–2 |
| Phase 2 | Mosque map, Jamat times, Quran reader (Arabic + Bangla + English) | Month 3–4 |
| Phase 3 | Ramadan calendar, Sehri/Iftar alerts, Eid prediction, shareable graphics | Month 4 |
| Phase 4 | User accounts, Jamat submissions, mosque corrections, badges, admin | Month 5–6 |
| Phase 5 | AR Qibla, extra Azan packs, PDF calendar, widgets, Apple Watch | Month 7+ |

---

## Monetization

- **Free:** All Islamic utility features permanently free (prayer times, Qibla, mosque, Ramadan, Quran)
- **Muazzin Pro:** BDT 99/month or BDT 499/year — extra Azan packs, widgets, AR Qibla, PDF calendar, Apple Watch
- **Ads (free tier only):** Mosque directory list only · halal categories only · zero ads during Ramadan prayer times

---

## API Endpoints

| Endpoint | Method | Description |
|---|---|---|
| `/api/v1/prayer-times/` | GET | Prayer times by lat/lng/date/days |
| `/api/v1/mosques/` | GET | Nearby mosques by lat/lng/radius |
| `/api/v1/mosques/{id}/jamat-submissions/` | POST | Submit Jamat time (rate-limited) |
| `/api/v1/hadith/` | GET | Hadith list |
| `/api/v1/hadith/daily/` | GET | Today's daily Hadith |
| `/api/v1/quran/` | GET | All 114 Surahs (metadata) |
| `/api/v1/quran/{id}/` | GET | Surah detail with all Ayahs |
| `/api/v1/quran/search/` | GET | Full-text search |
| `/api/v1/users/send-otp/` | POST | Send OTP to email |
| `/api/v1/users/verify-otp/` | POST | Verify OTP → JWT tokens |
| `/api/v1/users/me/` | GET/PATCH | Authenticated user profile |
| `/api/v1/notifications/register/` | POST | Register FCM device token |
| `/api/v1/auth/token/refresh/` | POST | Refresh JWT access token |

---

## Offline Support

| Feature | Storage | Size |
|---|---|---|
| Prayer times (30 days) | SQLite | ~2 MB |
| Mosque list (district, 7 days) | SQLite | ~1 MB |
| 365 Hadiths | JSON asset + SQLite | ~500 KB |
| Azan audio (3 variants) | App bundle | ~8 MB |
| Map tiles (district) | flutter_map cache | ~50 MB max |
| Quran text (all 3 languages) | App bundle | ~15 MB |

**Target:** < 30 MB initial install · < 80 MB after full local district data

---

*"And establish prayer and give zakah and bow with those who bow [in worship and obedience]." — Quran 2:43*
