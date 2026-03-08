from django.contrib import admin
from .models import Hadith


@admin.register(Hadith)
class HadithAdmin(admin.ModelAdmin):
    list_display  = ['day_of_year', 'book_name', 'hadith_number', 'source']
    list_filter   = ['book_name', 'source']
    search_fields = ['bangla_translation', 'english_translation', 'narrator']
    ordering      = ['day_of_year']
