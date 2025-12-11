from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_db
from app.models.patient import Patient
from app.schemas.patient import PatientCreate, PatientResponse

router = APIRouter(prefix="/patients", tags=["patients"])


@router.post("/", response_model=PatientResponse, status_code=status.HTTP_201_CREATED)
def create_patient(payload: PatientCreate, db: Session = Depends(get_db)):
    # Verificar si ya existe paciente con ese email
    existing = db.query(Patient).filter(Patient.email == payload.email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Ya existe un paciente registrado con este email",
        )

    patient = Patient(
        full_name=payload.full_name,
        email=payload.email,
        fecha_nacimiento=payload.fecha_nacimiento,
        genero=payload.genero,
        altura_cm=payload.altura_cm,
        peso_kg=payload.peso_kg,
        condiciones_medicas=payload.condiciones_medicas,
    )
    db.add(patient)
    db.commit()
    db.refresh(patient)

    return patient


@router.get("/", response_model=List[PatientResponse])
def list_patients(db: Session = Depends(get_db)):
    patients = db.query(Patient).order_by(Patient.id.desc()).all()
    return patients
