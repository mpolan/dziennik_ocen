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
        user_role = request.user.rola 

        if not student_id:
            return Response({"error": "Brak parametru student_id"}, status=status.HTTP_400_BAD_REQUEST)
        if user_role is None:
            return Response({"error": "Brak autoryzcji: Zaloguj się za pomocą klucza API."}, status=status.HTTP_401_UNAUTHORIZED)

        try:
            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT przedmiot_nazwa, typ, wartosc, data_wystawienia, nauczyciel_imie, nauczyciel_nazwisko
                    FROM vw_oceny_szczegoly
                    WHERE student_id = :id
                    AND (
                        :rola = 'ADMIN' OR
                        nauczyciel_email = :email OR
                        student_email = :email
                    )
                    ORDER BY przedmiot_nazwa, data_wystawienia
                """, {
                    'id': student_id,
                    'email': user_email,
                    'rola': user_role
                })

                rows = cursor.fetchall()

                # Obsługa wyjątków po roli
                if not rows:
                    if user_role == 'STUDENT':
                        return Response(
                            {"error": "Brak danych: To nie twoje oceny lub student o podanym ID nie istnieje."},
                            status=status.HTTP_404_NOT_FOUND
                        )
                    elif user_role == 'NAUCZYCIEL':
                        return Response(
                            {"error": "Brak danych: Nie uczysz tego studenta lub student o podanym ID nie istnieje."},
                            status=status.HTTP_404_NOT_FOUND
                        )
                    else:  # ADMIN
                        return Response(
                            {"error": "Brak danych: Student o podanym ID nie istnieje lub nie ma ocen."},
                            status=status.HTTP_404_NOT_FOUND
                        )
                results = []
                for row in rows:
                    results.append({
                        'Przedmiot': row[0],
                        'Typ': row[1],
                        'Ocena': row[2],
                        'Prowadzacy': f"{row[4]} {row[5]}",
                        'Data Wystawienia': row[3]
                    })
                # Średnia
                cursor.execute("""
                    SELECT ROUND(AVG(wartosc), 2) FROM VW_OCENY_SZCZEGOLY
                    WHERE student_id = :id
                """, {'id': student_id})

                srednia = cursor.fetchone()
                srednia = {
                    'Średnia ocen': srednia[0]
                }

            return Response({
                'Średnia': srednia,
                'Oceny': results
            })

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        
class OgolnyRankingOcenView(APIView):
    @swagger_auto_schema(operation_summary="Pobierz ogólny ranking studentów wg średniej ocen")
    def get(self, request):
        try:
            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT pozycja, student_imie, student_nazwisko, srednia
                    FROM vw_ranking_ogolny
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

class RankingPrzedmiotowView(APIView):
    @swagger_auto_schema(operation_summary="Pobierz ranking z przedmiotow wg średniej ocen")
    def get(self, request):
        try:
            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT pozycja, przedmiot_nazwa, nauczyciel_dane, srednia
                    FROM vw_ranking_przedmiotow
                """)

                rows = cursor.fetchall()
                results = []
                for row in rows:
                    results.append({
                        'Pozycja': row[0],
                        'Przedmiot': row[1],
                        'Nauczyciel': row[2],
                        'Średnia': row[3]
                    })

            return Response(results)

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        
class RankingGrupView(APIView):
    @swagger_auto_schema(operation_summary="Pobierz ranking z grup wg średniej ocen")
    def get(self, request):
        try:
            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT pozycja, grupa_dane, srednia
                    FROM vw_ranking_grup
                """)

                rows = cursor.fetchall()
                results = []
                for row in rows:
                    results.append({
                        'Pozycja': row[0],
                        'Grupa': row[1],
                        'Średnia': row[2]
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
        user_role = getattr(request.user, 'rola', None)

        if not przedmiot_id:
            return Response({"error": "Brak parametru przedmiot_id"}, status=status.HTTP_400_BAD_REQUEST)
        if user_role is None:
            return Response({"error": "Brak autoryzcji: Zaloguj się za pomocą klucza API."}, status=status.HTTP_401_UNAUTHORIZED)

        try:
            with connection.cursor() as cursor:
                if user_role == 'ADMIN':
                    cursor.execute("""
                        SELECT student, przedmiot, nauczyciel, srednia, status
                        FROM vw_zaliczenia
                        WHERE przedmiot_id = :id
                        ORDER BY srednia ASC
                    """, {'id': przedmiot_id})
                else:
                    cursor.execute("""
                        SELECT student, przedmiot, nauczyciel, srednia, status
                        FROM vw_zaliczenia
                        WHERE przedmiot_id = :id AND (nauczyciel_email = :email or student_email = :email)
                        ORDER BY srednia ASC
                    """, {'id': przedmiot_id, 'email': user_email})

                rows = cursor.fetchall()

                # Obsługa wyjątków na podstawie roli
                if not rows:
                    if user_role == 'NAUCZYCIEL':
                        return Response(
                            {"error": "Brak dostępu: Nie prowadzisz tego przedmiotu lub nie ma on ocen."},
                            status=status.HTTP_403_FORBIDDEN
                        )
                    elif user_role == 'STUDENT':
                        return Response(
                            {"error": "Brak dostępu: Nie uczestniczysz w tym przedmiocie, lub on nie istnieje."},
                            status=status.HTTP_403_FORBIDDEN
                        )
                    else:
                        return Response(
                            {"error": "Brak danych: Przedmiot nie istnieje lub nie ma ocen."},
                            status=status.HTTP_404_NOT_FOUND
                        )

                results = []
                for row in rows:
                    results.append({
                        'Student': row[0],
                        'Przedmiot': row[1],
                        'Prowadzacy': row[2],
                        'Średnia': row[3],
                        'Status': row[4]
                    })

                # Statystyka zaliczeń
                cursor.execute("""
                    SELECT
                        COUNT(*) AS liczba_wszystkich,
                        SUM(CASE WHEN status = 'zaliczony' THEN 1 ELSE 0 END) AS liczba_zaliczonych,
                        SUM(CASE WHEN status = 'niezaliczony' THEN 1 ELSE 0 END) AS liczba_niezaliczonych
                    FROM vw_zaliczenia
                    WHERE przedmiot_id = :id
                """, {'id': przedmiot_id})

                stat_row = cursor.fetchone()
                statystyki = {
                    'Liczba wszystkich studentów': stat_row[0],
                    'Zaliczonych': stat_row[1],
                    'Niezaliczonych': stat_row[2]
                }

            return Response({
                'Statystyki': statystyki,
                'Lista Zaliczeń': results
            })

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

