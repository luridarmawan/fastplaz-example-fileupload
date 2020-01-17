unit filehandler_controller;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, html_lib, fpcgi, fpjson, json_lib, HTTPDefs,
  fastplaz_handler, database_lib, string_helpers, dateutils,
  datetime_helpers, array_helpers;

type

  { TFilehandlerController }

  TFilehandlerController = class(TMyCustomController)
  private
    function Tag_MainContent_Handler(const TagName: string;
      Params: TStringList): string;
    procedure BeforeRequestHandler(Sender: TObject; ARequest: TRequest);
  public
    constructor CreateNew(AOwner: TComponent; CreateMode: integer); override;
    destructor Destroy; override;

    procedure Get; override;
    procedure Post; override;
  end;

implementation

uses theme_controller, common;

const
  UPLOAD_FOLDERS = 'uploads/';
  permittedFileType: array [0..2] of string = ('.jpg', '.jpeg', '.png');

constructor TFilehandlerController.CreateNew(AOwner: TComponent; CreateMode: integer);
begin
  inherited CreateNew(AOwner, CreateMode);
  BeforeRequest := @BeforeRequestHandler;
end;

destructor TFilehandlerController.Destroy;
begin
  inherited Destroy;
end;

// Init First
procedure TFilehandlerController.BeforeRequestHandler(Sender: TObject;
  ARequest: TRequest);
begin
end;

// GET Method Handler
procedure TFilehandlerController.Get;
var
  msg: string;
  fileListAsArray: TJSONArray;
begin
  msg := _SESSION['msg'];
  ThemeUtil.Assign('$msg', msg);
  ThemeUtil.Assign('$FileUpload', _SESSION['fileupload']);

  Tags['maincontent'] := @Tag_MainContent_Handler; //<<-- tag maincontent handler
  Response.Content := ThemeUtil.Render();
end;

// POST Method Handler
procedure TFilehandlerController.Post;
var
  i: integer;
  targetPath, msg: string;
begin
  if Request.Files.Count = 0 then
  begin
    _SESSION['msg'] := 'Pastikan sudah memilih file yang diupload.';
    _SESSION['fileupload'] := '';
    Redirect('./');
    Exit;
  end;

  msg := '';
  targetPath := IncludeTrailingPathDelimiter(GetCurrentDir) + UPLOAD_FOLDERS;
  for i := 0 to Request.Files.Count - 1 do
  begin
    // only for permitted file type
    if not ((ExtractFileExt(Request.Files[i].FileName)) in permittedFileType) then
      Continue;

    if not FileCopy(Request.Files[i].LocalFileName, targetPath +
      Request.Files[i].FileName) then
    begin
      // failed
      // TODO: add error handling
    end;

    _SESSION['fileupload'] := Request.Files[i].FileName;
  end;

  _SESSION['msg'] := msg;
  Redirect('./');
end;

function TFilehandlerController.Tag_MainContent_Handler(const TagName: string;
  Params: TStringList): string;
begin
  Result := ThemeUtil.RenderFromContent(nil, '', 'modules/file-upload/main.html');
end;

end.

