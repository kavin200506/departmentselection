from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
import json
from .models import Issue

def admin_dashboard(request):
    """Render the admin dashboard HTML page"""
    return render(request, 'admin_dashboard.html')

def test_connection(request):
    """Render the database connection test page"""
    return render(request, 'test_connection.html')

def get_issues(request):
    """API endpoint to get all issues as JSON"""
    issues = Issue.objects.all()
    issues_data = []
    
    for issue in issues:
        issues_data.append({
            'person_id': issue.person_id,
            'problem_id': issue.problem_id,
            'datetime': issue.datetime.strftime('%Y-%m-%d %H:%M'),
            'location': issue.location,
            'problem_type': issue.problem_type,
            'urgency_level': issue.urgency_level,
            'description': issue.description,
            'image_url': issue.image_url or 'https://via.placeholder.com/400x300?text=No+Image',
            'status': issue.status,
        })
    
    return JsonResponse(issues_data, safe=False)

@csrf_exempt
@require_http_methods(["POST"])
def resolve_issue(request):
    """API endpoint to resolve an issue"""
    try:
        data = json.loads(request.body)
        problem_id = data.get('problem_id')
        
        issue = Issue.objects.get(problem_id=problem_id)
        issue.status = 'resolved'
        issue.save()
        
        return JsonResponse({'success': True, 'message': 'Issue resolved successfully'})
    except Issue.DoesNotExist:
        return JsonResponse({'success': False, 'message': 'Issue not found'}, status=404)
    except Exception as e:
        return JsonResponse({'success': False, 'message': str(e)}, status=500)

def get_dashboard_stats(request):
    """API endpoint to get dashboard statistics"""
    total_problems = Issue.objects.count()
    active_problems = Issue.objects.exclude(status='resolved').count()
    resolved_problems = Issue.objects.filter(status='resolved').count()
    
    return JsonResponse({
        'total_problems': total_problems,
        'active_problems': active_problems,
        'resolved_problems': resolved_problems,
    })

@csrf_exempt
@require_http_methods(["POST"])
def create_issue(request):
    """API endpoint to create a new issue"""
    try:
        data = json.loads(request.body)
        
        issue = Issue.objects.create(
            person_id=data.get('person_id'),
            location=data.get('location'),
            problem_type=data.get('problem_type'),
            urgency_level=data.get('urgency_level'),
            description=data.get('description'),
            image_url=data.get('image_url', ''),
        )
        
        return JsonResponse({
            'success': True, 
            'message': 'Issue created successfully',
            'problem_id': issue.problem_id
        })
    except Exception as e:
        return JsonResponse({'success': False, 'message': str(e)}, status=500)