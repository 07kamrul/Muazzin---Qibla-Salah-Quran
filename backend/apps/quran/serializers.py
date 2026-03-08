from rest_framework import serializers
from .models import Ayah, Surah


class AyahSerializer(serializers.ModelSerializer):
    surah_number = serializers.IntegerField(source='surah.number', read_only=True)

    class Meta:
        model  = Ayah
        fields = [
            'surah_number', 'ayah_number',
            'arabic_text', 'bangla_translation', 'english_translation',
            'juz_number', 'page_number',
        ]


class SurahListSerializer(serializers.ModelSerializer):
    """Metadata only — no ayahs (for list endpoint)."""

    class Meta:
        model  = Surah
        fields = [
            'number', 'name_arabic', 'name_bangla', 'name_english',
            'name_meaning', 'ayah_count', 'juz_start', 'revelation_type',
        ]


class SurahDetailSerializer(serializers.ModelSerializer):
    """Surah with all ayahs (for detail endpoint)."""
    ayahs = AyahSerializer(many=True, read_only=True)

    class Meta:
        model  = Surah
        fields = [
            'number', 'name_arabic', 'name_bangla', 'name_english',
            'name_meaning', 'ayah_count', 'juz_start', 'revelation_type',
            'ayahs',
        ]
