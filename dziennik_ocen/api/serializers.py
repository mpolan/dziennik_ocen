from rest_framework import serializers

class DodajOceneSerializer(serializers.Serializer):
    user_id = serializers.IntegerField()
    student_id = serializers.IntegerField()
    przedmiot_id = serializers.IntegerField()
    ocena = serializers.FloatField()
    typ = serializers.CharField()
