from django.urls import path

from .views import symptome

urlpatterns = [
    path('', symptome, name="symptomes"),
]
