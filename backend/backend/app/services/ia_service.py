import random
import time


class IAServiceError(Exception):
    pass


def generar_plan_con_ia(patient_id: int, objetivos: str | None) -> str:
    """
    Stub de IA real.
    Aquí en el futuro puedes llamar a un modelo LLM (OpenAI, Ollama, etc.)
    o a otro microservicio vía HTTP/gRPC.
    """
    # Simular probabilidad de fallo o timeout
    if random.random() < 0.2:
        # simulamos timeout/fallo
        time.sleep(0.5)
        raise IAServiceError("Fallo en el motor de IA")

    # Plan fake:
    objetivos_text = objetivos or "mejorar hábitos alimenticios"
    return f"""
PLAN SEMANAL (IA) PARA PACIENTE {patient_id}
Objetivos: {objetivos_text}

Lunes: Desayuno con avena, almuerzo pollo a la plancha con ensalada, cena crema de verduras.
Martes: ...
(etc.)
"""


def generar_plan_lite(patient_id: int, objetivos: str | None) -> str:
    """
    Fallback 'lite' más simple y determinístico, por si la IA principal falla.
    """
    objetivos_text = objetivos or "mejorar hábitos alimenticios"
    return f"""
PLAN LITE PARA PACIENTE {patient_id}
Objetivos: {objetivos_text}

Recomendación general:
- Aumentar consumo de frutas y verduras.
- Reducir azúcares refinados y bebidas azucaradas.
- Tomar al menos 8 vasos de agua al día.
- Mantener 3 comidas principales y 2 colaciones ligeras.
"""
