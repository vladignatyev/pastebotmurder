#!/usr/bin/env python

import os
import sys
from mixpanel import Mixpanel
from mixpanel_async import AsyncBufferedConsumer

consumer=AsyncBufferedConsumer()
mp = Mixpanel('fd4cf0a7fd2808a85c4ba0ec3b524875', consumer=consumer)

def track_event(event):
	mp.track(None, "WIN:%s" % event)

def resource_path(relative):
    if hasattr(sys, "_MEIPASS"):
        return os.path.join(sys._MEIPASS, relative)
    return os.path.join(relative)