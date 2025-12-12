from sqlalchemy import Column, Integer, String, Text, ForeignKey
from sqlalchemy.orm import relationship

from app.db.base_class import Base



class Plan(Base):
    __tablename__ = "plans"

    id = Column(Integer, primary_key=True, index=True)

    patient_id = Column(Integer, ForeignKey("patients.id"), nullable=False)

    # ejemplo de campos, ajusta a lo que ya tengas
    title = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    ai_summary = Column(Text, nullable=True)

    # 👇 relación hacia Patient
    patient = relationship("Patient", back_populates="plans")
