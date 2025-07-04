from django.shortcuts import render

# Create your views here.
def carte(request):
    return render(request, 'Carte/index.html')