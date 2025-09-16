from django.db import models

# Create your models here.


class Department(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField()


class Location(models.Model):
    latitude = models.DecimalField(max_digits=9, decimal_places=6)
    longitude = models.DecimalField(max_digits=9, decimal_places=6)
    address = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.latitude}, {self.longitude} (@ {self.created_at:%Y-%m-%d %H:%M:%S})"