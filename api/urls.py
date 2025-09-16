from django.urls import path
from .views import hello_world, root_view
from .views import DepartmentListCreate, LocationListCreate

urlpatterns = [
    path('hello/', hello_world),
    path('', root_view),  # This will map the root path 'api/' to root_view
    path('departments/', DepartmentListCreate.as_view(), name='departments-list-create'),
    path('locations/', LocationListCreate.as_view(), name='locations-list-create'),

]
