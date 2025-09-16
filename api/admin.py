from django.contrib import admin
from .models import Department, Location

# Register your models here.
@admin.register(Department)
class DepartmentAdmin(admin.ModelAdmin):
    list_display = ("id", "name")


@admin.register(Location)
class LocationAdmin(admin.ModelAdmin):
    list_display = ("id", "latitude", "longitude", "address", "created_at")
    list_filter = ("created_at",)
