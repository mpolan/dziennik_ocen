from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from django.db import connection
from drf_yasg.utils import swagger_auto_schema
from .serializers import DodajOceneSerializer, LoginSerializer
from drf_yasg import openapi

class CustomLoginView(APIView):
    @swagger_auto_schema(request_body=LoginSerializer)
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        username = serializer.validated_data['username']
        password = serializer.validated_data['password']

        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT hashuj_haslo(:password) FROM dual", {'password': password})
                hashed_pw = cursor.fetchone()[0]

                cursor.execute("""
                    SELECT id, rola FROM UZYTKOWNIK 
                    WHERE login = :username AND haslo = :hashed
                """, {'username': username, 'hashed': hashed_pw})

                result = cursor.fetchone()
                if result:
                    user_id, rola = result
                    token = RefreshToken()
                    token['rola'] = rola
                    token['username'] = username
                    return Response({
                        'access': str(token.access_token),
                        'refresh': str(token)
                    }, status=200)
                else:
                    return Response({'error': 'Nieprawidłowe dane logowania'}, status=401)

        except Exception as e:
            return Response({'error': str(e)}, status=500)

class DodajOceneView(APIView):
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(request_body=DodajOceneSerializer, security=[{'Bearer': []}])
    def post(self, request):
        serializer = DodajOceneSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user_email = request.user.username
        student_id = serializer.validated_data["student_id"]
        przedmiot_id = serializer.validated_data["przedmiot_id"]
        ocena = serializer.validated_data["ocena"]
        typ = serializer.validated_data["typ"]

        try:
            with connection.cursor() as cursor:
                cursor.callproc('dodaj_ocene', [
                    user_email,
                    student_id,
                    przedmiot_id,
                    ocena,
                    typ
                ])
            return Response({"message": "Ocena dodana."}, status=status.HTTP_200_OK)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

class OcenyStudentaView(APIView):
    permission_classes = [IsAuthenticated]
    @swagger_auto_schema(
        manual_parameters=[
            openapi.Parameter('student_id', openapi.IN_QUERY, description="ID studenta", type=openapi.TYPE_INTEGER)
        ],
        security=[{'Bearer': []}]
    )
    def get(self, request):
        student_id = request.GET.get('student_id')
        user_email = request.user.username

        if not student_id:
            return Response({"error": "Brak parametru student_id"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT przedmiot_nazwa, typ, wartosc, data_wystawienia, nauczyciel_imie, nauczyciel_nazwisko
                    FROM vw_oceny_szczegoly
                    WHERE student_id = :id
                    AND nauczyciel_email = :email
                    ORDER BY przedmiot_nazwa, data_wystawienia
                """, {'id': student_id, 'email': user_email})

                rows = cursor.fetchall()
                results = []
                for row in rows:
                    results.append({
                        'Przedmiot': row[0],
                        'Typ': row[1],
                        'Ocena': row[2],
                        'Prowadzacy': f"{row[4]} {row[5]}",
                        'Data Wystawienia': row[3]
                    })

            return Response(results)

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        
class OgolnyRankingOcenView(APIView):
    @swagger_auto_schema(operation_summary="Pobierz ogólny ranking studentów wg średniej ocen")
    def get(self, request):
        try:
            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT pozycja, student_imie, student_nazwisko, srednia
                    FROM vw_ranking
                """)

                rows = cursor.fetchall()
                results = []
                for row in rows:
                    results.append({
                        'Pozycja': row[0],
                        'Student': f"{row[1]} {row[2]}",
                        'Średnia Ocen': row[3]
                    })

            return Response(results)

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        
class ZaliczeniaZPrzedmiotuView(APIView):

    @swagger_auto_schema(
        manual_parameters=[
            openapi.Parameter('przedmiot_id', openapi.IN_QUERY, description="ID przedmiotu", type=openapi.TYPE_INTEGER)
        ],
        security=[{'Bearer': []}]
    )
    def get(self, request):
        przedmiot_id = request.GET.get('przedmiot_id')
        user_email = request.user.username
        if not przedmiot_id:
            return Response({"error": "Brak parametru przedmiot_id"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT student, przedmiot, nauczyciel, srednia, status FROM vw_zaliczenia
                    WHERE przedmiot_id = :id
                    AND nauczyciel_email =:email
                    ORDER BY srednia asc
                """, {'id': przedmiot_id, 'email': user_email})

                rows = cursor.fetchall()
                results = []
                for row in rows:
                    results.append({
                        'Student': row[0],
                        'Przedmiot': row[1],
                        'Prowadzacy': row[2],
                        'Średnia': row[3],
                        'Status': row[4]
                    })

            return Response(results)

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)