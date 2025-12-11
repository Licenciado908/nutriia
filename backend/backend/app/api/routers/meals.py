from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File # <--- FALTABA AGREGAR UploadFile y File AQUÍ
from sqlalchemy.orm import Session
from typing import List

# 1. IMPORTAR TUS MODELOS Y ESQUEMAS
from app.models.meal import Meal
from app.models.user import User
from app.schemas.meal import MealCreate, MealResponse

# 2. IMPORTAR DEPENDENCIAS
from app.api.deps import get_db

# Ajustamos la importación de Auth: Traemos 'get_current_active_user' y lo renombramos a 'get_current_user' para usarlo fácil
from app.api.deps_auth import get_current_active_user as get_current_user

# 3. SERVICIOS
from app.services.ia_service import analizar_comida_con_gemini

router = APIRouter()

# --- ENDPOINT 1: OBTENER HISTORIAL (GET) ---
@router.get("/", response_model=List[MealResponse])
def read_my_meals(
        skip: int = 0,
        limit: int = 100,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user),
):
    """
    Obtiene el historial de comidas del usuario logueado.
    """
    meals = db.query(Meal).filter(Meal.user_id == current_user.id) \
        .order_by(Meal.created_at.desc()) \
        .offset(skip).limit(limit).all()
    return meals

# --- ENDPOINT 2: REGISTRAR COMIDA (POST) ---
@router.post("/", response_model=MealResponse)
def create_meal(
        meal_in: MealCreate,
        db: Session = Depends(get_db),
        current_user: User = Depends(get_current_user),
):
    """
    Guarda una nueva comida en la base de datos.
    """
    new_meal = Meal(
        **meal_in.dict(),
        user_id=current_user.id
    )

    db.add(new_meal)
    db.commit()
    db.refresh(new_meal)
    return new_meal

# --- ENDPOINT 3: ANALIZAR FOTO CON IA (POST) ---
@router.post("/analyze", response_model=dict)
async def analyze_meal_photo(
        file: UploadFile = File(...), # Ahora sí funcionará porque importamos File y UploadFile
        current_user: User = Depends(get_current_user),
):
    """
    Recibe una imagen, la envía a Gemini y devuelve la estimación nutricional.
    NO guarda en base de datos todavía, solo analiza.
    """
    # Validar que sea imagen
    if not file.content_type.startswith("image/"):
        raise HTTPException(400, detail="El archivo debe ser una imagen")

    # Leer bytes
    contents = await file.read()

    try:
        # Llamar a nuestro servicio de IA
        data = analizar_comida_con_gemini(contents)

        # Validación básica de la respuesta de la IA
        if "Error" in data.get("name", ""):
            raise HTTPException(400, detail="No se detectó comida válida en la imagen")

        return data

    except Exception as e:
        # Imprimir el error en consola para que puedas depurarlo si falla
        print(f"Error en endpoint analyze: {e}")
        raise HTTPException(500, detail=str(e))