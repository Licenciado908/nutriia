from pydantic import BaseModel
from datetime import datetime
from typing import Optional

# Base común (lo que compartimos al crear y leer)
class MealBase(BaseModel):
    name: str
    calories: int
    protein: float
    carbs: float
    fats: float
    image_url: Optional[str] = None

# Lo que recibimos del Frontend al crear una comida
class MealCreate(MealBase):
    pass

# Lo que devolvemos al Frontend (incluye ID y fecha)
class MealResponse(MealBase):
    id: int
    user_id: int
    created_at: datetime

    class Config:
        from_attributes = True # Necesario para leer desde SQLAlchemy