from datetime import date, datetime, timedelta
from decimal import Decimal, ROUND_HALF_UP

from rest_framework.response import Response
from rest_framework.views import APIView

from .calculator import calculate
from .models import PrayerTimeCache


def _round_coord(value: float, places: int = 2) -> Decimal:
    """Round lat/lng to `places` decimal places for cache keying."""
    return Decimal(str(value)).quantize(Decimal('0.01'), rounding=ROUND_HALF_UP)


def _get_or_calc(lat: float, lng: float, target_date: date) -> dict:
    """Return cached or freshly-calculated prayer times for one day."""
    lat_key = _round_coord(lat)
    lng_key = _round_coord(lng)

    try:
        cache = PrayerTimeCache.objects.get(
            lat_key=lat_key,
            lng_key=lng_key,
            date=target_date,
        )
        return {
            'date':     str(cache.date),
            'fajr':     cache.fajr.isoformat(),
            'shuruq':   cache.shuruq.isoformat(),
            'dhuhr':    cache.dhuhr.isoformat(),
            'asr':      cache.asr.isoformat(),
            'maghrib':  cache.maghrib.isoformat(),
            'isha':     cache.isha.isoformat(),
            'tahajjud': cache.tahajjud.isoformat(),
            'ishraq':   cache.ishraq.isoformat(),
            'duha':     cache.duha.isoformat(),
        }
    except PrayerTimeCache.DoesNotExist:
        pass

    # Calculate and persist
    result = calculate(lat, lng, datetime.combine(target_date, datetime.min.time()))

    PrayerTimeCache.objects.create(
        lat_key  = lat_key,
        lng_key  = lng_key,
        date     = target_date,
        fajr     = result['fajr'],
        shuruq   = result['shuruq'],
        dhuhr    = result['dhuhr'],
        asr      = result['asr'],
        maghrib  = result['maghrib'],
        isha     = result['isha'],
        tahajjud = result['tahajjud'],
        ishraq   = result['ishraq'],
        duha     = result['duha'],
    )

    return result


class PrayerTimesView(APIView):
    """
    GET /api/v1/prayer-times/
    Query params:
      lat    – latitude  (required)
      lng    – longitude (required)
      date   – YYYY-MM-DD (default: today)
      days   – number of days to return, 1–30 (default: 1)
      method – calculation method, only 'karachi' supported (ignored)
    """

    def get(self, request):
        lat  = request.query_params.get('lat')
        lng  = request.query_params.get('lng')
        date_str = request.query_params.get('date')
        days_str = request.query_params.get('days', '1')

        if not lat or not lng:
            return Response(
                {'detail': 'lat and lng are required.'},
                status=400,
            )

        try:
            lat  = float(lat)
            lng  = float(lng)
        except ValueError:
            return Response({'detail': 'lat and lng must be numeric.'}, status=400)

        try:
            days = max(1, min(int(days_str), 30))
        except ValueError:
            days = 1

        if date_str:
            try:
                start_date = date.fromisoformat(date_str)
            except ValueError:
                return Response({'detail': 'Invalid date format. Use YYYY-MM-DD.'}, status=400)
        else:
            start_date = date.today()

        if days == 1:
            return Response(_get_or_calc(lat, lng, start_date))

        results = []
        for i in range(days):
            target = start_date + timedelta(days=i)
            results.append(_get_or_calc(lat, lng, target))

        return Response({'results': results})
