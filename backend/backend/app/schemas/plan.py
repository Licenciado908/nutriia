from pydantic import BaseModel, ConfigDict
from typing import Optional


class PlanCreateRequest(BaseModel):
    patient_id: int
    objetivos: Optional[str] = None


class PlanResponse(BaseModel):
    id: int
    patient_id: int
    objetivos: Optional[str] = None
    contenido: str
    tipo: str

    # Reemplaza orm_mode por from_attributes
    model_config = ConfigDict(from_attributes=True)
