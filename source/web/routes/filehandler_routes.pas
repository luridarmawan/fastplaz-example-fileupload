unit filehandler_routes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpjson, fastplaz_handler;

implementation

uses filehandler_controller;

initialization
  Route[ '/'] := TFilehandlerController; // Main Controller

end.

