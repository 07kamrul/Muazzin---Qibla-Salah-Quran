from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models


class Hadith(models.Model):
    arabic_text         = models.TextField(blank=True)
    bangla_translation  = models.TextField()
    english_translation = models.TextField()
    source              = models.CharField(max_length=200)
    book_name           = models.CharField(max_length=200)
    hadith_number       = models.CharField(max_length=50)
    narrator            = models.CharField(max_length=200, blank=True)
    day_of_year         = models.PositiveSmallIntegerField(
        unique=True,
        validators=[MinValueValidator(1), MaxValueValidator(365)],
        help_text='1–365 daily rotation index',
    )

    class Meta:
        db_table = 'hadiths'
        ordering = ['day_of_year']

    def __str__(self):
        return f'Hadith #{self.day_of_year} — {self.book_name} {self.hadith_number}'
