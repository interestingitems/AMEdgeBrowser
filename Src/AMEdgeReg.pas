unit AMEdgeReg;

interface
uses Vcl.Edge,System.Classes;

procedure Register;
implementation

uses  AMEdgeBrowser,DesignIntf;

procedure Register;
begin
  RegisterComponents('AMEdgeBrowser', [TAMEdgeBrowser]); // may contain multiple components
  RegisterPropertyEditor(TypeInfo(TWebViewStatusEvent), TAMEdgeBrowser, 'OnCreateWebViewCompleted', nil);
  RegisterPropertyEditor(TypeInfo(TNewWindowRequestedEvent), TAMEdgeBrowser, 'OnNewWindowRequested', nil);
  RegisterPropertyEditor(TypeInfo(TProcessFailedEvent), TAMEdgeBrowser, 'OnProcessFailed', nil);
  RegisterPropertyEditor(TypeInfo(TScriptDialogOpeningEvent), TAMEdgeBrowser, 'OnScriptDialogOpening', nil);
end;


end.
