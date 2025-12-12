from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship

from app.db.base_class import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    role = Column(String, nullable=False)  # "nutricionista" o "paciente"

    # Un usuario-paciente tiene 1 perfil de Patient
    patient_profile = relationship(
        "Patient",
        back_populates="user",
        uselist=False,
        foreign_keys="Patient.user_id",
    )

    # Un usuario-nutricionista tiene muchos pacientes
    patients = relationship(
        "Patient",
        back_populates="nutritionist",
        foreign_keys="Patient.nutritionist_id",
    )

    # ✅ Relación: un usuario (paciente) tiene muchas comidas
    meals = relationship(
        "Meal",
        back_populates="user",
        cascade="all, delete-orphan",
    )
