from typing import Annotated, Literal

from fastapi import APIRouter, Depends, WebSocket, WebSocketDisconnect
from pydantic import BaseModel, TypeAdapter

from src.chat.service import ChatService, get_chat_service

router = APIRouter(
    prefix="/chat",
    tags=["chat"],
)


class SetNameMessage(BaseModel):
    type: Literal["set_name"]
    name: str


class ChatMessage(BaseModel):
    type: Literal["message"]
    text: str


Message = SetNameMessage | ChatMessage
message_adapter: TypeAdapter[Message] = TypeAdapter(Message)


@router.websocket("/ws")
async def websocket_endpoint(
    websocket: WebSocket,
    connection_manager: Annotated[ChatService, Depends(get_chat_service)],
):
    await connection_manager.connect(websocket)
    try:
        while True:
            data_raw = await websocket.receive_json()
            data = message_adapter.validate_python(data_raw)
            if data.type == "set_name":
                await connection_manager.set_username(websocket, data.name)
                await connection_manager.publish(f"System: {data.name} joined the chat")
            elif data.type == "message":
                username = connection_manager.get_username(websocket)
                await connection_manager.publish(f"{username}: {data.text}")
    except WebSocketDisconnect:
        username = connection_manager.get_username(websocket)
        connection_manager.disconnect(websocket)
        await connection_manager.publish(f"System: {username} left the chat")
