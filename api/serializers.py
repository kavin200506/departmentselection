from rest_framework import serializers
from .models import Department, Location


class DepartmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Department
        fields = ["id", "name", "description"]


class LocationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Location
        fields = ["id", "latitude", "longitude", "address", "created_at"]
        read_only_fields = ["id", "created_at"]


