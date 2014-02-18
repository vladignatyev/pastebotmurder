# -*- mode: python -*-
a = Analysis(['ShotBuf.py'],
             pathex=['c:\\Documents and Settings\\nep\\Projects\\pastebotmurder\\win\\shotbuf'],
             hiddenimports=[],
             hookspath=None,
             runtime_hooks=None)
a.datas += [('active.png', 'active.png', 'DATA')]
a.datas += [('inactive.png', 'inactive.png', 'DATA')]
a.datas += [('trusted-certs.crt', 'trusted-certs.crt', 'DATA')]
a.datas += [('welcome.png', 'welcome.png', 'DATA')]
a.datas += [('dropbox.png', 'dropbox.png', 'DATA')]
pyz = PYZ(a.pure)
exe = EXE(pyz,
          a.scripts,
          exclude_binaries=True,
          name='ShotBuf.exe',
          debug=False,
          strip=None,
          upx=True,
          console=False , icon='icon_app.ico')
coll = COLLECT(exe,
               a.binaries,
               a.zipfiles,
               a.datas,
               strip=None,
               upx=True,
               name='ShotBuf')
