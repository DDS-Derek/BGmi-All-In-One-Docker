#!/usr/bin/env python
# coding=utf-8

import os
import logging
import common
from aiogram import Bot

common.api_token = os.environ.get('api_token', False)
common.proxy_url = os.environ.get('proxy_url', '')
common.admin_user = os.environ.get('admin_user', '')
common.enable_public_command = os.environ.get('enable_public_command', 'Always')
common.error_channel = os.environ.get('error_channel', None)
common.bgmi_base_url = os.environ.get('bgmi_base_url', 'http://127.0.0.1')

loglevel = os.environ.get('log_level', 'ERROR')
logging.basicConfig(level=getattr(logging, loglevel))

bot = Bot(token=common.api_token, proxy=common.proxy_url)


async def seng_message_to_err_channel(text=''):
    if common.error_channel is None:
        return
    return await bot.send_message(chat_id=common.error_channel, text=text)
