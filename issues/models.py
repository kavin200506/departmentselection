

# Create your models here.
from django.db import models
from django.utils import timezone

class Issue(models.Model):
    PROBLEM_TYPES = [
        ('pothole', 'Pothole'),
        ('streetlight', 'Street Light'),
        ('water', 'Water Supply'),
        ('garbage', 'Garbage Collection'),
        ('traffic', 'Traffic Signal'),
        ('other', 'Other'),
    ]
    
    URGENCY_LEVELS = [
        ('low', 'Low'),
        ('medium', 'Medium'),
        ('high', 'High'),
        ('critical', 'Critical'),
    ]
    
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('in_progress', 'In Progress'),
        ('resolved', 'Resolved'),
    ]

    person_id = models.CharField(max_length=100)
    problem_id = models.AutoField(primary_key=True)
    datetime = models.DateTimeField(default=timezone.now)
    location = models.TextField()
    problem_type = models.CharField(max_length=20, choices=PROBLEM_TYPES)
    urgency_level = models.CharField(max_length=10, choices=URGENCY_LEVELS)
    description = models.TextField()
    image_url = models.URLField(blank=True, null=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    
    class Meta:
        db_table = 'civic_issues'
        ordering = ['-datetime']
    
    def __str__(self):
        return f"{self.problem_type} - {self.location[:50]}"