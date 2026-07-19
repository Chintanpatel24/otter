; Otter Setup Script
; Inno Setup 6 configuration for the Otter desktop application
; No references to any other project names

#define AppName "Otter"
#define AppVersion "1.0.0"
#define AppPublisher "Otter Team"
#define AppURL "https://github.com/Chintanpatel/otter"
#define AppExeName "otter.exe"

[Setup]
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}
DefaultDirName={autopf}\Otter
DisableProgramGroupPage=yes
OutputDir=output
OutputBaseFilename=otter_setup
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
ArchitecturesAllowed=x64

; Setup icon
SetupIconFile=assets\logo.ico

; License file (optional)
LicenseFile=LICENSE

; Clean minimal wizard
WizardStyle=modern

; No extra tasks, clean install
[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional options"; Flags: unchecked

[Files]
Source: "dist\otter.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "dist\engine.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "assets\logo.png"; DestDir: "{app}\assets"; Flags: ignoreversion
Source: "README.md"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\Otter"; Filename: "{app}\otter.exe"; WorkingDir: "{app}"
Name: "{autodesktop}\Otter"; Filename: "{app}\otter.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\otter.exe"; Description: "Launch Otter"; Flags: nowait postinstall skipifsilent

[Code]
procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpFinished then
  begin
    Log('Installation completed successfully');
  end;
end;
