# -*- mode: python -*-
a = Analysis(['shotbuf_desktop.py'],
             pathex=['c:\\Users\\varuzhnikov\\Projects\\pastebotmurder\\win\\shotbuf'],
             hiddenimports=[],
             hookspath=None,
             runtime_hooks=None)
pyz = PYZ(a.pure)
a.datas += [('statusbaricon.png', 'statusbaricon.png', 'DATA')]
a.datas += [('trusted-certs.crt', 'trusted-certs.crt', 'DATA')]
a.datas += [('storage.txt', 'init_db/storage.txt', 'DATA')]
a.datas += [('shotbuf.log', 'shotbuf.log', 'DATA')]
exe = EXE(pyz,
          a.scripts,
          exclude_binaries=True,
          name='shotbuf_desktop.exe',
          debug=False,
          strip=None,
          upx=True,
          console=False )
coll = COLLECT(exe,
               a.binaries,
               a.zipfiles,
               a.datas,
               strip=None,
               upx=True,
               name='shotbuf_desktop')
