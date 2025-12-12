from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship

from app.db.base_class import Base


class Patient(Base):
    __tablename__ = "patients"

    id = Column(Integer, primary_key=True, index=True)

    # FK al usuario-paciente
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    # FK al usuario-nutricionista
    nutritionist_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    full_name = Column(String, nullable=False)
    email = Column(String, nullable=True)

    # Relación al usuario-paciente
    user = relationship(
        "User",
        back_populates="patient_profile",
        foreign_keys=[user_id],
    )

    # Relación al usuario-nutricionista
    nutritionist = relationship(
        "User",
        back_populates="patients",
        foreign_keys=[nutritionist_id],
    )

    # Relación con planes
    plans = relationship(
        "Plan",
        back_populates="patient",
        cascade="all, delete-orphan",
    )

    # ✅ RELACIÓN CON INDICADORES (AQUÍ ADENTRO)
    indicators = relationship(
        "PatientIndicator",
        back_populates="patient",
        cascade="all, delete-orphan",
    )
