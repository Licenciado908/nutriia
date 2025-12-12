from http.client import HTTPException
from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from fastapi import Depends, HTTPException, status

from app.api.deps import get_db
from app.api.deps_auth import get_current_user  # 👈 AQUÍ ESTÁ get_current_user
from app.models.patient import Patient
from app.models.user import User
from app.schemas.patient import PatientResponse
from app import models, schemas

router = APIRouter(prefix="/patients", tags=["patients"])


@router.get("/", response_model=List[PatientResponse])
def list_my_patients(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    # Solo nutricionistas consultan sus pacientes
    if current_user.role != "nutricionista":
        return []

    patients = (
        db.query(Patient)
        .filter(Patient.nutritionist_id == current_user.id)
        .order_by(Patient.id.desc())
        .all()
    )
    return patients

@router.get("/{patient_id}/indicators", response_model=List[schemas.PatientIndicatorOut])
def list_indicators(
    patient_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    if current_user.role != "nutricionista":
        raise HTTPException(status_code=403, detail="Solo nutricionistas")

    patient = db.query(models.Patient).filter(models.Patient.id == patient_id).first()
    if not patient:
        raise HTTPException(status_code=404, detail="Paciente no encontrado")

    # Seguridad: el paciente debe pertenecer a este nutricionista
    if patient.nutritionist_id != current_user.id:
        raise HTTPException(status_code=403, detail="No tienes acceso a este paciente")

    indicators = (
        db.query(models.PatientIndicator)
        .filter(models.PatientIndicator.patient_id == patient_id)
        .order_by(models.PatientIndicator.created_at.desc())
        .all()
    )
    return indicators


@router.post(
    "/{patient_id}/indicators",
    response_model=schemas.PatientIndicatorOut,
    status_code=status.HTTP_201_CREATED
)
def create_indicator(
    patient_id: int,
    payload: schemas.PatientIndicatorCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    if current_user.role != "nutricionista":
        raise HTTPException(status_code=403, detail="Solo nutricionistas")

    patient = db.query(models.Patient).filter(models.Patient.id == patient_id).first()
    if not patient:
        raise HTTPException(status_code=404, detail="Paciente no encontrado")

    if patient.nutritionist_id != current_user.id:
        raise HTTPException(status_code=403, detail="No tienes acceso a este paciente")

    ind = models.PatientIndicator(
        patient_id=patient_id,
        weight=payload.weight,
        bmi=payload.bmi,
        fat_percent=payload.fat_percent,
        note=payload.note,
    )
    db.add(ind)
    db.commit()
    db.refresh(ind)
    return ind

