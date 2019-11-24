#!/usr/bin/env python
  
import logging
import sys
logging.basicConfig(stream=sys.stderr)
sys.path.insert(0, '/var/www/html/api/')
from rest import rest as application
