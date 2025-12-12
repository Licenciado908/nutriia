from datetime import date
from pydantic import BaseModel, EmailStr
from typing import Optional


class PatientBase(BaseModel):
    full_name: str
    email: Optional[EmailStr] = None
    fecha_nacimiento: Optional[date] = None
    genero: Optional[str] = None
    altura_cm: Optional[int] = None
    peso_kg: Optional[float] = None
    condiciones_medicas: Optional[str] = None


class PatientCreate(PatientBase):
    pass


class PatientResponse(PatientBase):
    id: int
    user_id: int
    nutritionist_id: int

    class Config:
        orm_mode = True
