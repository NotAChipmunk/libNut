unit libNut.OpenGL;

{$I libNut.Options.inc}

interface

uses
  libNut.Exceptions,
  libNut.Engine,
  libNut.Bitmaps,
  libNut.GDIPlus,
  libNut.Maths.Geometry,

  Winapi.Windows,
  Winapi.OpenGL,
  Winapi.OpenGLext;

type
  EOpenGL = class(TException);
  TOpenGL = class;

  TBlendMode = (Disable, Alpha, Lighten, Darken);

  {$REGION 'TTexture'}
  TTexture = class
  private
    FHandle: GLuint;

    FWidth:  Integer;
    FHeight: Integer;

    FDepth: Boolean;

    FSmooth: Boolean;
    FWrap:   Boolean;

    procedure SetSmooth(const ASmooth: Boolean);
    procedure SetWrap  (const AWrap:   Boolean);
  public
    constructor Create(const AWidth, AHeight: Integer; const ADepth: Boolean = False; const Data: Pointer = nil); overload;
    constructor Create(const ABitmap: TBitmap32); overload;
    constructor Create(const AFileName: String); overload;

    destructor  Destroy; override;

    procedure Resize(const AWidth, AHeight: Integer; const ADepth: Boolean = False; const Data: Pointer = nil);

          procedure Activate  (const AIndex: Integer = 0);
    class procedure Deactivate(const AIndex: Integer = 0);

    property Handle: GLuint read FHandle;

    property Width:  Integer read FWidth;
    property Height: Integer read FHeight;

    property Depth: Boolean read FDepth;

    property Smooth: Boolean read FSmooth write SetSmooth;
    property Wrap:   Boolean read FWrap   write SetWrap;
  end;
  {$ENDREGION}

  {$REGION 'TShaderSource'}
  TShaderType = (
    Fragment = GL_FRAGMENT_SHADER,
    Vertex   = GL_VERTEX_SHADER
  );

  TShaderSource = class
  private
    FHandle: GLuint;

    FShaderType: TShaderType;
  public
    constructor Create(const ASource: String; const AShaderType: TShaderType);
    destructor  Destroy; override;

    class function CreateFromFile(const AFileName: String; const AShaderType: TShaderType): TShaderSource;

    property Handle: GLuint read FHandle;

    property ShaderType: TShaderType read FShaderType;
  end;
  {$ENDREGION}

  {$REGION 'TShader'}
  TShader = class
  private
    FHandle: GLuint;
  public
    constructor Create(const AFragmentShader, AVertexShader: TShaderSource);

    class function CreateFromSource(const AFragmentSource, AVertexSource: String): TShader;

    class function CreateFromFiles(const AFragmentFile, AVertexFile: String): TShader; overload;
    class function CreateFromFiles(const AFileName:                  String): TShader; overload;

    destructor Destroy; override;

          procedure Activate;
    class procedure Deactivate;

    //function Uniform(const AName: String): TUniform; inline;

    property Handle: GLuint read FHandle;
  end;
  {$ENDREGION}

  {$REGION 'TFrameBuffer'}
  TFrameBuffer = class
  private
    FHandle:  GLuint;

    FTexture: TTexture;

    function GetDimention(const AIndex: Integer): Integer;

    procedure DrawBuffer(const APostProcess: TShader);
  public
    constructor Create(const AWidth, AHeight: Integer);
    destructor  Destroy; override;

    procedure Resize(const AWidth, AHeight: Integer);

          procedure Activate;
    class procedure Deactivate;

    procedure Present(const AFrameBuffer: TFrameBuffer;  const APostProcess: TShader = nil); overload;
    procedure Present(const AEngine:      TOpenGL;       const APostProcess: TShader = nil); overload;

    property Handle: Gluint read FHandle;

    property Texture: TTexture read FTexture;

    property Width:  Integer index 0 read GetDimention;
    property Height: Integer index 1 read GetDimention;
  end;
  {$ENDREGION}

  {$REGION 'TOpenGL'}
  TOpenGL = class(TEngine)
  private
    FRenderContext: HGLRC;

    FBlendMode:  TBlendMode;
    FSmoothMode: Boolean;
  public
    procedure OnCreateWindow;  override;
    procedure OnDestroyWindow; override;

    procedure Prepare; override;
    procedure Present; override;

    function MakeCurrent: Boolean;

    procedure Clear(const AColour: TVector4f);

    procedure SetBlendMode(const ABlendMode: TBlendMode);
    property  BlendMode: TBlendMode read FBlendMode write SetBlendMode;

    procedure SetSmoothMode(const ASmoothMode: Boolean);
    property  SmoothMode: Boolean read FSmoothMode write SetSmoothMode;

    property RenderContext: HGLRC read FRenderContext;
  end;
  {$ENDREGION}

implementation

uses
  libNut.Windows,
  libNut.Strings,
  libNut.Streams;

{$REGION 'TTexture'}
procedure TTexture.SetSmooth;
begin
  FSmooth := ASmooth;

  Activate;

  if FSmooth then
  begin
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  end
  else
  begin
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  end;
end;

procedure TTexture.SetWrap;
begin
  FWrap := AWrap;

  Activate;

  if FWrap then
  begin
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
  end
  else
  begin
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  end;
end;

constructor TTexture.Create(const AWidth, AHeight: Integer; const ADepth: Boolean = False; const Data: Pointer = nil);
begin
  inherited Create;

  FHandle := 0;

  FWrap := True;

  Resize(AWidth, AHeight, ADepth, Data);
end;

constructor TTexture.Create(const ABitmap: TBitmap32);
begin
  inherited Create;

  FWrap := True;

  Resize(ABitmap.Width, ABitmap.Height, False, ABitmap.Bits);
end;

constructor TTexture.Create(const AFileName: String);
var
  Image:      TGDIPlusObject;
  BitmapData: TBitmapData;
  w, h:       Cardinal;
begin
  inherited Create;

  FWrap := True;

  if not InitializeGDIPlus then
    raise EOpenGL.Create('Count not initialize GDI+');

  Image := nil;

  if GdipLoadImageFromFile(@AFileName[1], Image) <> 0 then
    raise EOpenGL.Create('Failed to load texture "'  + AFileName + '"');

  try
    GdipGetImageWidth (Image, w);
    GdipGetImageHeight(Image, h);

    BitmapData.Width  := w;
    BitmapData.Height := h;
    BitmapData.Format := TPixel32.Format;

    if GdipBitmapLockBits(Image, TRect.Create(0, 0, w, h), 1, TPixel32.Format, BitmapData) <> 0 then
      raise EOpenGL.Create('Failed to lock texture data');

    Resize(w, h, False, BitmapData.Scan0);
  finally
    GdipDisposeImage(Image);
  end;
end;

destructor TTexture.Destroy;
begin
  Resize(0, 0);

  inherited;
end;

procedure TTexture.Resize;
begin
  if FHandle <> 0 then
  begin
    glDeleteTextures(1, @FHandle);
    FHandle := 0;
  end;

  if (AWidth = 0) or (AHeight = 0) then
  begin
    FWidth  := 0;
    FHeight := 0;

    Exit;
  end;

  FWidth  := AWidth;
  FHeight := AHeight;

  FDepth := ADepth;

  glGenTextures(1, @FHandle);

  Activate;

  // TODO: Depth
  // TODO: Mipmaps

  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, AWidth, AHeight, 0, GL_BGRA_EXT, GL_UNSIGNED_BYTE, Data);

  SetSmooth(FSmooth);
  SetWrap  (FWrap);
end;

procedure TTexture.Activate;
begin
  if FHandle = 0 then
    Exit;

  glEnable(GL_TEXTURE_2D);
  glActiveTexture(GL_TEXTURE0 + AIndex);
  glBindTexture(GL_TEXTURE_2D, FHandle);
end;

class procedure TTexture.Deactivate;
begin
  glActiveTexture(GL_TEXTURE0 + AIndex);
  glBindTexture(GL_TEXTURE_2D, 0);
  glDisable(GL_TEXTURE_2D);
end;
{$ENDREGION}

{$REGION 'TShaderSource'}
constructor TShaderSource.Create;
var
  BufferStr: AnsiString;
  BufferPtr: PAnsiChar;
  BufferLen: GLint;

  Compiled: Byte;
begin
  inherited Create;

  FShaderType := AShaderType;

  FHandle := glCreateShader(Ord(FShaderType));

  BufferStr := AnsiString(ASource);
  BufferPtr := PAnsiChar(BufferStr);
  BufferLen := Length(BufferStr);

  glShaderSource(FHandle, 1, @BufferPtr, @BufferLen);
  glCompileShader(FHandle);

  glGetShaderiv(FHandle, GL_COMPILE_STATUS, @Compiled);

  if Compiled <> GL_TRUE then
  begin
    var ErrorStr: AnsiString;
    var ErrorLen: GLsizei;

    glGetShaderiv(FHandle, GL_INFO_LOG_LENGTH, @ErrorLen);
    SetLength(ErrorStr, ErrorLen);

    glGetShaderInfoLog(FHandle, ErrorLen, @ErrorLen, PAnsiChar(ErrorStr));

    raise EOpenGL.Create('Failed to compile shader:'#13#10 + String(ErrorStr));
  end;
end;

destructor TShaderSource.Destroy;
begin
  if FHandle <> 0 then
    glDeleteShader(FHandle);

  inherited;
end;

class function TShaderSource.CreateFromFile;
var
  Source: String;
begin
  Source := LoadString(AFileName);
  if Source.IsEmpty then
    raise EOpenGL.Create('Failed to load shader: ' + AFileName);

  Result := TShaderSource.Create(Source, AShaderType);
end;
{$ENDREGION}

{$REGION 'TShader'}
constructor TShader.Create;
begin
  inherited Create;

  FHandle := glCreateProgram;

  glAttachShader(FHandle, AFragmentShader.FHandle);
  glAttachShader(FHandle,   AVertexShader.FHandle);

  glLinkProgram(FHandle);
end;

class function TShader.CreateFromSource;
var
  Frag, Vert: TShaderSource;
begin
  Frag := TShaderSource.Create(AFragmentSource, TShaderType.Fragment);

  try
    Vert := TShaderSource.Create(AVertexSource, TShaderType.Vertex);

    try
      Result := TShader.Create(Frag, Vert);
    finally
      Vert.Free;
    end;
  finally
    Frag.Free;
  end;
end;

class function TShader.CreateFromFiles(const AFragmentFile, AVertexFile: String): TShader;
var
  Frag, Vert: String;
begin
  Frag := LoadString(AFragmentFile);
  if Frag.IsEmpty then
    raise EOpenGL.Create('Failed to load fragment shader: ' + AFragmentFile);

  Vert := LoadString(AVertexFile);
  if Vert.IsEmpty then
    raise EOpenGL.Create('Failed to load vertex shader: ' + AVertexFile);

  Result := CreateFromSource(Frag, Vert);
end;

class function TShader.CreateFromFiles(const AFileName: String): TShader;
begin
  Result := CreateFromFiles(AFileName + '.frag', AFileName + '.vert');
end;

destructor TShader.Destroy;
begin
  if FHandle <> 0 then
    glDeleteProgram(FHandle);

  inherited;
end;

procedure TShader.Activate;
begin
  glUseProgram(FHandle);
end;

class procedure TShader.Deactivate;
begin
  glUseProgram(0);
end;
{$ENDREGION}

{$REGION 'TFrameBuffer'}
function TFrameBuffer.GetDimention;
begin
  if not Assigned(FTexture) then
    Exit(0);

  case AIndex of
    0: Result := FTexture.Width;
    1: Result := FTexture.Height;
  else
    Result := 0;
  end;
end;

procedure TFrameBuffer.DrawBuffer;
begin
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;

  glOrtho(0, 1, 0, 1, -1, 1);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;

  FTexture.Activate;

  if Assigned(APostProcess) then
    APostProcess.Activate;

  glDisable(GL_DEPTH_TEST);

  glBegin(GL_QUADS);
    glTexCoord2f(0, 0); glVertex2i(0, 0);
    glTexCoord2f(1, 0); glVertex2i(1, 0);
    glTexCoord2f(1, 1); glVertex2i(1, 1);
    glTexCoord2f(0, 1); glVertex2i(0, 1);
  glEnd;

  TTexture.Deactivate;
  TShader.Deactivate;
end;

constructor TFrameBuffer.Create;
begin
  inherited Create;

  FTexture := TTexture.Create(AWidth, AHeight);

  glGenFrameBuffers(1, @FHandle);
  glBindFrameBuffer(GL_FRAMEBUFFER, FHandle);
  glFrameBufferTexture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, FTexture.FHandle, 0);

  TFrameBuffer.Deactivate;
end;

destructor TFrameBuffer.Destroy;
begin
  if FHandle <> 0 then
    glDeleteFrameBuffers(1, @FHandle);

  if Assigned(FTexture) then
    FTexture.Free;

  inherited;
end;

procedure TFrameBuffer.Resize(const AWidth, AHeight: Integer);
begin
  FTexture.Resize(AWidth, AHeight);
  glBindFrameBuffer(GL_FRAMEBUFFER, FHandle);
  glFrameBufferTexture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, FTexture.FHandle, 0);
  TFrameBuffer.Deactivate;
end;

procedure TFrameBuffer.Activate;
begin
  if FHandle = 0 then
    Exit;

  glBindFrameBuffer(GL_FRAMEBUFFER, FHandle);
  glViewport(0, 0, FTexture.Width, FTexture.Height);

  TTexture.Deactivate;
end;

class procedure TFrameBuffer.Deactivate;
begin
  glBindFrameBuffer(GL_FRAMEBUFFER, 0);
end;

procedure TFrameBuffer.Present(const AFrameBuffer: TFrameBuffer; const APostProcess: TShader = nil);
begin
  AFrameBuffer.Activate;
  glViewport(0, 0, AFrameBuffer.Width, AFrameBuffer.Height);

  DrawBuffer(APostProcess);
end;

procedure TFrameBuffer.Present(const AEngine: TOpenGL; const APostProcess: TShader = nil);
begin
  Deactivate;
  glViewport(0, 0, AEngine.Handle.ClientWidth, AEngine.Handle.ClientHeight);

  DrawBuffer(APostProcess);
end;
{$ENDREGION}

{$REGION 'TOpenGL'}
procedure TOpenGL.OnCreateWindow;
var
  PixelFormatDesc: PIXELFORMATDESCRIPTOR;
  PixelFormat:     GLint;
begin
  inherited;

  FillChar(PixelFormatDesc, SizeOf(PixelFormatDesc), 0);

  PixelFormatDesc.nSize      := SizeOf(PixelFormatDesc);
  PixelFormatDesc.nVersion   := 1;
  PixelFormatDesc.dwFlags    := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
  PixelFormatDesc.iPixelType := PFD_TYPE_RGBA;
  PixelFormatDesc.cColorBits := 32;
  PixelFormatDesc.cDepthBits := 16;
  PixelFormatDesc.iLayerType := PFD_MAIN_PLANE;

  PixelFormat := ChoosePixelFormat(DeviceContext, @PixelFormatDesc);
  if PixelFormat = 0 then
    raise EOpenGL.Create('Failed to choose pixel format');

  if not SetPixelFormat(DeviceContext, PixelFormat, @PixelFormatDesc) then
    raise EOpenGL.Create('Failed to set pixel format');

  FRenderContext := wglCreateContext(DeviceContext);
  if FRenderContext = 0 then
    raise EOpenGL.Create('Failed to create render context');

  if not MakeCurrent then
    raise EOpenGL.Create('Failed to activate context');

  InitOpenGLext;
end;

procedure TOpenGL.OnDestroyWindow;
begin
  if DeviceContext <> 0 then
    wglMakeCurrent(DeviceContext, 0);

  inherited;

  if FRenderContext <> 0 then
  begin
    wglDeleteContext(FRenderContext);
    FRenderContext := 0;
  end;
end;

procedure TOpenGL.Prepare;
begin
  MakeCurrent;
  glViewport(0, 0, Width, Height);
end;

procedure TOpenGL.Present;
begin
  SwapBuffers(DeviceContext);
end;

function TOpenGL.MakeCurrent;
begin
  Result := wglMakeCurrent(DeviceContext, FRenderContext);
end;

procedure TOpenGL.Clear;
begin
  glClearColor(AColour.R, AColour.G, AColour.B, AColour.A);
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
end;

procedure TOpenGL.SetBlendMode;
begin
  FBlendMode := ABlendMode;

  if ABlendMode = TBlendMode.Disable then
    glDisable(GL_BLEND)
  else
    glEnable(GL_BLEND);

  case ABlendMode of
    TBlendMode.Alpha:   glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    TBlendMode.Lighten: glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    TBlendMode.Darken:  glBlendFunc(GL_ZERO,      GL_ONE_MINUS_SRC_ALPHA);
  end;
end;

procedure TOpenGL.SetSmoothMode;
begin
  FSmoothMode := ASmoothMode;

  if FSmoothMode then
  begin
    glEnable(GL_LINE_SMOOTH);
    glEnable(GL_POLYGON_SMOOTH);
    glHint(GL_LINE_SMOOTH_HINT, GL_NICEST);
    glHint(GL_POLYGON_SMOOTH_HINT, GL_NICEST);
  end
  else
  begin
    glDisable(GL_LINE_SMOOTH);
    glDisable(GL_POLYGON_SMOOTH);
  end;
end;
{$ENDREGION}

end.
