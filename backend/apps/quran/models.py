from django.db import models


class Surah(models.Model):
    REVELATION_CHOICES = [('meccan', 'Meccan'), ('medinan', 'Medinan')]

    number          = models.PositiveSmallIntegerField(primary_key=True)  # 1–114
    name_arabic     = models.CharField(max_length=100)
    name_bangla     = models.CharField(max_length=100)
    name_english    = models.CharField(max_length=100)
    name_meaning    = models.CharField(max_length=200, blank=True)
    ayah_count      = models.PositiveSmallIntegerField()
    juz_start       = models.PositiveSmallIntegerField(default=1)
    revelation_type = models.CharField(max_length=10, choices=REVELATION_CHOICES, default='meccan')

    class Meta:
        db_table = 'surahs'
        ordering = ['number']

    def __str__(self):
        return f'{self.number}. {self.name_english} ({self.name_arabic})'


class Ayah(models.Model):
    surah               = models.ForeignKey(
        Surah,
        on_delete=models.CASCADE,
        related_name='ayahs',
    )
    ayah_number         = models.PositiveSmallIntegerField()
    arabic_text         = models.TextField()
    bangla_translation  = models.TextField(blank=True)
    english_translation = models.TextField(blank=True)
    juz_number          = models.PositiveSmallIntegerField(default=1)
    page_number         = models.PositiveSmallIntegerField(null=True, blank=True)

    class Meta:
        db_table         = 'ayahs'
        unique_together  = ('surah', 'ayah_number')
        ordering         = ['surah__number', 'ayah_number']
        indexes          = [
            models.Index(fields=['surah', 'ayah_number']),
        ]

    def __str__(self):
        return f'{self.surah.number}:{self.ayah_number}'
