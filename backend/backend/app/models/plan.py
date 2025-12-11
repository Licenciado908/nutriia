from sqlalchemy import Column, Integer, String, ForeignKey, Text
from sqlalchemy.orm import relationship

from app.db.base import Base


class Plan(Base):
    __tablename__ = "plans"

    id = Column(Integer, primary_key=True, index=True)
    patient_id = Column(Integer, ForeignKey("patients.id"), nullable=False)

    objetivos = Column(Text, nullable=True)
    contenido = Column(Text, nullable=False)
    tipo = Column(String, default="IA")
    estado = Column(String, default="CREADO")

    patient = relationship("Patient", back_populates="plans")
