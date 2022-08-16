#!/bin/bash

groupmod -o -g "$PGID" abc
usermod -o -u "$PUID" abc

chown -R abc:abc \
	/bgmi

chown abc:abc \
	/media \
	/media/cartoon \
	/media/downloads