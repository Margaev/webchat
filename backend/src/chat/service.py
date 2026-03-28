from typing import Annotated, Any

from fastapi import Depends, WebSocket

from src.chat.pubsub import PubSub, get_pubsub

REDIS_CHANNEL = "chat"


class ChatService:
    def __init__(self, pubsub: PubSub):
        self.active_connections: list[WebSocket] = []
        self.usernames: dict[WebSocket, str] = {}
        self.pubsub = pubsub

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)
        self.usernames.pop(websocket, None)

    async def set_username(self, websocket: WebSocket, name: str):
        self.usernames[websocket] = name

    def get_username(self, websocket: WebSocket) -> str:
        return self.usernames.get(websocket, "Anonymous")

    async def publish(self, message: str):
        await self.pubsub.publish(REDIS_CHANNEL, message)

    async def broadcast_local(self, message: dict[str, Any]):
        if message is None or message["type"] != "message":
            return
        for ws in self.active_connections:
            try:
                await ws.send_text(message["data"].decode())
            except Exception as e:
                raise e

    async def serve(self):
        await self.pubsub.subscribe(
            channel=REDIS_CHANNEL, callback=self.broadcast_local
        )


async def get_chat_service(
    pubsub: Annotated[PubSub, Depends(get_pubsub)],
) -> ChatService:
    chat_service = ChatService(pubsub)
    await chat_service.serve()
    return chat_service
