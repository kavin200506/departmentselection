from django.shortcuts import render

# Create your views here.
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import generics
from .models import Department, Location
from .serializers import DepartmentSerializer, LocationSerializer

@api_view(['GET'])
def hello_world(request):
    return Response({"message": "Hello from Django Backend!"})

@api_view(['GET'])
def root_view(request):
    return Response({"message": "Welcome to the Django Backend!"})


class DepartmentListCreate(generics.ListCreateAPIView):
    queryset = Department.objects.all()
    serializer_class = DepartmentSerializer


class LocationListCreate(generics.ListCreateAPIView):
    queryset = Location.objects.order_by('-created_at')
    serializer_class = LocationSerializer
