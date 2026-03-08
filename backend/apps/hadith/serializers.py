from rest_framework import serializers
from .models import Hadith


class HadithSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Hadith
        fields = [
            'id', 'arabic_text', 'bangla_translation', 'english_translation',
            'source', 'book_name', 'hadith_number', 'narrator', 'day_of_year',
        ]
