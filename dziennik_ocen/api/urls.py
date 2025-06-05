from django.urls import path
from .views import DodajOceneView, OcenyStudentaView, OgolnyRankingOcenView, ZaliczeniaZPrzedmiotuView

urlpatterns = [
    path('dodaj-ocene/', DodajOceneView.as_view(), name='dodaj-ocene'),
    path('oceny-studenta/', OcenyStudentaView.as_view(), name='oceny-studenta'),
    path('ogolny-ranking/', OgolnyRankingOcenView.as_view(), name='ogolny-ranking-ocen'),
    path('zaliczenia-z-przedmiotu/', ZaliczeniaZPrzedmiotuView.as_view(), name='zaliczenia-z-przedmiotu'),
]
