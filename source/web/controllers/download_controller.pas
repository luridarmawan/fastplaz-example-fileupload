unit download_controller;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, html_lib, fastplaz_app, fpjson, json_lib, HTTPDefs,
  fastplaz_handler, database_lib, string_helpers, dateutils, datetime_helpers;

type
  TDownloadController = class(TMyCustomController)
  private
    procedure BeforeRequestHandler(Sender: TObject; ARequest: TRequest);
  public
    constructor CreateNew(AOwner: TComponent; CreateMode: integer); override;
    destructor Destroy; override;

    procedure Get; override;
  end;

implementation

uses theme_controller, common, fileupload_lib;

constructor TDownloadController.CreateNew(AOwner: TComponent; CreateMode: integer);
begin
  inherited CreateNew(AOwner, CreateMode);
  BeforeRequest := @BeforeRequestHandler;
end;

destructor TDownloadController.Destroy;
begin
  inherited Destroy;
end;

// Init First
procedure TDownloadController.BeforeRequestHandler(Sender: TObject;
  ARequest: TRequest);
begin
end;

// GET Method Handler
procedure TDownloadController.Get;
var
  fileName, filePath: string;
  fileStream: TFileStream;
begin
  //TODO: Check Priviledge

  fileName := _GET['filename'];
  if fileName.IsEmpty then
  begin
    Die('Invalid Request', 400);
    Exit; // Die does not leave the method
  end;

  // only a plain, permitted file name inside uploads/ (no "../", no path)
  filePath := UploadedFilePath(fileName);
  if filePath.IsEmpty then
  begin
    Die('Invalid file name.', 400);
    Exit;
  end;
  if not FileExists(filePath) then
  begin
    Die('File not exists.', 404);
    Exit;
  end;

  fileStream := TFileStream.Create(filePath, fmOpenRead or fmShareDenyWrite);
  // the response frees the stream after it has been sent
  Response.FreeContentStream := True;
  Response.ContentStream := fileStream;
  Response.ContentType := ContentTypeOf(fileName);
  // force download
  CustomHeader['Content-Disposition'] := 'attachment; filename="' + fileName + '"';
  CustomHeader['X-Content-Type-Options'] := 'nosniff';
end;

end.
