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

[Icons] 
Name: "{commonprograms}\Shotbuf"; Filename: "{app}\shotbuf_desktop.exe"; WorkingDir: "{app}"
Name: "{commonstartup}\Shotbuf"; Filename: "{app}\shotbuf_desktop.exe"; WorkingDir: "{app}"

[Setup]
PrivilegesRequired=admin
DisableProgramGroupPage=yes

[Registry]
Root: HKLM; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "Shotbuf"; ValueData: """{app}\shotbuf_desktop.exe"""; Flags: uninsdeletevalue