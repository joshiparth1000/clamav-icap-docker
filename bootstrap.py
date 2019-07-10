#!/usr/bin/python3

import os
import logging as log
import sys
import time

log.basicConfig(stream=sys.stderr, level=os.environ.get("LOG_LEVEL", "WARNING"))
logger=log.getLogger(__name__)

if os.path.exists("/tmp/clamd.sock"):
    os.remove("/tmp/clamd.sock")

if not os.path.isfile("/store/main.cvd"):
    logger.info("Initial clam DB download.")
    os.system("freshclam")

logger.info("Schedule freshclam DB updater.")
os.system("freshclam -d -c 6")

logger.info("Run clamav daemon")
os.system("clamd &")

logger.info("Run c-icap")
while not os.path.exists("/tmp/clamd.sock"):
    time.sleep(5)

os.system("/usr/local/c-icap/bin/c-icap -N -D")
