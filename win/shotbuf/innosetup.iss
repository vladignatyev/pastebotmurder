[Setup]
AppName=ShotBuf
AppVerName=ShotBuf v 1.2.0
AppVersion=1.2.0
DefaultDirName={pf}\ShotBuf
OutputDir=.
Compression=lzma/ultra
InternalCompressLevel=ultra
SolidCompression=yes

[Files]                                           
Source: dist\Shotbuf\*; DestDir: "{app}";Flags: recursesubdirs

[Setup]
PrivilegesRequired=admin
DisableProgramGroupPage=yes

[Icons] 
Name: "{commonprograms}\Shotbuf"; Filename: "{app}\ShotBuf.exe"; WorkingDir: "{app}"
Name: "{commonstartup}\Shotbuf"; Filename: "{app}\ShotBuf.exe"; WorkingDir: "{app}"
                                        

[Registry]
Root: HKLM; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "Shotbuf"; ValueData: """{app}\shotbuf_desktop.exe"""; Flags: uninsdeletevalue

[Run]
Filename: "{app}\ShotBuf.exe"; Description: "Launch application"; Flags: postinstall nowait skipifsilent