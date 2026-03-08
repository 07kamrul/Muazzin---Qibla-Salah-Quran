from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin

from .models import OTPCode, User


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display   = ['email', 'display_name', 'is_verified', 'is_staff', 'created_at']
    list_filter    = ['is_verified', 'is_staff', 'is_active']
    search_fields  = ['email', 'display_name']
    ordering       = ['-created_at']
    fieldsets      = (
        (None,          {'fields': ('email', 'password')}),
        ('Profile',     {'fields': ('display_name', 'is_verified')}),
        ('Permissions', {'fields': ('is_staff', 'is_active', 'is_superuser', 'groups', 'user_permissions')}),
    )
    add_fieldsets  = (
        (None, {
            'classes': ('wide',),
            'fields':  ('email', 'password1', 'password2'),
        }),
    )


@admin.register(OTPCode)
class OTPCodeAdmin(admin.ModelAdmin):
    list_display  = ['user', 'code', 'expires_at', 'is_used', 'created_at']
    list_filter   = ['is_used']
    search_fields = ['user__email']
    readonly_fields = ['code', 'created_at']
