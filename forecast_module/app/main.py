# main.py
from fastapi import FastAPI
from app.api import forecast, detail, redis
from app.dependencies.redis_init import init_redis
from fastapi.middleware.cors import CORSMiddleware
import asyncio

origins = [
    "http://localhost:5173",   # vite dev server
    "http://127.0.0.1:5173",
    "http://localhost:4173",   # vite preview / prod test
    "http://127.0.0.1:4173",
    "http://localhost",
    "http://localhost:80",
    "http://18.144.2.70",
    "*"  # For development, allow all origins
]

app = FastAPI()

@app.on_event("startup")
async def startup_event():
    await init_redis()

app.include_router(forecast.router, prefix="/forecast", tags=["Forecast"])
app.include_router(detail.router, prefix="/detail", tags=["Detail"])
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
    allow_credentials=True,
)
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)