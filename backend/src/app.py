from contextlib import asynccontextmanager

import uvicorn
from fastapi import FastAPI

from src.chat import http as chat_http


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield


app = FastAPI(lifespan=lifespan)

app.include_router(chat_http.router)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
