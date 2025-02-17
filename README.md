
# PRUEBA TÉCNICA / SISTEMA DE GESTIÓN DE ROLES Y PERMISOS

## Modelo Relacional
![Modelo Relacional](https://github.com/user-attachments/assets/c8c2ebcb-376d-4bfb-b43d-66e0efdf13a5)

## Sobre el Proyecto
Prueba técnica sobre la creación y gestión de roles y permisos en un sistema ficticio de **Nómina**, en el que toda la lógica del negocio se realiza mediante **procedimientos almacenados en SQL Server**, validando parámetros basados en el rol y los permisos específicos de un usuario.

## Tecnologías
<div align="center">
  <img src="https://img.shields.io/badge/SQL-000000?style=for-the-badge&logo=postgresql&logoColor=white" alt="SQL" />
  <img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python" />
</div>

## Creación de Base de Datos y Procedimientos Almacenados
`Visualizar documentación SQL añadida al repositorio`

## Clonar el Repositorio
```bash
git clone https://github.com/BarbadeProgramador/QualityTest-SQL
```

## Instalación de Dependencias Django
```bash
pip install -r requirements.txt
```

## Ejecución del Servidor Django
```bash
python manage.py runserver
```

## Endpoints

1. **Visualización de Empleados**: 
   - `GET` - `http://127.0.0.1:8000/api/ver-empleados/:id`
   
2. **Visualización de Pagos**:  
   - `GET` - `http://127.0.0.1:8000/api/ver-pagos/:id`

## Video Explicativo
[Ver video explicativo](https://www.youtube.com/watch?v=sw5mlMsb6-8&ab_channel=SebastianRodriguez)

> [!IMPORTANT]
> **Las claves primarias** expuestas en la documentación pueden cambiar según los valores autoincrementales asignados al momento de insertar la información en un entorno nuevo.
