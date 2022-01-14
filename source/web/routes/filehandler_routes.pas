unit filehandler_routes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, fastplaz_handler;

implementation

uses filehandler_controller, download_controller;

initialization
  Route[ '/download/(?P<filename>.*)'] := TDownloadController;
  Route[ '/'] := TFilehandlerController; // Main Controller

end.

