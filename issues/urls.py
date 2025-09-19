from django.urls import path
from . import views

urlpatterns = [
    # Web pages
    path('', views.admin_dashboard, name='admin_dashboard'),
    path('test/', views.test_connection, name='test_connection'),
    
    # API endpoints
    path('api/issues/', views.get_issues, name='get_issues'),
    path('api/issues/resolve/', views.resolve_issue, name='resolve_issue'),
    path('api/stats/', views.get_dashboard_stats, name='dashboard_stats'),
    path('api/issues/create/', views.create_issue, name='create_issue'),
]