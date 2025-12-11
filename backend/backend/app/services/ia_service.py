import google.generativeai as genai
import os
import json
import random # <--- Necesario para la función antigua
import time   # <--- Necesario para la función antigua
from dotenv import load_dotenv

# Cargar variables
load_dotenv()

api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    print("ADVERTENCIA: No se encontró GEMINI_API_KEY")

genai.configure(api_key=api_key)

class IAServiceError(Exception):
    pass

# --- FUNCIÓN NUEVA (CÁMARA / GEMINI VISION) ---
def analizar_comida_con_gemini(image_bytes: bytes) -> dict:
    """
    Envía una imagen a Gemini 1.5 Flash para estimar calorías.
    """
    try:
        model = genai.GenerativeModel('gemini-1.5-flash')
        prompt = """
        Eres un nutricionista experto y un sistema de visión artificial.
        Analiza esta imagen de comida. Identifica qué es y estima sus valores nutricionales.
        
        IMPORTANTE: Tu respuesta DEBE ser SOLAMENTE un objeto JSON válido.
        El formato JSON debe ser exactamente así:
        {
            "name": "Nombre corto del plato",
            "calories": 0,
            "protein": 0.0,
            "carbs": 0.0,
            "fats": 0.0
        }
        Si la imagen no es comida, devuelve "name": "Error".
        """

        image_part = {"mime_type": "image/jpeg", "data": image_bytes}
        response = model.generate_content([prompt, image_part])

        clean_text = response.text.replace("```json", "").replace("```", "").strip()
        return json.loads(clean_text)

    except Exception as e:
        print(f"Error Gemini: {e}")
        raise IAServiceError(f"Error procesando imagen: {str(e)}")


# --- FUNCIÓN ANTIGUA (GENERADOR DE PLANES) ---
# ¡Esta es la que faltaba y causaba el error!
def generar_plan_con_ia(patient_id: int, objetivos: str | None) -> str:
    """
    Stub de IA para generar planes de dieta.
    """
    # Simulación simple para que no falle el resto del sistema
    objetivos_text = objetivos or "mejorar hábitos"
    return f"""
    PLAN SEMANAL PARA PACIENTE {patient_id}
    Objetivos: {objetivos_text}
    
    Lunes: Desayuno avena, Almuerzo Pollo.
    Martes: ...
    (Generado por NutriIA)
    """

def generar_plan_lite(patient_id: int, objetivos: str | None) -> str:
    return f"Plan Lite para {patient_id}: Comer frutas y verduras."