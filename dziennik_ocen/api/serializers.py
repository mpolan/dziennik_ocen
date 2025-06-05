from rest_framework import serializers

class DodajOceneSerializer(serializers.Serializer):
    student_id = serializers.IntegerField()
    przedmiot_id = serializers.IntegerField()
    ocena = serializers.FloatField()
    typ = serializers.CharField()


class LoginSerializer(serializers.Serializer):
    username = serializers.EmailField()
    password = serializers.CharField()
