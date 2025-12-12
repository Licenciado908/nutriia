from app.db.base_class import Base

# Importa modelos para registrar tablas (esto NO debe importar Base desde aquí)
from app.models.user import User
from app.models.patient import Patient
from app.models.meal import Meal
from app.models.plan import Plan
from app.models.patientIndicator import PatientIndicator
