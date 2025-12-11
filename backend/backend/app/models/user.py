from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship # <--- 1. Importar relationship
from app.db.base import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    role = Column(String, nullable=False, default="nutricionista")

    # --- NUEVA LÍNEA ---
    # Usamos "Meal" como string para evitar errores de importación circular
    meals = relationship("Meal", back_populates="user", cascade="all, delete-orphan")