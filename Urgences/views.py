from django.shortcuts import render

# Create your views here.
def urgences(request):
    return render(request, "Urgences/index.html")
