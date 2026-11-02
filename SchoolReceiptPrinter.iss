[Setup]
AppName=School Receipt Printer
AppVersion=1.0.0
DefaultDirName={commonpf64}\School Receipt Printer
DefaultGroupName=School Receipt Printer
OutputDir=.
OutputBaseFilename=SchoolReceiptPrinter_Setup
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs

[Icons]
Name: "{commonprograms}\School Receipt Printer"; Filename: "{app}\school_receipt_printer.exe"
Name: "{commondesktop}\School Receipt Printer"; Filename: "{app}\school_receipt_printer.exe"
