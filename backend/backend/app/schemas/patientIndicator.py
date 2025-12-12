from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class PatientIndicatorCreate(BaseModel):
    weight: float
    bmi: float
    fat_percent: float
    note: Optional[str] = None

class PatientIndicatorOut(BaseModel):
    id: int
    patient_id: int
    weight: float
    bmi: float
    fat_percent: float
    note: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True
