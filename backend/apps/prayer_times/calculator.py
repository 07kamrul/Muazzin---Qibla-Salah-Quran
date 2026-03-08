"""
Hanafi/Karachi prayer time calculator using ephem.

Method parameters (Muslim World League / Karachi):
  - Fajr:  18° below horizon
  - Isha:  18° below horizon
  - Asr:   shadow = 2× object height  (Hanafi)
  - Dhuhr: Sun transit + 1 min
  - Maghrib: Sunset

Extra times:
  - Tahajjud: last 1/3 of the night (between Isha and next Fajr)
  - Ishraq:   Sunrise + 20 min
  - Duha:     Sunrise + 45 min

All times are returned as timezone-aware datetime in Asia/Dhaka (UTC+6).
"""

import math
from datetime import datetime, timedelta, timezone

import ephem

# UTC+6 fixed offset — Bangladesh has no DST
BD_TZ = timezone(timedelta(hours=6))

FAJR_ANGLE  = 18.0  # degrees below horizon
ISHA_ANGLE  = 18.0  # degrees below horizon


def _to_local(ephem_date) -> datetime:
    """Convert ephem UTC date to Asia/Dhaka aware datetime."""
    utc_dt = ephem.Date(ephem_date).datetime()
    return utc_dt.replace(tzinfo=timezone.utc).astimezone(BD_TZ)


def _angle_to_horizon(angle_deg: float) -> float:
    """
    Return the ephem horizon string for a given angle below the horizon.
    ephem uses '-0:XX:XX' format where negative = below.
    """
    deg  = int(angle_deg)
    frac = angle_deg - deg
    mins = int(frac * 60)
    secs = int((frac * 60 - mins) * 60)
    return f'-{deg}:{mins:02d}:{secs:02d}'


def _hanafi_asr(observer: ephem.Observer, date: ephem.Date) -> datetime:
    """
    Calculate Hanafi Asr (shadow = 2× object height).

    The shadow length s = 2×h where h is the object height.
    The altitude when shadow = n×h is:  alt = arctan(1 / (n + tan(|lat - dec|)))
    We iteratively solve for the time when the Sun reaches this altitude
    on its way down (afternoon).
    """
    observer.date = date
    sun = ephem.Sun(observer)

    lat_rad = float(observer.lat)
    dec_rad = float(sun.dec)

    shadow_multiple = 2.0  # Hanafi

    altitude = math.degrees(
        math.atan(1.0 / (shadow_multiple + abs(math.tan(lat_rad - dec_rad))))
    )

    # Search from midday forward (sun descending)
    midday = ephem.Date(observer.next_transit(ephem.Sun()))
    observer.date = midday

    # Iterate 15-minute steps until the sun drops to our altitude
    step = ephem.minute * 15
    while True:
        observer.date += step
        sun.compute(observer)
        sun_alt_deg = math.degrees(float(sun.alt))
        if sun_alt_deg <= altitude:
            # Linear interpolation between previous and current step
            observer.date -= step
            sun.compute(observer)
            prev_alt = math.degrees(float(sun.alt))
            frac = (prev_alt - altitude) / (prev_alt - sun_alt_deg)
            observer.date += step * frac
            return _to_local(observer.date)

        if sun_alt_deg < -5:
            # Safety: sun already below horizon — should not happen
            break

    # Fallback: one step estimate
    return _to_local(observer.date)


def calculate(lat: float, lng: float, date: datetime) -> dict:
    """
    Calculate all prayer times for a given location and date.

    Args:
        lat:  Latitude  (degrees, +N)
        lng:  Longitude (degrees, +E)
        date: Date (any timezone; only the date part is used)

    Returns:
        dict with ISO-8601 strings in Asia/Dhaka timezone:
        {date, fajr, shuruq, dhuhr, asr, maghrib, isha,
         tahajjud, ishraq, duha}
    """
    obs          = ephem.Observer()
    obs.lat      = str(lat)
    obs.lon      = str(lng)
    obs.elevation = 0
    obs.pressure  = 0  # disable atmospheric refraction (pure astronomical)

    # Set observer to noon of the requested date in BD time
    # This ensures all calculations are for the correct local day
    noon_bd = date.replace(hour=12, minute=0, second=0, microsecond=0)
    if noon_bd.tzinfo is None:
        noon_bd = noon_bd.replace(tzinfo=BD_TZ)
    noon_utc = noon_bd.astimezone(timezone.utc)
    obs.date = ephem.Date(noon_utc.strftime('%Y/%m/%d %H:%M:%S'))

    # ── Sunrise / Sunset (standard 0°34' refraction horizon = default) ──────
    obs.horizon = '0'
    sunrise  = _to_local(obs.previous_rising(ephem.Sun()))
    sunset   = _to_local(obs.next_setting(ephem.Sun()))

    # ── Dhuhr (solar transit + 1 min) ────────────────────────────────────────
    transit   = _to_local(obs.next_transit(ephem.Sun()))
    dhuhr     = transit + timedelta(minutes=1)

    # ── Fajr (18° below horizon before sunrise) ──────────────────────────────
    obs.horizon = _angle_to_horizon(FAJR_ANGLE)
    fajr = _to_local(obs.previous_rising(ephem.Sun(), use_center=True))

    # ── Isha (18° below horizon after sunset) ────────────────────────────────
    obs.horizon = _angle_to_horizon(ISHA_ANGLE)
    isha = _to_local(obs.next_setting(ephem.Sun(), use_center=True))

    # ── Hanafi Asr ────────────────────────────────────────────────────────────
    obs.horizon = '0'
    obs.date    = ephem.Date(noon_utc.strftime('%Y/%m/%d %H:%M:%S'))
    asr         = _hanafi_asr(obs, ephem.Date(noon_utc.strftime('%Y/%m/%d %H:%M:%S')))

    # ── Maghrib = Sunset ─────────────────────────────────────────────────────
    maghrib = sunset

    # ── Extra times ──────────────────────────────────────────────────────────
    shuruq   = sunrise
    ishraq   = sunrise + timedelta(minutes=20)
    duha     = sunrise + timedelta(minutes=45)

    # Tahajjud: last 1/3 of the night (between Isha and next Fajr)
    next_fajr  = fajr + timedelta(days=1)
    night_secs = (next_fajr - isha).total_seconds()
    tahajjud   = isha + timedelta(seconds=night_secs * 2 / 3)

    date_str = date.strftime('%Y-%m-%d') if not isinstance(date, str) else date

    return {
        'date':      date_str,
        'fajr':      fajr.isoformat(),
        'shuruq':    shuruq.isoformat(),
        'dhuhr':     dhuhr.isoformat(),
        'asr':       asr.isoformat(),
        'maghrib':   maghrib.isoformat(),
        'isha':      isha.isoformat(),
        'tahajjud':  tahajjud.isoformat(),
        'ishraq':    ishraq.isoformat(),
        'duha':      duha.isoformat(),
    }
