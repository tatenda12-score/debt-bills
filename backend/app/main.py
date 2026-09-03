from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.routes import auth, financial_records, reminders

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url="/openapi.json",
    description="Financial Reminder Application Backend API",
    version="0.1.0",
)

# Set all CORS enabled origins
if settings.BACKEND_CORS_ORIGINS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
        allow_credentials=(settings.BACKEND_CORS_ORIGINS != ["*"]),
        allow_methods=["*"],
        allow_headers=["*"],
    )

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(financial_records.router, prefix="/financial-records", tags=["financial records"])
app.include_router(reminders.router, tags=["reminders"])
