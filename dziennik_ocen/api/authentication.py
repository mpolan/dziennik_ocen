from rest_framework_simplejwt.authentication import JWTAuthentication
from django.contrib.auth.models import AnonymousUser
from types import SimpleNamespace

class CustomJWTAuthentication(JWTAuthentication):
    def get_user(self, validated_token):
        username = validated_token.get("username", None)
        if not username:
            return AnonymousUser()

        # Tworzymy prosty użytkownik-obiekt, który udaje zalogowanego
        user = SimpleNamespace()
        user.username = username
        user.is_authenticated = True
        return user
