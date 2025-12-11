from sqlalchemy import Column, Integer, String, Date, Numeric, Text, ForeignKey
from sqlalchemy.orm import relationship

from app.db.base import Base


class Patient(Base):
    __tablename__ = "patients"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)

    # Campos extra útiles para nutrición
    fecha_nacimiento = Column(Date, nullable=True)
    genero = Column(String, nullable=True)
    altura_cm = Column(Integer, nullable=True)
    peso_kg = Column(Numeric(5, 2), nullable=True)
    condiciones_medicas = Column(Text, nullable=True)

    # Relación con planes
    plans = relationship("Plan", back_populates="patient")
