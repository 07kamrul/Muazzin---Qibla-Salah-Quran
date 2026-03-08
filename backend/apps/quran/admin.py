from django.contrib import admin
from .models import Ayah, Surah


class AyahInline(admin.TabularInline):
    model  = Ayah
    fields = ['ayah_number', 'arabic_text', 'bangla_translation', 'english_translation']
    extra  = 0
    max_num = 10  # Show first 10 in admin; full list via API


@admin.register(Surah)
class SurahAdmin(admin.ModelAdmin):
    list_display  = ['number', 'name_english', 'name_arabic', 'ayah_count', 'revelation_type']
    list_filter   = ['revelation_type']
    search_fields = ['name_english', 'name_arabic', 'name_bangla']
    ordering      = ['number']
    inlines       = [AyahInline]


@admin.register(Ayah)
class AyahAdmin(admin.ModelAdmin):
    list_display  = ['surah', 'ayah_number', 'juz_number']
    list_filter   = ['surah', 'juz_number']
    search_fields = ['arabic_text', 'bangla_translation', 'english_translation']
