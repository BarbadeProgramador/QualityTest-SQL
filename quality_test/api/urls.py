from django.urls import path, include
from .views import sp_view_employee , sp_view_nomina , export_csv

urlpatterns = [
    path('ver-empleados/<int:id>/', sp_view_employee, name='ver-empleados'), # Ruta para ejecutar el SP
    path('ver-pagos/<int:id>/', sp_view_nomina, name='ver-pagos'),
    path('descargar-csv/<int:id>' , export_csv, name='csv'),
]
