from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.db.base_class import Base


class Meal(Base):
    __tablename__ = "meals"

    id = Column(Integer, primary_key=True, index=True)
    # Vinculamos directamente al usuario que se loguea (User.id)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    name = Column(String, index=True, nullable=False)
    calories = Column(Integer, nullable=False)
    protein = Column(Float, default=0.0)
    carbs = Column(Float, default=0.0)
    fats = Column(Float, default=0.0)

    # Aquí guardaremos la URL de la foto que subamos a Gemini luego
    image_url = Column(String, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)

    # Relación inversa (la definiremos en User en el paso 2)
    user = relationship("User", back_populates="meals")