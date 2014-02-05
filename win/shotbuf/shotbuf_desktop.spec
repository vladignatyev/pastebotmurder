# -*- mode: python -*-
a = Analysis(['shotbuf_desktop.py'],
             pathex=['c:\\Users\\varuzhnikov\\Projects\\pastebotmurder\\win\\shotbuf'],
             hiddenimports=[],
             hookspath=None,
             runtime_hooks=None)
a.datas += [('statusbaricon.png', 'statusbaricon.png', 'DATA')]
a.datas += [('trusted-certs.crt', 'trusted-certs.crt', 'DATA')]
pyz = PYZ(a.pure)
exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          name='shotbuf_desktop.exe',
          debug=False,
          strip=None,
          upx=True,
          console=False )
