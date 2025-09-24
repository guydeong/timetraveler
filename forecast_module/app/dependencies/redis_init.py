import os
from redis.asyncio import Redis

r = Redis(
    host='redis',
    port=6379,
    db=0,
    password=os.getenv('REDIS_PASSWORD')
)

async def init_redis():
    try:
        await r.ping()
        print("Successfully connected to Redis")
    except Exception as e:
        print(f"Failed to connect to Redis: {e}")
        raise