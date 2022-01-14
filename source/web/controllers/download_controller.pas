unit download_controller;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, html_lib, fpcgi, fpjson, json_lib, HTTPDefs, 
    fastplaz_handler, database_lib, string_helpers, dateutils, datetime_helpers;

type
  TDownloadController = class(TMyCustomController)
  private
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

constructor TDownloadController.CreateNew(AOwner: TComponent; 
  CreateMode: integer);
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
  fileName: string;
  imgStream: TFileStream;
begin
  fileName:= _GET['filename'];
  if fileName.IsEmpty then
    Die('Invalid Request');
  if not FileExists(UPLOAD_FOLDERS + fileName) then
    Die('File not exists.');

  imgStream := TFileStream.Create(UPLOAD_FOLDERS + fileName, fmOpenRead);
  Response.ContentStream := imgStream;

  Response.ContentType:= 'image/' + ExtractFileExt(fileName);
  Response.SendContent;

  imgStream.Free;
end;

// POST Method Handler
procedure TDownloadController.Post;
begin
  Response.Content := 'This is POST Method';
end;

end.

