from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import DeviceToken
from .serializers import DeviceTokenSerializer


class RegisterDeviceTokenView(APIView):
    """POST /api/v1/notifications/register/ — Register or update FCM token."""

    def post(self, request):
        serializer = DeviceTokenSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        fcm_token = serializer.validated_data['fcm_token']
        platform  = serializer.validated_data['platform']
        user      = request.user if request.user.is_authenticated else None

        DeviceToken.objects.update_or_create(
            fcm_token=fcm_token,
            defaults={'platform': platform, 'user': user},
        )

        return Response(
            {'detail': 'Device token registered.'},
            status=status.HTTP_200_OK,
        )
