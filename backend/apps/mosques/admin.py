from django.contrib import admin
from django.contrib.gis import admin as gis_admin

from .models import JamatSubmission, Mosque


@admin.register(Mosque)
class MosqueAdmin(gis_admin.OSMGeoAdmin):
    list_display   = ['name_bn', 'name_en', 'district', 'verification_status', 'created_at']
    list_filter    = ['verification_status', 'district']
    search_fields  = ['name_bn', 'name_en', 'district', 'upazila']
    readonly_fields = ['id', 'created_at', 'updated_at']


@admin.register(JamatSubmission)
class JamatSubmissionAdmin(admin.ModelAdmin):
    list_display  = ['mosque', 'submitted_by', 'status', 'created_at']
    list_filter   = ['status']
    search_fields = ['mosque__name_bn']
    actions       = ['approve_submissions']

    @admin.action(description='Approve selected submissions')
    def approve_submissions(self, request, queryset):
        for submission in queryset.filter(status='pending'):
            mosque = submission.mosque
            mosque.jamat_times = {**mosque.jamat_times, **submission.times}
            mosque.save(update_fields=['jamat_times', 'updated_at'])
            submission.status = 'approved'
            submission.save(update_fields=['status'])
