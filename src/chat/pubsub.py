import asyncio
import logging
from typing import Any, Awaitable, Callable, Protocol

import redis.asyncio as redis

from src.settings import settings


class PubSub(Protocol):
    async def subscribe(
        self,
        channel: str,
        callback: Callable[[dict[str, Any]], Awaitable[Any]],
    ): ...

    async def publish(self, channel: str, message: str): ...

    async def close(self): ...


class RedisPubSub:
    def __init__(self, host: str, port: str) -> None:
        self.redis_url: str = f"redis://{host}:{port}"
        self.redis_client: redis.Redis = redis.from_url(self.redis_url)
        self.pubsub = self.redis_client.pubsub()

        self._tasks: list[asyncio.Task[None]] = []

    async def subscribe(
        self,
        channel: str,
        callback: Callable[[dict[str, Any]], Awaitable[Any]],
    ):
        await self.pubsub.subscribe(channel)

        async def reader():
            try:
                async for message in self.pubsub.listen():
                    await callback(message)
            except asyncio.CancelledError:
                logging.info("Task cancelled")
            except Exception:
                logging.exception("pubsub reader error")

        self._tasks.append(asyncio.create_task(reader()))

    async def publish(self, channel: str, message: str):
        await self.redis_client.publish(channel=channel, message=message)

    async def close(self):
        for task in self._tasks:
            task.cancel()

        await asyncio.gather(*self._tasks, return_exceptions=True)

        try:
            await self.pubsub.close()
        except Exception:
            logging.exception("Error during closing pubsub.")

        try:
            await self.redis_client.close()
        except Exception:
            logging.exception("Error ducint closing Redis client")


async def get_pubsub():
    pubsub = RedisPubSub(
        host=settings.redis_host,
        port=settings.redis_port,
    )
    try:
        yield pubsub
    finally:
        await pubsub.close()
