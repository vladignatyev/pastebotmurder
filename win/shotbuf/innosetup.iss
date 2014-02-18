[Setup]
AppName=Shotbuf
AppVerName=Shotbuf v 1.1
AppVersion=1.1
DefaultDirName={pf}\Shotbuf
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