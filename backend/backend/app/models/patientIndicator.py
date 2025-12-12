from datetime import datetime
from sqlalchemy import Column, Integer, Float, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship

from app.db.base_class import Base


class PatientIndicator(Base):
    __tablename__ = "patient_indicators"

    id = Column(Integer, primary_key=True, index=True)
    patient_id = Column(Integer, ForeignKey("patients.id", ondelete="CASCADE"), nullable=False, index=True)

    weight = Column(Float, nullable=False)
    bmi = Column(Float, nullable=False)
    fat_percent = Column(Float, nullable=False)

    note = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)

    patient = relationship("Patient", back_populates="indicators")
