from django.urls import path

from .views import carte

urlpatterns = [
    path('', carte, name="carte"),
]
