from rest_framework import serializers


class NominaSerializer(serializers.Serializer):
    nombre = serializers.CharField()
    nit = serializers.CharField()
    charge = serializers.CharField()
    area = serializers.CharField()
    payment_day = serializers.DateField()
    salary = serializers.FloatField()


class EmployeeSerializer(serializers.Serializer):
    nombre = serializers.CharField()
    nit = serializers.CharField()
    email = serializers.EmailField()
    charge = serializers.CharField()
    departamento = serializers.CharField()
    area = serializers.CharField()
