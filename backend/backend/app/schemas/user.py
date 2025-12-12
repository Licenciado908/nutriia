from pydantic import BaseModel, EmailStr


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserCreate(BaseModel):
    full_name: str
    email: EmailStr
    password: str
    role: str


class UserResponse(BaseModel):
    id: int
    full_name: str
    email: EmailStr
    role: str

    class Config:
        orm_mode = True


class NutritionistRegisterRequest(BaseModel):
    full_name: str
    email: EmailStr
    password: str


class PatientRegisterRequest(BaseModel):
    full_name: str
    email: EmailStr
    password: str
    nutritionist_email: EmailStr
