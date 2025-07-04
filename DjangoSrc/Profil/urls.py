from django.urls import path

from .views import profil

urlpatterns = [
    path('', profil, name="profil"),
]
