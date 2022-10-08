unit libNut.Hash;

{$I libNut.Options.inc}

interface

type
  {$REGION 'THash'}
  THash = class abstract
  public
    constructor Create;

    procedure Reset; virtual; abstract;
    procedure Update(const AData: Pointer; const ALen: Integer); virtual; abstract;
    procedure Done; virtual; abstract;

    procedure UpdateStr(const AStr: String); inline;

    class function HashStr (const AStr: String):                 String; inline;
    class function HashData(const AData; const ASize: Cardinal): String;
  end;
  {$ENDREGION}

  {$REGION 'TCRC8'}
  TCRC8 = class(THash)
  private
    FHash: Byte;
  public
    procedure Reset; override;
    procedure Update(const AData: Pointer; const ALen: Integer); override;
    procedure Done; override;

    function ToString: String; override;

    property Hash: Byte read FHash;
  end;
  {$ENDREGION}

  {$REGION 'TCRC32'}
  TCRC32 = class(THash)
  private
    FHash: Cardinal;
  public
    procedure Reset; override;
    procedure Update(const AData: Pointer; const ALen: Integer); override;
    procedure Done; override;

    function ToString: String; override;

    property Hash: Cardinal read FHash;
  end;
  {$ENDREGION}

  {$REGION 'TSHA256'}
  TSHA256 = class(THash)
  private
    FHash: record
      A, B, C, D, E, F, G, H: Cardinal;
    end;

    FLen:    Int64;
    FBuffer: array[0..63] of Byte;
    FIndex:  Integer;

    FHashStr: String;

    procedure Compress;
  public
    procedure Reset; override;
    procedure Update(const AData: Pointer; const ALen: Integer); override;
    procedure Done; override;

    function ToString: String; override;
  end;
  {$ENDREGION}

implementation

uses
  libNut.Types.Convert,
  libNut.Memory;

{$REGION 'THash'}
constructor THash.Create;
begin
  inherited;

  Reset;
end;

procedure THash.UpdateStr;
begin
  Update(PChar(@AStr[1]), Length(AStr) * SizeOf(Char));
end;

class function THash.HashStr;
begin
  Result := HashData(PChar(@AStr[1])^, Length(AStr) * SizeOf(Char));
end;

class function THash.HashData;
begin
  with Self.Create do try
    Update(@AData, ASize);
    Done;
    Result := ToString;
  finally
    Free;
  end;
end;
{$ENDREGION}

{$REGION 'TCRC8'}
{$REGION 'CRC8Table'}
const
  CRC8Table: array[Byte] of Byte = (
       098,006,085,150,036,023,112,164,135,207,169,005,026,064,165,219, //  1
       061,020,068,089,130,063,052,102,024,229,132,245,080,216,195,115, //  2
       090,168,156,203,177,120,002,190,188,007,100,185,174,243,162,010, //  3
       237,018,253,225,008,208,172,244,255,126,101,079,145,235,228,121, //  4
       123,251,067,250,161,000,107,097,241,111,181,082,249,033,069,055, //  5
       059,153,029,009,213,167,084,093,030,046,094,075,151,114,073,222, //  6
       197,096,210,045,016,227,248,202,051,152,252,125,081,206,215,186, //  7
       039,158,178,187,131,136,001,049,050,017,141,091,047,129,060,099, //  8
       154,035,086,171,105,034,038,200,147,058,077,118,173,246,076,254, //  9
       133,232,196,144,198,124,053,004,108,074,223,234,134,230,157,139, // 10
       189,205,199,128,176,019,211,236,127,192,231,070,233,088,146,044, // 11
       183,201,022,083,013,214,116,109,159,032,095,226,140,220,057,012, // 12
       221,031,209,182,143,092,149,184,148,062,113,065,037,027,106,166, // 13
       003,014,204,072,021,041,056,066,028,193,040,217,025,054,179,117, // 14
       238,087,240,155,180,170,242,212,191,163,078,218,137,194,175,110, // 15
       043,119,224,071,122,142,042,160,104,048,247,103,015,011,138,239  // 16
   );
{$ENDREGION}

procedure TCRC8.Reset;
begin
  FHash := $FF;
end;

procedure TCRC8.Update;
begin
  for var i := 1 to ALen do
  begin
    FHash := CRC8Table[FHash xor PByte(AData)^];
    AData.Inc;
  end;
end;

procedure TCRC8.Done;
begin
  FHash := FHash xor $FF;
end;

function TCRC8.ToString;
begin
  Result := IntToBaseX(FHash, 16, 2);
end;
{$ENDREGION}

{$REGION 'TCRC32'}
{$REGION 'CRC32Table'}
const
  CRC32Table: array[Byte] of Cardinal = (
    $00000000, $77073096, $EE0E612C, $990951BA, $076DC419,
    $706AF48F, $E963A535, $9E6495A3, $0EDB8832, $79DCB8A4,
    $E0D5E91E, $97D2D988, $09B64C2B, $7EB17CBD, $E7B82D07,
    $90BF1D91, $1DB71064, $6AB020F2, $F3B97148, $84BE41DE,
    $1ADAD47D, $6DDDE4EB, $F4D4B551, $83D385C7, $136C9856,
    $646BA8C0, $FD62F97A, $8A65C9EC, $14015C4F, $63066CD9,
    $FA0F3D63, $8D080DF5, $3B6E20C8, $4C69105E, $D56041E4,
    $A2677172, $3C03E4D1, $4B04D447, $D20D85FD, $A50AB56B,
    $35B5A8FA, $42B2986C, $DBBBC9D6, $ACBCF940, $32D86CE3,
    $45DF5C75, $DCD60DCF, $ABD13D59, $26D930AC, $51DE003A,
    $C8D75180, $BFD06116, $21B4F4B5, $56B3C423, $CFBA9599,
    $B8BDA50F, $2802B89E, $5F058808, $C60CD9B2, $B10BE924,
    $2F6F7C87, $58684C11, $C1611DAB, $B6662D3D, $76DC4190,
    $01DB7106, $98D220BC, $EFD5102A, $71B18589, $06B6B51F,
    $9FBFE4A5, $E8B8D433, $7807C9A2, $0F00F934, $9609A88E,
    $E10E9818, $7F6A0DBB, $086D3D2D, $91646C97, $E6635C01,
    $6B6B51F4, $1C6C6162, $856530D8, $F262004E, $6C0695ED,
    $1B01A57B, $8208F4C1, $F50FC457, $65B0D9C6, $12B7E950,
    $8BBEB8EA, $FCB9887C, $62DD1DDF, $15DA2D49, $8CD37CF3,
    $FBD44C65, $4DB26158, $3AB551CE, $A3BC0074, $D4BB30E2,
    $4ADFA541, $3DD895D7, $A4D1C46D, $D3D6F4FB, $4369E96A,
    $346ED9FC, $AD678846, $DA60B8D0, $44042D73, $33031DE5,
    $AA0A4C5F, $DD0D7CC9, $5005713C, $270241AA, $BE0B1010,
    $C90C2086, $5768B525, $206F85B3, $B966D409, $CE61E49F,
    $5EDEF90E, $29D9C998, $B0D09822, $C7D7A8B4, $59B33D17,
    $2EB40D81, $B7BD5C3B, $C0BA6CAD, $EDB88320, $9ABFB3B6,
    $03B6E20C, $74B1D29A, $EAD54739, $9DD277AF, $04DB2615,
    $73DC1683, $E3630B12, $94643B84, $0D6D6A3E, $7A6A5AA8,
    $E40ECF0B, $9309FF9D, $0A00AE27, $7D079EB1, $F00F9344,
    $8708A3D2, $1E01F268, $6906C2FE, $F762575D, $806567CB,
    $196C3671, $6E6B06E7, $FED41B76, $89D32BE0, $10DA7A5A,
    $67DD4ACC, $F9B9DF6F, $8EBEEFF9, $17B7BE43, $60B08ED5,
    $D6D6A3E8, $A1D1937E, $38D8C2C4, $4FDFF252, $D1BB67F1,
    $A6BC5767, $3FB506DD, $48B2364B, $D80D2BDA, $AF0A1B4C,
    $36034AF6, $41047A60, $DF60EFC3, $A867DF55, $316E8EEF,
    $4669BE79, $CB61B38C, $BC66831A, $256FD2A0, $5268E236,
    $CC0C7795, $BB0B4703, $220216B9, $5505262F, $C5BA3BBE,
    $B2BD0B28, $2BB45A92, $5CB36A04, $C2D7FFA7, $B5D0CF31,
    $2CD99E8B, $5BDEAE1D, $9B64C2B0, $EC63F226, $756AA39C,
    $026D930A, $9C0906A9, $EB0E363F, $72076785, $05005713,
    $95BF4A82, $E2B87A14, $7BB12BAE, $0CB61B38, $92D28E9B,
    $E5D5BE0D, $7CDCEFB7, $0BDBDF21, $86D3D2D4, $F1D4E242,
    $68DDB3F8, $1FDA836E, $81BE16CD, $F6B9265B, $6FB077E1,
    $18B74777, $88085AE6, $FF0F6A70, $66063BCA, $11010B5C,
    $8F659EFF, $F862AE69, $616BFFD3, $166CCF45, $A00AE278,
    $D70DD2EE, $4E048354, $3903B3C2, $A7672661, $D06016F7,
    $4969474D, $3E6E77DB, $AED16A4A, $D9D65ADC, $40DF0B66,
    $37D83BF0, $A9BCAE53, $DEBB9EC5, $47B2CF7F, $30B5FFE9,
    $BDBDF21C, $CABAC28A, $53B39330, $24B4A3A6, $BAD03605,
    $CDD70693, $54DE5729, $23D967BF, $B3667A2E, $C4614AB8,
    $5D681B02, $2A6F2B94, $B40BBE37, $C30C8EA1, $5A05DF1B,
    $2D02EF8D
  );
{$ENDREGION}

procedure TCRC32.Reset;
begin
  FHash := $FFFFFFFF;
end;

procedure TCRC32.Update;
begin
  for var i := 1 to ALen do
  begin
    FHash := CRC32Table[Byte(FHash xor Cardinal(PByte(AData)^))] xor ((FHash shr 8) and $FFFFFF);
    AData.Inc;
  end;
end;

procedure TCRC32.Done;
begin
  FHash := FHash xor $FFFFFFFF;
end;

function TCRC32.ToString;
begin
  Result := IntToBaseX(FHash, 16, 8);
end;
{$ENDREGION}

{$REGION 'TSHA256'}
function BSwap32(A: Cardinal): Cardinal;
begin
  Result := ((A and $FF)       shl 24) or
            ((A and $FF00)     shl  8) or
            ((A and $FF0000)   shr  8) or
            ((A and $FF000000) shr 24);
end;

procedure BSwap256(ASource, ADest: PCardinal);
begin
  for var i := 0 to 7 do
  begin
    ADest^ := BSwap32(ASource^);

    Inc(ASource);
    Inc(ADest);
  end;
end;

procedure TSHA256.Compress;
var
  a, b, c, d, e, f, g, h: Cardinal;
  t1, t2:                 Cardinal;
  w:                      array[0..63] of Cardinal;
  i:                      Cardinal;
begin
  FIndex := 0;

  Move(FBuffer, w, SizeOf(FBuffer));

  a := FHash.A;
  b := FHash.B;
  c := FHash.C;
  d := FHash.D;
  e := FHash.E;
  f := FHash.F;
  g := FHash.G;
  h := FHash.H;

  for i := 0 to 15 do
    w[i] := BSwap32(w[i]);

  for i := 16 to 63 do
    w[i] := (((w[i - 2] shr 17) or (w[i - 2] shl 15)) xor ((w[i - 2] shr 19) or
            (w[i - 2] shl 13)) xor (w[i - 2] shr 10)) + w[i - 7] + (((w[i - 15]
            shr 7) or (w[i - 15] shl 25)) xor ((w[i - 15] shr 18) or (w[i - 15]
            shl 14)) xor (w[i - 15] shr 3)) + w[i - 16];

  t1 := h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $428a2f98 + W[0];  t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c)); h := t1 + t2; d := d + t1;
  t1 := g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $71374491 + W[1];  t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b)); g := t1 + t2; c := c + t1;
  t1 := f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $b5c0fbcf + W[2];  t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a)); f := t1 + t2; b := b + t1;
  t1 := e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $e9b5dba5 + W[3];  t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h)); e := t1 + t2; a := a + t1;
  t1 := d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $3956c25b + W[4];  t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g)); d := t1 + t2; h := h + t1;
  t1 := c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $59f111f1 + W[5];  t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f)); c := t1 + t2; g := g + t1;
  t1 := b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $923f82a4 + W[6];  t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e)); b := t1 + t2; f := f + t1;
  t1 := a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $ab1c5ed5 + W[7];  t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d)); a := t1 + t2; e := e + t1;
  t1 := h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $d807aa98 + W[8];  t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c)); h := t1 + t2; d := d + t1;
  t1 := g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $12835b01 + W[9];  t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b)); g := t1 + t2; c := c + t1;
  t1 := f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $243185be + W[10]; t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a)); f := t1 + t2; b := b + t1;
  t1 := e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $550c7dc3 + W[11]; t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h)); e := t1 + t2; a := a + t1;
  t1 := d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $72be5d74 + W[12]; t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g)); d := t1 + t2; h := h + t1;
  t1 := c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $80deb1fe + W[13]; t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f)); c := t1 + t2; g := g + t1;
  t1 := b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $9bdc06a7 + W[14]; t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e)); b := t1 + t2; f := f + t1;
  t1 := a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $c19bf174 + W[15]; t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d)); a := t1 + t2; e := e + t1;
  t1 := h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $e49b69c1 + W[16]; t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c)); h := t1 + t2; d := d + t1;
  t1 := g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $efbe4786 + W[17]; t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b)); g := t1 + t2; c := c + t1;
  t1 := f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $0fc19dc6 + W[18]; t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a)); f := t1 + t2; b := b + t1;
  t1 := e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $240ca1cc + W[19]; t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h)); e := t1 + t2; a := a + t1;
  t1 := d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $2de92c6f + W[20]; t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g)); d := t1 + t2; h := h + t1;
  t1 := c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $4a7484aa + W[21]; t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f)); c := t1 + t2; g := g + t1;
  t1 := b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $5cb0a9dc + W[22]; t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e)); b := t1 + t2; f := f + t1;
  t1 := a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $76f988da + W[23]; t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d)); a := t1 + t2; e := e + t1;
  t1 := h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $983e5152 + W[24]; t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c)); h := t1 + t2; d := d + t1;
  t1 := g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $a831c66d + W[25]; t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b)); g := t1 + t2; c := c + t1;
  t1 := f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $b00327c8 + W[26]; t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a)); f := t1 + t2; b := b + t1;
  t1 := e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $bf597fc7 + W[27]; t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h)); e := t1 + t2; a := a + t1;
  t1 := d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $c6e00bf3 + W[28]; t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g)); d := t1 + t2; h := h + t1;
  t1 := c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $d5a79147 + W[29]; t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f)); c := t1 + t2; g := g + t1;
  t1 := b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $06ca6351 + W[30]; t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e)); b := t1 + t2; f := f + t1;
  t1 := a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $14292967 + W[31]; t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d)); a := t1 + t2; e := e + t1;
  t1 := h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $27b70a85 + W[32]; t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c)); h := t1 + t2; d := d + t1;
  t1 := g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $2e1b2138 + W[33]; t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b)); g := t1 + t2; c := c + t1;
  t1 := f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $4d2c6dfc + W[34]; t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a)); f := t1 + t2; b := b + t1;
  t1 := e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $53380d13 + W[35]; t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h)); e := t1 + t2; a := a + t1;
  t1 := d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $650a7354 + W[36]; t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g)); d := t1 + t2; h := h + t1;
  t1 := c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $766a0abb + W[37]; t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f)); c := t1 + t2; g := g + t1;
  t1 := b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $81c2c92e + W[38]; t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e)); b := t1 + t2; f := f + t1;
  t1 := a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $92722c85 + W[39]; t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d)); a := t1 + t2; e := e + t1;
  t1 := h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $a2bfe8a1 + W[40]; t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c)); h := t1 + t2; d := d + t1;
  t1 := g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $a81a664b + W[41]; t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b)); g := t1 + t2; c := c + t1;
  t1 := f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $c24b8b70 + W[42]; t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a)); f := t1 + t2; b := b + t1;
  t1 := e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $c76c51a3 + W[43]; t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h)); e := t1 + t2; a := a + t1;
  t1 := d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $d192e819 + W[44]; t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g)); d := t1 + t2; h := h + t1;
  t1 := c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $d6990624 + W[45]; t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f)); c := t1 + t2; g := g + t1;
  t1 := b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $f40e3585 + W[46]; t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e)); b := t1 + t2; f := f + t1;
  t1 := a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $106aa070 + W[47]; t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d)); a := t1 + t2; e := e + t1;
  t1 := h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $19a4c116 + W[48]; t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c)); h := t1 + t2; d := d + t1;
  t1 := g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $1e376c08 + W[49]; t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b)); g := t1 + t2; c := c + t1;
  t1 := f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $2748774c + W[50]; t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a)); f := t1 + t2; b := b + t1;
  t1 := e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $34b0bcb5 + W[51]; t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h)); e := t1 + t2; a := a + t1;
  t1 := d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $391c0cb3 + W[52]; t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g)); d := t1 + t2; h := h + t1;
  t1 := c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $4ed8aa4a + W[53]; t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f)); c := t1 + t2; g := g + t1;
  t1 := b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $5b9cca4f + W[54]; t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e)); b := t1 + t2; f := f + t1;
  t1 := a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $682e6ff3 + W[55]; t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d)); a := t1 + t2; e := e + t1;
  t1 := h + (((e shr 6) or (e shl 26)) xor ((e shr 11) or (e shl 21)) xor ((e shr 25) or (e shl 7))) + ((e and f) xor (not e and g)) + $748f82ee + W[56]; t2:= (((a shr 2) or (a shl 30)) xor ((a shr 13) or (a shl 19)) xor ((a shr 22) xor (a shl 10))) + ((a and b) xor (a and c) xor (b and c)); h := t1 + t2; d := d + t1;
  t1 := g + (((d shr 6) or (d shl 26)) xor ((d shr 11) or (d shl 21)) xor ((d shr 25) or (d shl 7))) + ((d and e) xor (not d and f)) + $78a5636f + W[57]; t2:= (((h shr 2) or (h shl 30)) xor ((h shr 13) or (h shl 19)) xor ((h shr 22) xor (h shl 10))) + ((h and a) xor (h and b) xor (a and b)); g := t1 + t2; c := c + t1;
  t1 := f + (((c shr 6) or (c shl 26)) xor ((c shr 11) or (c shl 21)) xor ((c shr 25) or (c shl 7))) + ((c and d) xor (not c and e)) + $84c87814 + W[58]; t2:= (((g shr 2) or (g shl 30)) xor ((g shr 13) or (g shl 19)) xor ((g shr 22) xor (g shl 10))) + ((g and h) xor (g and a) xor (h and a)); f := t1 + t2; b := b + t1;
  t1 := e + (((b shr 6) or (b shl 26)) xor ((b shr 11) or (b shl 21)) xor ((b shr 25) or (b shl 7))) + ((b and c) xor (not b and d)) + $8cc70208 + W[59]; t2:= (((f shr 2) or (f shl 30)) xor ((f shr 13) or (f shl 19)) xor ((f shr 22) xor (f shl 10))) + ((f and g) xor (f and h) xor (g and h)); e := t1 + t2; a := a + t1;
  t1 := d + (((a shr 6) or (a shl 26)) xor ((a shr 11) or (a shl 21)) xor ((a shr 25) or (a shl 7))) + ((a and b) xor (not a and c)) + $90befffa + W[60]; t2:= (((e shr 2) or (e shl 30)) xor ((e shr 13) or (e shl 19)) xor ((e shr 22) xor (e shl 10))) + ((e and f) xor (e and g) xor (f and g)); d := t1 + t2; h := h + t1;
  t1 := c + (((h shr 6) or (h shl 26)) xor ((h shr 11) or (h shl 21)) xor ((h shr 25) or (h shl 7))) + ((h and a) xor (not h and b)) + $a4506ceb + W[61]; t2:= (((d shr 2) or (d shl 30)) xor ((d shr 13) or (d shl 19)) xor ((d shr 22) xor (d shl 10))) + ((d and e) xor (d and f) xor (e and f)); c := t1 + t2; g := g + t1;
  t1 := b + (((g shr 6) or (g shl 26)) xor ((g shr 11) or (g shl 21)) xor ((g shr 25) or (g shl 7))) + ((g and h) xor (not g and a)) + $bef9a3f7 + W[62]; t2:= (((c shr 2) or (c shl 30)) xor ((c shr 13) or (c shl 19)) xor ((c shr 22) xor (c shl 10))) + ((c and d) xor (c and e) xor (d and e)); b := t1 + t2; f := f + t1;
  t1 := a + (((f shr 6) or (f shl 26)) xor ((f shr 11) or (f shl 21)) xor ((f shr 25) or (f shl 7))) + ((f and g) xor (not f and h)) + $c67178f2 + W[63]; t2:= (((b shr 2) or (b shl 30)) xor ((b shr 13) or (b shl 19)) xor ((b shr 22) xor (b shl 10))) + ((b and c) xor (b and d) xor (c and d)); a := t1 + t2; e := e + t1;

  Inc(FHash.A, a);
  Inc(FHash.B, b);
  Inc(FHash.C, c);
  Inc(FHash.D, d);
  Inc(FHash.E, e);
  Inc(FHash.F, f);
  Inc(FHash.G, g);
  Inc(FHash.H, h);

  FillChar(w,       SizeOf(w),       0);
  FillChar(FBuffer, SizeOf(FBuffer), 0);
end;

procedure TSHA256.Reset;
begin
  FHashStr := '';

  FHash.A := $6A09E667;
  FHash.B := $BB67AE85;
  FHash.C := $3C6EF372;
  FHash.D := $A54ff53A;
  FHash.E := $510E527F;
  FHash.F := $9B05688C;
  FHash.G := $1F83D9AB;
  FHash.H := $5BE0CD19;

  FillChar(FBuffer, SizeOf(FBuffer), 0);

  FIndex := 0;
  FLen   := 0;
end;

procedure TSHA256.Update;
var
  i, l: UInt64;
  d:    Pointer;
begin
  l := ALen;
  Inc(FLen, l shl 3);

  d := AData;

  while l > 0 do
  begin
    i := 64 - FIndex;

    if i <= l then
    begin
      Move(d^, FBuffer[FIndex], i);
      Dec(l, i);
      d := Pointer(UIntPtr(d) + i);

      Compress;

      FIndex := 0;
    end
    else
    begin
      Move(d^, FBuffer[FIndex], l);
      Inc(FIndex, l);

      Break;
    end;
  end;
end;

procedure TSHA256.Done;
const
  HexChar: array[0..15] of AnsiChar = '0123456789ABCDEF';
type
  TInt64 = packed record
    Lo, Hi: Cardinal;
  end;
var
  i:       Integer;
  AResult: AnsiString;
  PResult: PAnsiChar;
  Digest:  array[0..31] of Byte;
begin
  FBuffer[FIndex] := $80;

  FillChar(FBuffer[FIndex + 1], 63 - FIndex, 0);

  if FIndex >= 56 then
  begin
    Compress;

    FillChar(FBuffer, 56, 0);
  end;

  PInteger(@FBuffer[56])^ := BSwap32(TInt64(FLen).Hi);
  PInteger(@FBuffer[60])^ := BSwap32(TInt64(FLen).Lo);

  Compress;

  BSwap256(@FHash, @Digest);

  SetLength(AResult, SizeOf(Digest) * 2);
  PResult := PAnsiChar(AResult);

  for i := 0 to SizeOf(Digest) - 1 do
  begin
    PResult[0] := HexChar[Digest[I] shr 4];
    PResult[1] := HexChar[Digest[I] and 15];
    Inc(PResult, 2);
  end;

  FHashStr := String(AResult);
end;

function TSHA256.ToString;
begin
  Result := FHashStr;
end;
{$ENDREGION}

end.
