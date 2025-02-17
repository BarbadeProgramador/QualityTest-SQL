from django.shortcuts import render
from django.db import connection
from django.http import JsonResponse , HttpResponse  
from rest_framework.decorators import api_view , action
from reportlab.pdfgen import canvas 
import csv  # 
import io  
from rest_framework import viewsets  
from rest_framework.response import Response  


@api_view(['GET'])
def sp_view_employee(request, id):  
    if not id:
        return JsonResponse({"error": "El parámetro id_usuario es necesario."}, status=400)

    try:
        with connection.cursor() as cursor:
            # Ejecuta el procedimiento almacenado con el id_usuario
            cursor.execute("EXEC [dbo].[permisoVisualizacionEmpleadosSP5] @id_usuario = %s", [id])
            resultado = cursor.fetchall()

        # Verificación de si no hay resultados
        if not resultado:
            return JsonResponse({"error": "El usuario no tiene permisos"}, status=404)

        return JsonResponse({"resultado": resultado})

    except Exception as e:
        return JsonResponse({"error": f"El usuario no tiene permisos: {str(e)}"}, status=500)


@api_view(['GET'])
def sp_view_nomina(request, id):
    if not id:
        return JsonResponse({"error": "El parámetro id_usuario es necesario."}, status=400)

    try:
        with connection.cursor() as cursor:
            cursor.execute("EXEC [dbo].[permisoVisualizacionNominaSP] @id_usuario = %s", [id])
            resultado = cursor.fetchall()

        # Verificación de si no hay resultados
        if not resultado:
            return JsonResponse({"error": "NEl usuario no tiene permisos"}, status=404)

        return JsonResponse({"resultado": resultado})

    except Exception as e:
        return JsonResponse({"error": f"El usuario no tiene permisos {str(e)}"}, status=500)


@action(detail=False, methods=['get'])
def export_csv(request, id):
    """Genera y descarga un archivo CSV con la lista de empleados."""
    try:
        with connection.cursor() as cursor:
            cursor.execute("EXEC permisoVisualizacionEmpleadosSP5 @id_usuario=%s", [id])
            empleados = cursor.fetchall()

        # Verificación de si no hay empleados
        if not empleados:
            return JsonResponse({"error": "El usuario no tiene permisos"}, status=404)

        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = 'attachment; filename="empleados.csv"'
        writer = csv.writer(response)
        writer.writerow(['nombre', 'nit', 'email', 'cargo', 'departamento', 'area'])  # Encabezados

        for emp in empleados:
            writer.writerow(emp)  # Escribir cada fila en el archivo CSV

        return response

    except Exception as e:
        return JsonResponse({"error": f"El usuario no tiene permisos: {str(e)}"}, status=500)

