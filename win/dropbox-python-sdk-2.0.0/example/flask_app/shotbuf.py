import subprocess
import sys
from shotbuf_desktop import main as desktop_main

theproc = subprocess.Popen([sys.executable, "shotbuf_web.py"])
desktop_main()

