# backend/app/api/routers/plans.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_db
from app.api.deps_auth import get_current_user   # 👈 AQUI IMPORTAS get_current_user

from app.models.patient import Patient
from app.models.plan import Plan
from app.models.user import User                 # 👈 para tipar current_user

from app.schemas.plan import PlanCreateRequest, PlanResponse
from app.services.ia_service import (
    generar_plan_con_ia,
    generar_plan_lite,
    IAServiceError,
)

router = APIRouter(prefix="/planes", tags=["planes"])


@router.post("/", response_model=PlanResponse, status_code=status.HTTP_201_CREATED)
def crear_plan(
    request: PlanCreateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),   # 👈 AQUI USAS LA DEPENDENCIA
):
    """
    Crea un plan nutricional para un paciente, usando IA + fallback LITE.
    Solo usuarios autenticados pueden usar este endpoint.
    """

    # (Opcional) restringir por rol
    if current_user.role not in ("nutricionista", "admin"):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="No tienes permisos para generar planes.",
        )

    # Verificamos que el paciente exista
    patient = db.query(Patient).filter(Patient.id == request.patient_id).first()
    if not patient:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Paciente no encontrado",
        )

    contenido = None
    tipo = "IA"

    try:
        contenido = generar_plan_con_ia(request.patient_id, request.objetivos)
    except IAServiceError:
        try:
            contenido = generar_plan_lite(request.patient_id, request.objetivos)
            tipo = "LITE"
        except Exception:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail=(
                    "Servicio de generación de planes no disponible. "
                    "Por favor genere el plan manualmente."
                ),
            )

    plan = Plan(
        patient_id=request.patient_id,
        objetivos=request.objetivos,
        contenido=contenido,
        tipo=tipo,
    )
    db.add(plan)
    db.commit()
    db.refresh(plan)

    return plan
