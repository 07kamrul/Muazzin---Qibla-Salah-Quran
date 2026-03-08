from django.core.mail import send_mail
from django.conf import settings
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.throttling import ScopedRateThrottle
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

from .models import OTPCode, User
from .serializers import OTPRequestSerializer, OTPVerifySerializer, UserProfileSerializer


class OTPRequestView(APIView):
    """POST /api/v1/auth/otp/ — Send OTP to email."""

    throttle_classes = [ScopedRateThrottle]
    throttle_scope   = 'otp'

    def post(self, request):
        serializer = OTPRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        email = serializer.validated_data['email'].lower()
        user, _ = User.objects.get_or_create(email=email)

        otp_obj = OTPCode.generate(user)

        send_mail(
            subject='Your Muazzin OTP Code',
            message=(
                f'Your one-time password is: {otp_obj.code}\n\n'
                f'This code expires in {settings.OTP_EXPIRY_MINUTES} minutes.\n'
                'If you did not request this, please ignore this email.'
            ),
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[email],
            fail_silently=False,
        )

        return Response(
            {'detail': 'OTP sent to your email.'},
            status=status.HTTP_200_OK,
        )


class OTPVerifyView(APIView):
    """POST /api/v1/auth/otp/verify/ — Verify OTP and return JWT tokens."""

    def post(self, request):
        serializer = OTPVerifySerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        email = serializer.validated_data['email'].lower()
        otp   = serializer.validated_data['otp']

        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response(
                {'detail': 'Invalid email or OTP.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        otp_obj = (
            OTPCode.objects
            .filter(user=user, is_used=False)
            .order_by('-created_at')
            .first()
        )

        if not otp_obj or not otp_obj.is_valid or otp_obj.code != otp:
            return Response(
                {'detail': 'Invalid or expired OTP.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        otp_obj.is_used = True
        otp_obj.save(update_fields=['is_used'])

        user.is_verified = True
        user.save(update_fields=['is_verified'])

        refresh = RefreshToken.for_user(user)
        return Response({
            'access':  str(refresh.access_token),
            'refresh': str(refresh),
            'user':    UserProfileSerializer(user).data,
        })


class UserMeView(APIView):
    """GET/PATCH /api/v1/users/me/ — Current user profile."""

    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response(UserProfileSerializer(request.user).data)

    def patch(self, request):
        serializer = UserProfileSerializer(
            request.user,
            data=request.data,
            partial=True,
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)
