from django.urls import path
from .views import DodajOceneView, OcenyStudentaView

urlpatterns = [
    path('dodaj-ocene/', DodajOceneView.as_view(), name='dodaj-ocene'),
    path('oceny-studenta/', OcenyStudentaView.as_view(), name='oceny-studenta'),
]
