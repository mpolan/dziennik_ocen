from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.db import connection
from drf_yasg.utils import swagger_auto_schema
from .serializers import DodajOceneSerializer
from drf_yasg import openapi

class DodajOceneView(APIView):

    @swagger_auto_schema(request_body=DodajOceneSerializer)
    def post(self, request):
        serializer = DodajOceneSerializer(data=request.data)
        if serializer.is_valid():
            data = serializer.validated_data
            try:
                with connection.cursor() as cursor:
                    cursor.callproc("dodaj_ocene", [
                        data['user_id'],
                        data['student_id'],
                        data['przedmiot_id'],
                        data['ocena'],
                        data['typ']
                    ])
                return Response({"message": "Ocena została dodana."}, status=status.HTTP_201_CREATED)
            except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class OcenyStudentaView(APIView):

    @swagger_auto_schema(
        manual_parameters=[
            openapi.Parameter('student_id', openapi.IN_QUERY, description="ID studenta", type=openapi.TYPE_INTEGER)
        ]
    )
    def get(self, request):
        student_id = request.GET.get('student_id')
        if not student_id:
            return Response({"error": "Brak parametru student_id"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            with connection.cursor() as cursor:
                cursor.execute("""
                    SELECT przedmiot_nazwa, typ, wartosc, data_wystawienia, nauczyciel_imie, nauczyciel_nazwisko
                    FROM vw_oceny_szczegoly
                    WHERE student_id = :id
                    ORDER BY przedmiot_nazwa, data_wystawienia
                """, {'id': student_id})

                rows = cursor.fetchall()
                results = []
                for row in rows:
                    results.append({
                        'przedmiot': row[0],
                        'typ': row[1],
                        'ocena': row[2],
                        'data': row[3],
                        'nauczyciel': f"{row[4]} {row[5]}"
                    })

            return Response(results)

        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)