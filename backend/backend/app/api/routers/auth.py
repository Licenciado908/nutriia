from datetime import timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.deps import get_db
from app.models.user import User
from app.schemas.user import UserCreate, UserLogin, UserResponse
from app.core.security import (
    create_access_token,
    hash_password,
    verify_password,
    ACCESS_TOKEN_EXPIRE_MINUTES
)

router = APIRouter(prefix="/auth", tags=["auth"])


# ============================
# REGISTRO DE USUARIO
# ============================
@router.post("/register", response_model=UserResponse)
def register(user_in: UserCreate, db: Session = Depends(get_db)):
    # ¿Usuario ya existe?
    existing_user = db.query(User).filter(User.email == user_in.email).first()
    if existing_user:
        raise HTTPException(
            status_code=400,
            detail="Ya existe un usuario registrado con este email.",
        )

    hashed = hash_password(user_in.password)

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


# ============================
# LOGIN
# ============================
@router.post("/login")
def login(user_in: UserLogin, db: Session = Depends(get_db)):
    # Buscar usuario
    user = db.query(User).filter(User.email == user_in.email).first()

    if not user:
        raise HTTPException(status_code=401, detail="Email o contraseña incorrectos.")

    if not verify_password(user_in.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Email o contraseña incorrectos.")

    # Crear el token
    token = create_access_token(
        data={"sub": str(user.id), "role": user.role},
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    )

    return {
        "access_token": token,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "full_name": user.full_name,
            "email": user.email,
            "role": user.role,
        }
    }
