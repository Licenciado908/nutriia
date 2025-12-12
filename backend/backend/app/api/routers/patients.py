from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_db
from app.api.deps_auth import get_current_user  # 👈 AQUÍ ESTÁ get_current_user
from app.models.patient import Patient
from app.models.user import User
from app.schemas.patient import PatientResponse

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
