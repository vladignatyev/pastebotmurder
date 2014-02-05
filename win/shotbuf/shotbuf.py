import subprocess
import sys
from shotbuf_desktop import main as desktop_main
from shotbuf_web import init_db as init_token_storage

init_token_storage()
#theproc = subprocess.Popen([sys.executable, "shotbuf_web.py"])
desktop_main()

