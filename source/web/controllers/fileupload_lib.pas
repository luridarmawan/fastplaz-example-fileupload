unit fileupload_lib;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  UPLOAD_FOLDER = 'uploads';
  PERMITTED_FILE_TYPES: array [0..3] of string = ('.jpg', '.jpeg', '.png', '.pdf');
  MAX_FILENAME_LENGTH = 100;

// absolute path of the upload folder, with a trailing path delimiter
function UploadDir: string;
// True when the extension (case insensitive) is in PERMITTED_FILE_TYPES
function IsPermittedFileType(const AFileName: string): boolean;
// File name from the client reduced to [A-Za-z0-9._-]: no directory part,
// no leading dot, extension in lower case. '' when nothing usable is left.
function SafeUploadFileName(const AFileName: string): string;
// SafeUploadFileName that does not exist yet in UploadDir (name-1.ext, ...)
function UniqueUploadFileName(const AFileName: string): string;
// absolute path of an uploaded file, '' when the name is not a plain
// permitted file name inside UploadDir (path traversal, hidden file, ...)
function UploadedFilePath(const AFileName: string): string;
function ContentTypeOf(const AFileName: string): string;

implementation

function UploadDir: string;
begin
  Result := IncludeTrailingPathDelimiter(
    ExpandFileName(IncludeTrailingPathDelimiter(GetCurrentDir) + UPLOAD_FOLDER));
end;

function IsPermittedFileType(const AFileName: string): boolean;
var
  ext: string;
  i: integer;
begin
  Result := False;
  ext := LowerCase(ExtractFileExt(AFileName));
  for i := Low(PERMITTED_FILE_TYPES) to High(PERMITTED_FILE_TYPES) do
    if ext = PERMITTED_FILE_TYPES[i] then
      Exit(True);
end;

function SafeUploadFileName(const AFileName: string): string;
var
  s, ext: string;
  i: integer;
begin
  Result := '';
  // browsers on Windows may send "C:\path\name.jpg"
  s := StringReplace(AFileName, '\', '/', [rfReplaceAll]);
  i := LastDelimiter('/', s);
  if i > 0 then
    s := Copy(s, i + 1, Length(s));

  for i := 1 to Length(s) do
    if not (s[i] in ['A'..'Z', 'a'..'z', '0'..'9', '.', '_', '-']) then
      s[i] := '_';
  while (s <> '') and (s[1] = '.') do
    Delete(s, 1, 1);

  ext := LowerCase(ExtractFileExt(s));
  s := ChangeFileExt(s, '');
  if Length(s) > MAX_FILENAME_LENGTH then
    SetLength(s, MAX_FILENAME_LENGTH);
  if s = '' then
    Exit;
  Result := s + ext;
end;

function UniqueUploadFileName(const AFileName: string): string;
var
  base, ext: string;
  i: integer;
begin
  Result := SafeUploadFileName(AFileName);
  if Result = '' then
    Exit;
  ext := ExtractFileExt(Result);
  base := ChangeFileExt(Result, '');
  i := 0;
  while FileExists(UploadDir + Result) do
  begin
    Inc(i);
    Result := base + '-' + IntToStr(i) + ext;
  end;
end;

function UploadedFilePath(const AFileName: string): string;
var
  dir: string;
begin
  Result := '';
  if (AFileName = '') or (SafeUploadFileName(AFileName) <> AFileName) then
    Exit;
  if not IsPermittedFileType(AFileName) then
    Exit;
  dir := UploadDir;
  Result := ExpandFileName(dir + AFileName);
  // must stay inside the upload folder
  if not SameFileName(ExtractFilePath(Result), dir) then
    Result := '';
end;

function ContentTypeOf(const AFileName: string): string;
begin
  case LowerCase(ExtractFileExt(AFileName)) of
    '.jpg', '.jpeg': Result := 'image/jpeg';
    '.png': Result := 'image/png';
    '.pdf': Result := 'application/pdf';
    else
      Result := 'application/octet-stream';
  end;
end;

end.
