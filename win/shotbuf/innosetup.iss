[Setup]
AppName=Shotbuf
AppVerName=Shotbuf v 1.0
DefaultDirName={pf}\Shotbuf
OutputDir=.
Compression=lzma/ultra
InternalCompressLevel=ultra
SolidCompression=yes

[Files]
Source: dist\shotbuf_desktop\*; DestDir: "{app}"; Permissions: everyone-modify

[Run]
Filename: "{app}\shotbuf_desktop.exe"; Description: "Launch application"; Flags: postinstall nowait skipifsilent
