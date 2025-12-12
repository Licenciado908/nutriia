from datetime import timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_db
from app.core.security import (
    create_access_token,
    get_password_hash,
    verify_password,
    ACCESS_TOKEN_EXPIRE_MINUTES,
)
from app.models.user import User
from app.models.patient import Patient
from app.schemas.user import (
    UserCreate,
    UserLogin,
    UserResponse,
    NutritionistRegisterRequest,
    PatientRegisterRequest,
)

router = APIRouter(
    prefix="/auth",
    tags=["auth"],
)


# =======================
# REGISTRO GENERICO (si ya lo usas)
# =======================
@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def register(user_in: UserCreate, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.email == user_in.email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Ya existe un usuario con este email.",
        )

    hashed = get_password_hash(user_in.password)
    user = User(
        full_name=user_in.full_name,
        email=user_in.email,
        hashed_password=hashed,
        role=user_in.role,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


# =======================
# REGISTRO DE NUTRICIONISTA
# =======================
@router.post(
    "/register-nutri",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
)
def register_nutritionist(
    data: NutritionistRegisterRequest,
    db: Session = Depends(get_db),
):
    existing = db.query(User).filter(User.email == data.email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Ya existe un usuario con este email.",
        )

    hashed = get_password_hash(data.password)
    user = User(
        full_name=data.full_name,
        email=data.email,
        hashed_password=hashed,
        role="nutricionista",
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


# =======================
# REGISTRO DE PACIENTE
# =======================

from datetime import timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_db
from app.core.security import (
    create_access_token,
    get_password_hash,
    verify_password,
    ACCESS_TOKEN_EXPIRE_MINUTES,
)
from app.models.user import User
from app.models.patient import Patient
from app.schemas.user import (
    UserCreate,
    UserLogin,
    UserResponse,
    NutritionistRegisterRequest,
    PatientRegisterRequest,
)

router = APIRouter(
    prefix="/auth",
    tags=["auth"],
)

# ... register, register-nutri, login, etc. ...

@router.post(
    "/register-patient",
    status_code=status.HTTP_201_CREATED,
)
def register_patient(
    data: PatientRegisterRequest,
    db: Session = Depends(get_db),
):
    # 1. Verificar que el email del paciente no exista
    existing = db.query(User).filter(User.email == data.email).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Ya existe un usuario con este email.",
        )

    # 2. Buscar al nutricionista por email y rol
    nutritionist = (
        db.query(User)
        .filter(
            User.email == data.nutritionist_email,
            User.role == "nutricionista",
        )
        .first()
    )
    if not nutritionist:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Nutricionista no encontrado con ese email.",
        )

    try:
        # 3. Crear el usuario paciente (SIN commit aún)
        hashed = get_password_hash(data.password)
        user_paciente = User(
            full_name=data.full_name,
            email=data.email,
            hashed_password=hashed,
            role="paciente",
        )
        db.add(user_paciente)
        db.flush()  # ya tiene id, pero sin commit definitivo

        # 4. Crear el patient asociado
        patient = Patient(
            user_id=user_paciente.id,
            nutritionist_id=nutritionist.id,
            full_name=data.full_name,
            email=data.email,
            # el resto de campos opcionales se pueden dejar como None
        )
        db.add(patient)

        # 5. Commit conjunto
        db.commit()
        db.refresh(user_paciente)
        db.refresh(patient)

    except Exception as e:
        db.rollback()
        print("ERROR en register_patient:", e)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al registrar el paciente.",
        )

    return {
        "user": {
            "id": user_paciente.id,
            "full_name": user_paciente.full_name,
            "email": user_paciente.email,
            "role": user_paciente.role,
        },
        "patient": {
            "id": patient.id,
            "user_id": patient.user_id,
            "nutritionist_id": patient.nutritionist_id,
        },
    }


# =======================
# LOGIN (igual que antes)
# =======================
@router.post("/login")
def login(user_in: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == user_in.email).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email o contraseña incorrectos.",
        )

    if not verify_password(user_in.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email o contraseña incorrectos.",
        )

    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)

    token = create_access_token(
        data={"sub": str(user.id), "role": user.role},
        expires_delta=access_token_expires,
    )

    return {
      "access_token": token,
      "token_type": "bearer",
      "user": {
          "id": user.id,
          "full_name": user.full_name,
          "email": user.email,
          "role": user.role,
      },
    }
