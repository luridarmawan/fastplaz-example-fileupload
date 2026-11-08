unit filehandler_controller;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, html_lib, fastplaz_app, fpjson, json_lib, HTTPDefs,
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

uses theme_controller, common, fileupload_lib;

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
begin
  // the message is shown once; the template escapes both values
  ThemeUtil.Assign('$msg', _SESSION['msg']);
  _SESSION['msg'] := '';
  ThemeUtil.Assign('$FileUpload', _SESSION['fileupload']);

  Tags['maincontent'] := @Tag_MainContent_Handler; //<<-- tag maincontent handler
  Response.Content := ThemeUtil.Render();
end;

// POST Method Handler
procedure TFilehandlerController.Post;
var
  i, uploaded, rejected: integer;
  targetName, msg: string;
begin
  // token from [csrf-token name="frmUpload"] in main.html
  if not isValidCSRF then
  begin
    _SESSION['msg'] := 'Formulir kedaluwarsa, silakan coba lagi.';
    Redirect('./');
    Exit; // Redirect does not leave the method
  end;

  if Request.Files.Count = 0 then
  begin
    _SESSION['msg'] := 'Pastikan sudah memilih file yang diupload.';
    _SESSION['fileupload'] := '';
    Redirect('./');
    Exit;
  end;

  uploaded := 0;
  rejected := 0;
  for i := 0 to Request.Files.Count - 1 do
  begin
    // the input was left empty
    if Request.Files[i].FileName = '' then
      Continue;

    // only for permitted file type (case insensitive)
    if (Request.Files[i].Size = 0) or
      not IsPermittedFileType(Request.Files[i].FileName) then
    begin
      Inc(rejected);
      Continue;
    end;

    // never trust the client's file name: no path, safe characters only,
    // and an existing file is not overwritten
    targetName := UniqueUploadFileName(Request.Files[i].FileName);
    if targetName.IsEmpty or
      not FileCopy(Request.Files[i].LocalFileName, UploadDir + targetName) then
    begin
      Inc(rejected);
      Continue;
    end;

    Inc(uploaded);
    _SESSION['fileupload'] := targetName;
  end;

  msg := '';
  if rejected > 0 then
    msg := IntToStr(rejected) +
      ' file gagal diupload. File yang diperbolehkan: .jpg, .jpeg, .png, .pdf'
  else if uploaded = 0 then
    msg := 'Pastikan sudah memilih file yang diupload.';
  _SESSION['msg'] := msg;
  Redirect('./');
end;

function TFilehandlerController.Tag_MainContent_Handler(const TagName: string;
  Params: TStringList): string;
begin
  Result := ThemeUtil.RenderFromContent(nil, '', 'modules/file-upload/main.html');
end;

end.
