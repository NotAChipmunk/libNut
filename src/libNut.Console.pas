unit libNut.Console;

{$I libNut.Options.inc}

interface

uses
  Winapi.Windows;

{$IF DEFINED(MSWINDOWS)}
function printf(fmt: PAnsiChar): Integer; cdecl; varargs; external 'msvcrt.dll';
{$ENDIF}

implementation

uses
  libNut.Path;

{$DEFINE DEBUG}

initialization
  if not IsConsole then
    AssignFile(Output, {$IFDEF DEBUG}AppFile('.log'){$ELSE}'nul'{$ENDIF});

finalization
  if IsConsole {and (ExitCode <> 0)} then
    Readln;

end.
