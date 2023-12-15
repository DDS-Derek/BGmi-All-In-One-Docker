# coding=utf-8

import os
import logging
import types
import json
import asyncio
import aiohttp
import common
from aiogram import Dispatcher, Bot as TGBot, types as TGTypes
from utils import channel_set, group_set
from aiohttp import ClientSession


class msg_handler(Dispatcher):

    def __init__(self, **config_object):
        super(msg_handler, self).__init__(**config_object)
        self.logger = logging.getLogger(__class__.__name__)
        self.admin_command_handler = admin_command_handler(self.bot)
        self.public_command_handler = public_command_handler(self.bot)
        self.user = None

        loop = asyncio.get_event_loop()
        loop.run_until_complete(self.register_command_list())

        @self.channel_post_handler()
        @self.message_handler()
        async def handle_msg(context):
            message = str(context['text'])
            if not message.startswith('/'):
                return
            if message.endswith('@' + (await self.bot.me).username):
                message = message[:-len('@'+(await self.bot.me).username)]
            message = message[1:]
            cmd = message.split(' ')
            method_name = cmd[0]
            params = cmd[1:]

            is_admin = self.is_admin(context=context)

            if not self.should_reply_command(is_admin=is_admin, context=context):
                return

            self.logger.debug("calling %s" % method_name)
            method = self.get_command_method(method_name, is_admin=is_admin)
            if not callable(method) or not isinstance(method, types.MethodType):
                await self.bot.send_message(
                    chat_id=context['chat']['id'],
                    reply_to_message_id=context['message_id'],
                    text="command %s not exist" % method_name
                )
                return

            await method(context, params)

    async def register_command_list(self):
        handler = self.public_command_handler
        command_list = [
            TGTypes.BotCommand(command=method_name, description=getattr(handler, method_name).__doc__) for method_name in dir(handler)
            if not method_name.startswith('_') and callable(getattr(handler, method_name))
        ]
        self.logger.debug(command_list)
        await self.bot.set_my_commands(commands=command_list)


    def should_reply_command(self, is_admin, context):
        self.logger.debug("should_reply_command: is_admin=%s" % is_admin)
        if is_admin:
            return True

        enable_public_command = common.enable_public_command
        if enable_public_command == 'Always':
            return True
        if not is_admin and enable_public_command == 'Never':
            return False

        if not is_admin and enable_public_command == 'Subscriber':
            message_type = str(context['chat']['type'])
            chat_id = str(context['chat']['id'])
            if (message_type == 'channel') and (chat_id in channel_set):
                return True
            if (message_type == 'group') and (chat_id in group_set):
                return True
            if message_type == 'private':
                return True
            return False

        self.logger.debug("should_reply_command trapped in unexpected condition")
        return False

    def is_admin(self, context):
        # channel dont grant admin privileges
        if context['chat']['type'] == 'channel':
            return False

        admin = common.admin_user
        if str(context['from']['username']) != str(admin):
            self.logger.debug("user: %s not admin(%s)" % (context['from']['username'], admin))
            return False
        self.logger.debug("user: %s is admin(%s) √" % (context['from']['username'], admin))
        return True

    def get_command_method(self, item, is_admin=False):
        try:
            method = getattr(self.public_command_handler, item)
        except AttributeError:
            method = None
        self.logger.debug("method: %s from public_command_handler type is %s" % (item, type(method).__name__))
        if is_admin and not isinstance(method, types.MethodType):
            try:
                method = getattr(self.admin_command_handler, item)
            except AttributeError:
                method = None
            self.logger.debug("method: %s from admin_command_handler type is %s" % (item, type(method).__name__))
        return method


class admin_command_handler:
    def __init__(self, tgbot: TGBot):
        self.tgbot = tgbot
        self.logger = logging.getLogger(__class__.__name__)

    async def set(self, context, params):
        message_type = str(context['chat']['type'])
        chat_id = str(context['chat']['id'])

        if message_type == 'group':
            group_set.add(chat_id)
            await self.send_message(
                chat_id=context['chat']['id'],
                reply_to_message_id=context['message_id'],
                text='group %s add to subscript list' % chat_id
            )
        pass

    async def addchannel(self, context, params):
        chat_id = str(context['chat']['id'])
        if len(params) < 1:
            await self.send_message(
                chat_id=context['chat']['id'],
                reply_to_message_id=context['message_id'],
                text='Usage: /addchannel <@channelUserName> [<@channelUserName> <@channelUserName> ...]'
            )
            return
        id_list = params
        added_list = []
        for _id in id_list:
            if not _id.startswith('@'):
                continue
            channel_set.add(_id)
            added_list.append(_id)
            pass
        await self.send_message(
            chat_id=chat_id,
            reply_to_message_id=context['message_id'],
            text='add channel %s' % (','.join(id_list)) if len(added_list) != 0 else 'nothing to add'
        )
        pass

    async def getlist(self, context, params):
        await self.send_message(
            chat_id=context['chat']['id'],
            reply_to_message_id=context['message_id'],
            text='channel subscript list:\n %s' % ('\n'.join(channel_set))
        )

        group_list_msgs = []
        for group_id in group_set:
            chat = await self.get_chat(chat_id=group_id)  # TODO: add cache
            self.logger.debug(chat)

            group_list_msgs.append('%s:\t%s' % (group_id, chat['title']))

        await self.send_message(
            chat_id=context['chat']['id'],
            reply_to_message_id=context['message_id'],
            text='group subscript list: \n %s' % ('\n'.join(group_list_msgs))
        )
        pass

    async def remove(self, context, params):
        if len(params) < 2:
            await self.send_message(
                chat_id=context['chat']['id'],
                reply_to_message_id=context['message_id'],
                text='Usage: /remove <channel/group> <id> [<id> <id> ...]'
            )
            return
        list_name = params[0]
        id_list = params[1:]
        if list_name == 'channel':
            for _id in id_list:
                if _id in channel_set:
                    channel_set.remove(_id)
                pass
            await self.send_message(
                chat_id=context['chat']['id'],
                reply_to_message_id=context['message_id'],
                text='deleted channel %s' % (','.join(id_list))
            )
            pass
        if list_name == 'group':
            for _id in id_list:
                if _id in group_set:
                    group_set.remove(_id)
                pass
            await self.send_message(
                chat_id=context['chat']['id'],
                reply_to_message_id=context['message_id'],
                text='deleted group %s' % (','.join(id_list))
            )
            pass

    def __getattr__(self, name):
        return getattr(self.tgbot, name)


class public_command_handler:
    def __init__(self, tgbot: TGBot):
        self.tgbot = tgbot
        self.logger = logging.getLogger(__class__.__name__)

    async def ping(self, context, params):
        """ping"""
        await self.send_message(
            chat_id=context['chat']['id'],
            reply_to_message_id=context['message_id'],
            text='pong'
        )

    async def status(self, context, params):
        """获取番剧订阅状态"""
        api_url = common.bgmi_base_url + '/api/index'
        self.logger.debug('checking status...')

        try:
            async with ClientSession() as client:
                content = await fetch(client, api_url)
        except asyncio.TimeoutError as _:
            await self.send_message(
                chat_id=context['chat']['id'],
                reply_to_message_id=context['message_id'],
                text='bgmi api fetch timeout!'
            )
            return
        except (
                aiohttp.client_exceptions.ClientConnectionError,
                ConnectionError,
                ConnectionAbortedError,
                ConnectionRefusedError,
                ConnectionResetError
        ) as _:
            await self.send_message(
                chat_id=context['chat']['id'],
                reply_to_message_id=context['message_id'],
                text='bgmi api connect failed!'
            )
            return

        json.loads(content)
        api_data = json.loads(content)

        current_bangumi_episode = ["%s[%s]" % (bangumi['bangumi_name'], bangumi['episode']) for bangumi in
                                   api_data['data']]

        message = "当前订阅的番剧有:\n" \
                  "%s" % ('\n'.join(current_bangumi_episode))

        await self.send_message(
            chat_id=context['chat']['id'],
            reply_to_message_id=context['message_id'],
            text=message
        )

    def __getattr__(self, name):
        return getattr(self.tgbot, name)


async def fetch(client: ClientSession, url):
    async with client.get(url=url) as resp:
        assert resp.status == 200
        return await resp.text()
