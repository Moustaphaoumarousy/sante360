from django.shortcuts import render

# Create your views here.
def symptome(request):
    return render(request, "Symptomes/index.html")