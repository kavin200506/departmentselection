from django.core.management.base import BaseCommand
from issues.models import Issue
from django.utils import timezone
from datetime import timedelta

class Command(BaseCommand):
    help = 'Create sample civic issues data'

    def handle(self, *args, **options):
        # Clear existing data
        Issue.objects.all().delete()
        
        # Create sample issues
        sample_issues = [
            {
                'person_id': 'CITIZEN_001',
                'location': 'Main Street, Downtown - Near City Hall',
                'problem_type': 'pothole',
                'urgency_level': 'high',
                'description': 'Large pothole causing traffic issues and vehicle damage. Located in the middle lane.',
                'image_url': 'https://via.placeholder.com/400x300?text=Pothole+Image',
                'status': 'pending',
                'datetime': timezone.now() - timedelta(hours=2)
            },
            {
                'person_id': 'CITIZEN_002',
                'location': 'Oak Avenue, Residential Area',
                'problem_type': 'streetlight',
                'urgency_level': 'medium',
                'description': 'Street light not working for 3 days. Area is very dark at night.',
                'image_url': 'https://via.placeholder.com/400x300?text=Street+Light+Issue',
                'status': 'in_progress',
                'datetime': timezone.now() - timedelta(days=1)
            },
            {
                'person_id': 'CITIZEN_003',
                'location': 'Water Street, Commercial District',
                'problem_type': 'water',
                'urgency_level': 'critical',
                'description': 'Water main burst causing flooding on the street. Emergency repair needed.',
                'image_url': 'https://via.placeholder.com/400x300?text=Water+Main+Burst',
                'status': 'pending',
                'datetime': timezone.now() - timedelta(hours=1)
            },
            {
                'person_id': 'CITIZEN_004',
                'location': 'Park Lane, Near Central Park',
                'problem_type': 'garbage',
                'urgency_level': 'low',
                'description': 'Garbage bins overflowing. Regular collection seems to be missed.',
                'image_url': 'https://via.placeholder.com/400x300?text=Garbage+Overflow',
                'status': 'resolved',
                'datetime': timezone.now() - timedelta(days=3)
            },
            {
                'person_id': 'CITIZEN_005',
                'location': 'Traffic Circle, Main Intersection',
                'problem_type': 'traffic',
                'urgency_level': 'high',
                'description': 'Traffic signal not working properly. Causing confusion and potential accidents.',
                'image_url': 'https://via.placeholder.com/400x300?text=Traffic+Signal+Issue',
                'status': 'pending',
                'datetime': timezone.now() - timedelta(hours=4)
            },
            {
                'person_id': 'CITIZEN_006',
                'location': 'Riverside Drive, Waterfront',
                'problem_type': 'other',
                'urgency_level': 'medium',
                'description': 'Broken bench in the park. Needs repair for public safety.',
                'image_url': 'https://via.placeholder.com/400x300?text=Broken+Bench',
                'status': 'resolved',
                'datetime': timezone.now() - timedelta(days=2)
            }
        ]
        
        for issue_data in sample_issues:
            Issue.objects.create(**issue_data)
        
        self.stdout.write(
            self.style.SUCCESS(f'Successfully created {len(sample_issues)} sample issues!')
        )
