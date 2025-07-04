from django.urls import path

from .views import urgences

urlpatterns = [
    path('', urgences, name="urgences"),
]
