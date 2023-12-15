# coding=utf-8
from tgbot import bot
from msg_handler import msg_handler
from scheduler.NewBangumiScheduler import schedulers
import asyncio


def main():
    handler = msg_handler(bot=bot)
    loop = asyncio.get_event_loop()
    loop.create_task(handler.start_polling())
    schedulers.start()
    loop.run_forever()


if __name__ == '__main__':
    main()
