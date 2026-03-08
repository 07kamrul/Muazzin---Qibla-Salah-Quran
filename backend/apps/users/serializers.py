from rest_framework import serializers

from .models import User


class OTPRequestSerializer(serializers.Serializer):
    email = serializers.EmailField()


class OTPVerifySerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp   = serializers.CharField(min_length=6, max_length=6)


class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model  = User
        fields = ['id', 'email', 'display_name', 'is_verified', 'created_at']
        read_only_fields = ['id', 'email', 'is_verified', 'created_at']
