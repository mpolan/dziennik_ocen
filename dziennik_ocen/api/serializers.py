from rest_framework import serializers

class DodajOceneSerializer(serializers.Serializer):
    student_id = serializers.IntegerField()
    przedmiot_id = serializers.IntegerField()
    ocena = serializers.FloatField()
    typ = serializers.CharField()

    def validate_ocena(self, value):
        dozwolone_oceny = [2.0, 3.0, 3.5, 4.0, 4.5, 5.0]
        if value not in dozwolone_oceny:
            raise serializers.ValidationError("Ocena musi być jedną z: 2.0, 3.0, 3.5, 4.0, 4.5, 5.0")
        return value



class AktualizujOceneSerializer(serializers.Serializer):
    ocena_id = serializers.IntegerField(min_value=1)
    nowa = serializers.FloatField()

    def validate_nowa(self, value):
        dozwolone_oceny = [2.0, 3.0, 3.5, 4.0, 4.5, 5.0]
        if value not in dozwolone_oceny:
            raise serializers.ValidationError("Ocena musi być jedną z: 2.0, 3.0, 3.5, 4.0, 4.5, 5.0")
        return value


class LoginSerializer(serializers.Serializer):
    username = serializers.EmailField()
    password = serializers.CharField(write_only=True)

