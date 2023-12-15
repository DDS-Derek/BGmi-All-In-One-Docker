#!/usr/bin/python
# coding=utf-8

import os, json


class savable_set(set):
    file_path = ''

    def __init__(self, file_path, **param):
        self.file_path = file_path
        super(savable_set, self).__init__()
        self.load()

    def save(self):
        try:
            with open(file=self.file_path, mode='w') as fp:
                json.dump(list(self), fp)
        except EnvironmentError:
            pass
        pass

    def add(self, element):
        r = super(savable_set, self).add(element)
        self.save()
        return r

    def remove(self, element):
        r = super(savable_set, self).remove(element)
        self.save()
        return r

    def load(self):
        try:
            with open(file=self.file_path) as fp:
                load_set = json.load(fp)
        except EnvironmentError:
            load_set = []
        except json.JSONDecodeError:
            load_set = []
            pass

        self.clear()
        for item in load_set:
            self.add(item)
        pass
    pass


channel_set = savable_set(os.environ.get('DATA_PATH', './data') + '/channel_set.json')
group_set = savable_set(os.environ.get('DATA_PATH', './data') + '/group_set.json')
