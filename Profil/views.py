from django.shortcuts import render

# Create your views here.
def profil(request):
    return render(request, "Profil/index.html")