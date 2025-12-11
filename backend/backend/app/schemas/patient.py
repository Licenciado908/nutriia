from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import date


class PatientCreate(BaseModel):
    full_name: str
    email: str
    fecha_nacimiento: Optional[date] = None
    genero: Optional[str] = None
    altura_cm: Optional[int] = None
    peso_kg: Optional[float] = None
    condiciones_medicas: Optional[str] = None


class PatientResponse(BaseModel):
    id: int
    full_name: str
    email: str
    fecha_nacimiento: Optional[date] = None
    genero: Optional[str] = None
    altura_cm: Optional[int] = None
    peso_kg: Optional[float] = None
    condiciones_medicas: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)
