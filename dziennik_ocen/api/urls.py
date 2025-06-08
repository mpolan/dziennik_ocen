from django.urls import path
from .views import DodajOceneView, OcenyStudentaView, OgolnyRankingOcenView, RankingPrzedmiotowView, RankingGrupView, ZaliczeniaZPrzedmiotuView, CustomLoginView

urlpatterns = [
    path('login/', CustomLoginView.as_view(), name='login'),
    path('dodaj-ocene/', DodajOceneView.as_view(), name='dodaj-ocene'),
    path('oceny-studenta/', OcenyStudentaView.as_view(), name='oceny-studenta'),
    path('ranking-ogolny/', OgolnyRankingOcenView.as_view(), name='ranking-ogolny-z-ocen'),
    path('ranking-przedmiotow/', RankingPrzedmiotowView.as_view(), name='ranking-z-przedmiotow'),
    path('ranking-grup/', RankingGrupView.as_view(), name='ranking-grup'),
    path('zaliczenia-z-przedmiotu/', ZaliczeniaZPrzedmiotuView.as_view(), name='zaliczenia-z-przedmiotu')
]
