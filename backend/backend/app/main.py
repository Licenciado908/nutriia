from fastapi import FastAPI

from app.db.base import Base
from app.db.session import engine
from app.api.routers import plans as plans_router
from app.api.routers import patients as patients_router  # 👈 nuevo import
from app.api.routers import auth as auth_router

app = FastAPI(
    title="NutriIA Backend",
    version="0.1.0",
)


@app.on_event("startup")
def on_startup():
    Base.metadata.create_all(bind=engine)


@app.get("/health")
def health_check():
    return {"status": "ok"}


app.include_router(auth_router.router)
app.include_router(patients_router.router)
app.include_router(plans_router.router)