; Inno Setup script — AnalyticMath Lab
; Gera instalador a partir de dist/AnalyticMathLab.exe (PyInstaller).
; Build: python scripts/build_installer.py

#define MyAppName "AnalyticMath Lab"
#define MyAppVersion "0.1.0"
#define MyAppPublisher "AnalyticMath Lab"
#define MyAppExeName "AnalyticMathLab.exe"

; Ícone opcional (descomente quando assets/analyticmath.ico existir):
; #define MyAppIcon "..\assets\analyticmath.ico"

[Setup]
AppId={{A7B3C4D5-E6F7-4890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={localappdata}\Programs\{#MyAppName}
DefaultGroupName={#MyAppName}
OutputDir=output
OutputBaseFilename=AnalyticMathLabSetup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
; Instalação por usuário — não exige administrador
PrivilegesRequired=lowest
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\{#MyAppExeName}
#ifexist "..\assets\analyticmath.ico"
SetupIconFile=..\assets\analyticmath.ico
#endif

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\dist\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\AnalyticMath Lab CLI"; Filename: "{cmd}"; Parameters: "/K ""{app}\{#MyAppExeName}"" --help"; Comment: "Abrir ajuda da CLI do AnalyticMath Lab"
Name: "{autodesktop}\AnalyticMath Lab CLI"; Filename: "{cmd}"; Parameters: "/K ""{app}\{#MyAppExeName}"" --help"; Tasks: desktopicon; Comment: "Abrir ajuda da CLI do AnalyticMath Lab"

[Run]
Filename: "{cmd}"; Parameters: "/K ""{app}\{#MyAppExeName}"" --help"; Description: "Abrir AnalyticMath Lab CLI"; Flags: postinstall skipifsilent nowait
