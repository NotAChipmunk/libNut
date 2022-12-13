program libNut;

{R *.res}

uses
  Winapi.Windows,
  libNut.Bitmaps in '..\src\libNut.Bitmaps.pas',
  libNut.Cadencer in '..\src\libNut.Cadencer.pas',
  libNut.Colours in '..\src\libNut.Colours.pas',
  libNut.Engine in '..\src\libNut.Engine.pas',
  libNut.Exceptions in '..\src\libNut.Exceptions.pas',
  libNut.GDI in '..\src\libNut.GDI.pas',
  libNut.GDIPlus in '..\src\libNut.GDIPlus.pas',
  libNut.GUID in '..\src\libNut.GUID.pas',
  libNut.Hash in '..\src\libNut.Hash.pas',
  libNut.Maths in '..\src\libNut.Maths.pas',
  libNut.Memory in '..\src\libNut.Memory.pas',
  libNut.MIDI in '..\src\libNut.MIDI.pas',
  libNut.OpenGL in '..\src\libNut.OpenGL.pas',
  libNut.Path in '..\src\libNut.Path.pas',
  libNut.Platform in '..\src\libNut.Platform.pas',
  libNut.Random in '..\src\libNut.Random.pas',
  libNut.Registry in '..\src\libNut.Registry.pas',
  libNut.Streams in '..\src\libNut.Streams.pas',
  libNut.Strings in '..\src\libNut.Strings.pas',
  libNut.Threads in '..\src\libNut.Threads.pas',
  libNut.Timing in '..\src\libNut.Timing.pas',
  libNut.Types.Compare in '..\src\libNut.Types.Compare.pas',
  libNut.Types.Convert in '..\src\libNut.Types.Convert.pas',
  libNut.Types.Operator in '..\src\libNut.Types.Operator.pas',
  libNut.Types in '..\src\libNut.Types.pas',
  libNut.Windows in '..\src\libNut.Windows.pas',
  libNut.WinSock in '..\src\libNut.WinSock.pas',
  libNut.Utils in '..\src\libNut.Utils.pas',
  libNut.FileSystem in '..\src\libNut.FileSystem.pas',
  libNut.Maths.Geometry2D in '..\src\libNut.Maths.Geometry2D.pas',
  libNut.Vectors in '..\src\libNut.Vectors.pas',
  libNut.Collections in '..\src\libNut.Collections.pas',
  libNut.Console in '..\src\libNut.Console.pas',
  libNut.DOM in '..\src\libNut.DOM.pas',
  libNut.Config in '..\src\libNut.Config.pas',
  libNut.Types.Hash in '..\src\libNut.Types.Hash.pas';

{
  TODO:
    INI/CFG Config file (Simplified XML/JSON?) (RKT/XOD.pas)
    Console library with...
    TBitmap<> type for console buffers
    Log file/stream
    Fix colours (TVector4f). HSL conversion. (Expand to named colours?)
    Maths.Geomtry2D more support (matrices etc)
    Maths.Geomtry3D
    Language files/strings
    RTTI/IDispatch support
    Evaluator for above... or...
    ActiveScript
    Hooks/LDE64
    OpenCL
    Audio interface
    SQLite
    Basic 2D physics
    More GDI support (regions etc)
    Scenegraph
    State machine
    Better debugging RKT/Debug.pas?
    Memory dump (RKT/NLDEBUG.pas)
}

{$APPTYPE CONSOLE}
{ASSERTIONS ON}
{DEFINE DEBUG}
{$I libNut.Options.inc}

var
  d: TDictionary<String, Integer>;
begin
  d := TDictionary<String, Integer>.Create;

  d['test1'] := 123;
  d['test2'] := 321;

  Writeln(d['test1']);
  Writeln(d['test4']);

  d.Delete('test1');

  Writeln(d['test1']);
  Writeln(d['test2']);

  Writeln(d.Exists('test2'));
  d['test2'] := 0;
  Writeln(d.Exists('test2'));
end.
