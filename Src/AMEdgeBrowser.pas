unit AMEdgeBrowser;

interface

uses
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Winapi.Messages, System.SysUtils, Winapi.Windows, Vcl.OleCtrls, SHDocVw,
  WebView2, System.NetEncoding, Winapi.ActiveX, Vcl.Edge, System.Classes,
  System.IOUtils, comobj, vcl.Graphics, System.UITypes, AMEdgeConstant,
  AMEdgeInterface, AMEdgeStructure;


 (*TODO:
 [AddToCache]      how read/write db ???
 [AddToCoockie]    ICoreWebView2_2 ICoreWebView2CookieManager
 [Cache]           for PNG tiles //partial ??
 [cache]           Clear before navigate ?? why navigate is not virtual ??
 [Work Offline]    ICoreWebView2_3 and SetVirtualHostNameToFolderMapping??
 [ReadOnlu]        onKeypRess doesn't work for ReadOnly and click mouse  why event exists but non work... in WebView2 Microsoft interface not found any ???
 [DisableShortcut] doesn't work properly (disable always)
 [language]        by resource and Tsilang with dedicate property on object inspector for MessageDlg
 [language]        for context menu  CoreWebView2EnvironmentOptions.Language
 [popupmenu]       Not exists (realy??) implement in ICoreWebView2_4 example https://github.com/MicrosoftEdge/WebView2Feedback/blob/master/specs/ContextMenuRequested.md
 [LOG]             Timing event
 [LOG]             Class helper for access to LastReordError con critcal section  (why not virtual ?? )
 [Component]       How to hide the TEdgeBrowser public event/function use from my extention??
 *)


type

  {Custom event}
  TOnLogErrorAm               = procedure(const aFunction, Description: String;var aRaise:Boolean) of object;
  TScriptDialogOpeningEventAM = procedure (Sender: TCustomEdgeBrowser; Args: TScriptDialogOpeningEventArgs;const aUrl,Msg:string) of object;
  TExecuteScriptEventAM       = procedure (Sender: TCustomEdgeBrowser; const AResultObjectAsJson: string) of object;

  { These properties can be customized only after creation
    of the webView each modification involves a new navigation
    to be apply

    -- for now I do not manage the self-navigation in case of modification
  }
  TAMCustomization = class(TPersistent)
  private
    FDefaultContextMenusEnabled  : Boolean;      {Disable/Enable popmenu of web page}
    FDefaultScriptDialogsEnabled : Boolean;      {Catch Alert,confirm ecc from webpage on event scripDialog}
    FDevEnabled                  : Boolean;      {Disable/Enable dev tools}
    FZoomEnabled                 : Boolean;      {Disable/Enable zoom}
    FDisableShortCut             : Boolean;      {Enabled/Disable shortcut see comment ICoreWebView2Settings3 for details}
    FStatusBarEnabled            : Boolean;      {??}
    FWebMessageEnabled           : Boolean;      {??}
    FAllowNewWindows             : Boolean;      {Disable/Enabled Open new windows when browser is not readonly }
//    FScriptEnabled               : Boolean;    {Some problem with this options}
    FAutoRecreateOnFailed        : Boolean;      {In case of exception the webview is recreate in automatic}
    FReadOnly                    : Boolean;      {Avoid to navigate on link of page or write edit}
    FOnchange                    : TNotifyEvent; {Envet for apply the change}
    procedure Change;
    procedure SetDefaultContextMenusEnabled(const Value: Boolean);
    procedure SetDefaultScriptDialogsEnabled(const Value: Boolean);
    procedure SetDevEnabled(const Value: Boolean);
    procedure SetStatusBarEnabled(const Value: Boolean);
    procedure SetWebMessageEnabled(const Value: Boolean);
    procedure SetZoomEnabled(const Value: Boolean);
    procedure SetDisableShortCut(const Value: Boolean);
  public
    property OnChange                     : TNotifyEvent  read FOnchange                     write FOnChange;
  published
    property DefaultContextMenusEnabled   : Boolean       read FDefaultContextMenusEnabled   write SetDefaultContextMenusEnabled  default false;
    property DefaultScriptDialogsEnabled  : Boolean       read FDefaultScriptDialogsEnabled  write SetDefaultScriptDialogsEnabled default True;
    property DevEnabled                   : Boolean       read FDevEnabled                   write SetDevEnabled                  default false;
    property StatusBarEnabled             : Boolean       read FStatusBarEnabled             write SetStatusBarEnabled            default false; {??}
    property AllowNewWindows              : Boolean       read FAllowNewWindows             write FAllowNewWindows                default false; {??}
    property DisableShortCut              : Boolean       read FDisableShortCut              write SetDisableShortCut             default false; {??}
    property ReadOnly                     : Boolean       read FReadOnly                     write FReadOnly                      default False;
    property WebMessageEnabled            : Boolean       read FWebMessageEnabled            write SetWebMessageEnabled           default false; {??}
    property ZoomEnabled                  : Boolean       read FZoomEnabled                  write SetZoomEnabled                 default false;
    property AutoRecreateOnFailed         : Boolean       read FAutoRecreateOnFailed         write FAutoRecreateOnFailed          default True;
  End;

  {Customization cache }
  TCacheProperties = class(TPersistent)
  private
    FClearCachePathOnStart     : Boolean; {Clear cache after create WebView}
    FClerCachepathOnNavigate   : Boolean; {Clear cache before navigate}
    FRemovePNGCacheFile        : Boolean; {Try to save PNG file in cache whene is clear}
    FCachePathByComponentName  : Boolean; {Create forder cache by name of component}
    FUseDefaultCache           : Boolean; {Use default cache of edgbrowser}
  published
    property ClearCachePathOnStart   : Boolean  read FClearCachePathOnStart    write FClearCachePathOnStart     default True;
    property UseDefaultCache         : Boolean  read FUseDefaultCache          write FUseDefaultCache           default false;
    property RemovePNGCacheFile      : Boolean  read FRemovePNGCacheFile       write FRemovePNGCacheFile        default False;
    property ClerCachepathOnNavigate : Boolean  read FClerCachepathOnNavigate  write FClerCachepathOnNavigate   default False;
    property CachePathByComponentName: Boolean  read FCachePathByComponentName write FCachePathByComponentName  default false;
  end;

  TAMEdgeBrowser = class(TCustomEdgeBrowser)
  private
    FAMCustomization             : TAMCustomization;
    FCacheProperties             : TCacheProperties;
    FbackgroundColorDefault      : TCOREWEBVIEW2_COLOR;  {Save original background color for restore it}
    FColorWebView                : TAlphaColor;          {Color background WebView}
    FSavedDefaultBacground       : Boolean;              {Indicate if original color background is saved}
    FUserAgent                   : string;
    FUserAgentOrig               : string;               {Save orignal user agent for restore}

    {Custom event}
    FOnScriptDialogOpeningAM     : TScriptDialogOpeningEventAM;
    FOnCreateWebViewCompletedAM  : TWebViewStatusEvent;
    FOnNewWindowRequestedAM      : TNewWindowRequestedEvent;
    FOnProcessFailedAM           : TProcessFailedEvent;
    FOnExecuteScriptAM           : TExecuteScriptEventAM;
    FOnErrorExecuteScriptAM      : TExecuteScriptEventAM;
    FOnLogErrorAm                : TOnLogErrorAm;
    function GetBrowserVersionInfo: string;
    {Cache managment}
    function GetCachePath: string;
    function ClearCachePathAndCreate: Boolean;
    function GetCachePathFiles: string;

    {Catch event of TEdgeBrowser}
    procedure CreateWebViewCompleted(Sender: TCustomEdgeBrowser;AResult: HResult);
    procedure NewWindowRequested(Sender: TCustomEdgeBrowser;Args: TNewWindowRequestedEventArgs);
    procedure ProcessFailed(Sender: TCustomEdgeBrowser; FailureType: TOleEnum);
    procedure ScriptDialogOpening(Sender: TCustomEdgeBrowser;Args: TScriptDialogOpeningEventArgs);
    procedure DoExecuteScript(Sender: TCustomEdgeBrowser; AResult: HRESULT;const AResultObjectAsJson: string);
    procedure DoErrorLog(const aFunction, Description: String);

    {Colo managment}
    procedure SetColorWebView(const value : TAlphaColor);
    procedure SaveDefaultBackGround;
    procedure OnChangeAmCustomization(sender: TObject);
    procedure SetAmCustomizazion;
    procedure setUserAgent(const Value: string);
    procedure ApplyUserAgent;
    procedure SetShortCut;
    procedure ApplyColorWebView;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ClearCachePath: Boolean;
    property AMBrowserVersionInfo : String  read GetBrowserVersionInfo;
    procedure SaveScreenShot(const aFilename: string);
    function GetHTMLSource:string;
  published
    property AMCustomization  : TAMCustomization     read FAMCustomization  write FAMCustomization;
    property CacheProperties  : TCacheProperties     read FCacheProperties  write FCacheProperties;
    property ColorWebView     : TAlphaColor          read FColorWebView     write SetColorWebView;
    property UserAgent        : string               read FUserAgent        write setUserAgent stored True;
    property Align;
    property Anchors;
    property TabOrder;
    property TabStop;
    property OnEnter;
    property OnExit;
    /// <summary>
    ///   Fired when the captured screenshot of the WebView has been saved
    /// </summary>
    property OnCapturePreviewCompleted;
    /// <summary>
    ///   Fired when the ContainsFullScreenElement property changes, which means that an HTML element inside the
    ///   WebView is entering or leaving fullscreen. The event handler can make the control larger or smaller as
    ///   required.
    /// </summary>
    property OnContainsFullScreenElementChanged;
    /// <summary>
    ///   Fired before any content is loaded. This follows the OnNavigationStarting and OnSourceChanged events
    ///   and precedes the OnHistoryChanged and OnNavigationCompleted events.
    /// </summary>
    property OnContentLoading;

    /// <summary>
    ///   Fired when a Chrome DevTools Protocol event, previously subscribed to with SubscribeToCDPEvent, occurs
    /// </summary>
    property OnDevToolsProtocolEventReceived;
    /// <summary>
    ///   Fired when the DocumentTitle property of the WebView changes and may fire before or after the
    ///   OnNavigationCompleted event
    /// </summary>
    property OnDocumentTitleChanged;

    /// <summary>
    ///   Fired when a child frame in the WebView requests permission to navigate to a different URI. This will fire
    ///   for redirects as well.
    /// </summary>
    property OnFrameNavigationStarting;
    /// <summary>
    ///   Fired when a child frame in the WebView has completely loaded or loading stopped with error.
    /// </summary>
    property OnFrameNavigationCompleted;
    /// <summary>
    ///   Fired on change of navigation history for the top level document. OnHistoryChanged fires after
    ///   OnSourceChanged and OnContentLoading
    /// </summary>
    property OnHistoryChanged;
    /// <summary>
    ///   Fired when the WebView main frame requests permission to navigate to a different URI. This will fire for
    ///   redirects as well.
    /// </summary>
    property OnNavigationStarting;
    /// <summary>
    ///   Fired when the WebView has completely loaded or loading stopped with error.
    /// </summary>
    property OnNavigationCompleted;
    /// <summary>
    ///   Fired when content in a WebView requests permission to access a privileged resource
    /// </summary>
    property OnPermissionRequested;
    /// <summary>
    ///   Fired when a JavaScript dialog (alert, confirm, or prompt) will show for the Webview. This event only
    ///   fires if the DefaultScriptDialogsEnabled property is False. The ScriptDialogOpening event can be used
    ///   to suppress dialogs or replace default dialogs with custom dialogs.
    /// </summary>
    property OnSourceChanged;
    /// <summary>
    ///   Fired when the WebMessageEnabled property is True and the top level document of the W webView calls
    ///   window.chrome.webview.postMessage
    /// </summary>
    property OnWebMessageReceived;
    /// <summary>
    ///   Fired when the WebView is performing an HTTP request to a matching URL and resource context filter that was
    ///   added with AddWebResourceRequestedFilter. At least one filter must be added for the event to fire.
    /// </summary>
    property OnWebResourceRequested;
    /// <summary>
    ///   Fires when content inside the WebView requested to close the window, such as after window.close is called.
    ///   The app should close the WebView and related app window if that makes sense to the app.
    /// </summary>
    property OnWindowCloseRequested;
    /// <summary>
    ///   Fired when the ZoomFactor property of the WebView changes. The event could fire because the caller modified
    ///   the ZoomFactor property, or due to the user manually modifying the zoom, but not from a programmatic change.
    /// </summary>
    property OnZoomFactorChanged;

    //** Customizzazione AM su eventi ** //

    /// <summary>
    ///   Fired when the WebView control creation has completed, either successfully or unsuccessfully (for example
    ///   Edge is not installed or the WebView2 control cannot loaded)
    /// </summary>
    property OnCreateWebViewCompletedAM : TWebViewStatusEvent         read FOnCreateWebViewCompletedAM   write FOnCreateWebViewCompletedAM;
    /// <summary>
    ///   OnNewWindowRequested fires when content inside the WebView requested to open a new window, such as through
    ///   window.open or through a context menu
    /// </summary>
    property OnNewWindowRequestedAM     : TNewWindowRequestedEvent    read FOnNewWindowRequestedAM       write FOnNewWindowRequestedAM;
    /// <summary>
    ///   Fired when a WebView process terminated unexpectedly or become unresponsive
    /// </summary>

    property OnProcessFailedAM          : TProcessFailedEvent         read FOnProcessFailedAM            write FOnProcessFailedAM;
    /// <summary>
    ///   Fired for navigating to a different site or fragment navigations. It will not fires for other types of
    ///   navigations such as page reloads. OnSourceChanged fires before OnContentLoading for navigation to a new
    ///   document.
    /// </summary>
    property OnScriptDialogOpeningAM    : TScriptDialogOpeningEventAM read FOnScriptDialogOpeningAM      write FOnScriptDialogOpeningAM;
    /// <summary>
    ///   Fires when script as invoked by ExecuteScript completes
    /// </summary>
    property OnExecuteScriptAM          : TExecuteScriptEventAM       read FOnExecuteScriptAM            write FOnExecuteScriptAM;
    property OnErrorExecuteScriptAM     : TExecuteScriptEventAM       read FOnErrorExecuteScriptAM       write FOnErrorExecuteScriptAM;
    property OnLogErroAM                : TOnLogErrorAm               read FOnLogErrorAm                 write FOnLogErrorAm;
  end;


implementation

{ TAMEdgeBrowser }
constructor TAMEdgeBrowser.Create(AOwner: TComponent);
begin
  {Cache}
  FCacheProperties                              := TCacheProperties.Create;
  FCacheProperties.RemovePNGCacheFile           := False;
  FCacheProperties.ClearCachePathOnStart        := True;
  FCacheProperties.ClerCachepathOnNavigate      := False;
  FCacheProperties.UseDefaultCache              := False;
  FCacheProperties.CachePathByComponentName     := False;

  {Custom}
  FAMCustomization                             := TAMCustomization.Create;
  FAMCustomization.DefaultContextMenusEnabled  := False;
  FAMCustomization.DefaultScriptDialogsEnabled := True;
  FAMCustomization.DevEnabled                  := False;
  FAMCustomization.StatusBarEnabled            := False;
  FAMCustomization.AllowNewWindows             := False;
  FAMCustomization.WebMessageEnabled           := False;
  FAMCustomization.ZoomEnabled                 := False;
  FAMCustomization.AutoRecreateOnFailed        := True;
  FAMCustomization.ReadOnly                    := False;
  FAMCustomization.DisableShortCut             := False;
  FAMCustomization.OnChange                    := OnChangeAmCustomization;
  {Customization color WebView}
  ColorWebView                                 := clDefault;
  FSavedDefaultBacground                       := False;
  FUserAgent                                   := '';
  inherited Create(AOwner);

  if not FCacheProperties.UseDefaultCache  then
    Self.UserDataFolder := GetCachePath;
  {Assign custom event}
  OnCreateWebViewCompleted := CreateWebViewCompleted;
  OnNewWindowRequested     := NewWindowRequested;
  OnProcessFailed          := ProcessFailed;
  OnScriptDialogOpening    := ScriptDialogOpening;
  OnExecuteScript          := DOExecuteScript;
end;

Procedure TAMEdgeBrowser.OnChangeAmCustomization(sender : TObject);
begin
  SetAmCustomizazion;
end;

Procedure TAMEdgeBrowser.ApplyColorWebView;
var Ctrl2     : ICoreWebView2Controller2;
    BackColor : TCOREWEBVIEW2_COLOR;
    HR        : HRESULT;
begin
  if not WebViewCreated then exit;
  self.ControllerInterface.QueryInterface(IID_ICoreWebView2Controller2, Ctrl2);
  if not Assigned(Ctrl2) then
    DoErrorLog('ApplyColorWebView','ICoreWebView2Controller2 not found');

  if ( ColorWebView <> clDefault ) then
  begin
    BackColor.A := TAlphaColorRec(ColorWebView).A;
    BackColor.R := TAlphaColorRec(ColorWebView).R;
    BackColor.G := TAlphaColorRec(ColorWebView).G;
    BackColor.B := TAlphaColorRec(ColorWebView).B;
    HR          := Ctrl2.put_DefaultBackgroundColor(BackColor);
    if not Succeeded(HR) then
    DoErrorLog('ApplyColorWebView',Format('put_DefaultBackgroundColor failed %d',[HR]))

  end
  else if FSavedDefaultBacground then
  begin
    HR := Ctrl2.put_DefaultBackgroundColor(FbackgroundColorDefault);
    if not SUCCEEDED(HR) then
    DoErrorLog('ApplyColorWebView',Format('put_DefaultBackgroundColor not failed %d',[HR]))
  end;
end;

Procedure TAMEdgeBrowser.SetColorWebView(const value : TAlphaColor);
begin
  if FColorWebView <> Value then
  begin
    FColorWebView := Value;
    ApplyColorWebView;
  end;
end;

procedure TAMEdgeBrowser.setUserAgent(const Value: string);
begin
  if FUserAgent <> Value then
  begin
    FUserAgent := Value;
    ApplyUserAgent;
  end;
end;

procedure TAMEdgeBrowser.SetShortCut;
var Ctrl3 : ICoreWebView2Settings3;
    HR    : HRESULT;
begin
  if not WebViewCreated then exit;

  SettingsInterface.QueryInterface(IID_ICoreWebView2Settings3, Ctrl3);
  if not Assigned(Ctrl3) then
  begin
    DoErrorLog('SetShortCut','IID_ICoreWebView2Settings3 not found');
    Exit;
  end;

  HR := Ctrl3.put_AreBrowserAcceleratorKeysEnabled(LongBool(Not FAMCustomization.DisableShortCut));

  if not Succeeded(HR) then
    DoErrorLog('SetShortCut',Format('put_AreBrowserAcceleratorKeysEnabled error %d',[HR]));
end;

procedure TAMEdgeBrowser.ApplyUserAgent;
var Ctrl2 : ICoreWebView2Settings2;
    HR    : HRESULT;
    tmp   : PChar;
begin
  if not WebViewCreated then exit;
  if ( FUserAgent.Trim = '' ) and (FUserAgentOrig.Trim = '') then exit;

  SettingsInterface.QueryInterface(IID_ICoreWebView2Settings2, Ctrl2);
  if not Assigned(Ctrl2) then
  begin
    DoErrorLog('ApplyUserAgent','IID_ICoreWebView2Settings2 not found');
    Exit;
  end;

  {Store orginal UserAnger for restore}
  if (FUserAgentOrig.Trim = '') then
  begin
    HR := Ctrl2.get_UserAgent(tmp);
    if Succeeded(HR) then
    begin
      FUserAgentOrig := tmp;
      CoTaskMemFree(tmp);
    end
    else
      DoErrorLog('ApplyUserAgent',Format('get_UserAgent error %d',[HR]))
  end;

  {restore user agent}
  if (FUserAgentOrig.Trim <> '') and (FUserAgent.Trim = '')  then
  begin
    HR := Ctrl2.put_UserAgent(PChar(FUserAgentOrig));
    if Succeeded(HR) then
      FUserAgentOrig := '' {stopping other restores}
    else
      DoErrorLog('ApplyUserAgent',Format('set_UserAgent error %d',[HR]))
  end;

  if (FUserAgent.Trim <> '')  then
  begin
    {BUG https://github.com/MicrosoftEdge/WebView2Feedback/issues/1861}
    HR := Ctrl2.put_UserAgent(PChar(FUserAgent));
    if not Succeeded(HR) then
      DoErrorLog('ApplyUserAgent',Format('set_UserAgent error %d',[HR]));
  end;
end;

Procedure TAMEdgeBrowser.SaveDefaultBackGround;
var Ctrl2 : ICoreWebView2Controller2;
    HR    : HRESULT;
begin
  if not WebViewCreated then exit;

  ControllerInterface.QueryInterface(IID_ICoreWebView2Controller2, Ctrl2);
  if not Assigned(Ctrl2) then
  begin
    DoErrorLog('SaveDefaultBackGround','ICoreWebView2Controller2 not found');
    Exit;
  end;

  HR := Ctrl2.get_DefaultBackgroundColor(FbackgroundColorDefault);

  if not SUCCEEDED(HR) then
    DoErrorLog('SaveDefaultBackGround','get_DefaultBackgroundColor failed' + SysErrorMessage(GetLastError))
  else
    FSavedDefaultBacground := True;
end;

procedure TAMEdgeBrowser.SetAmCustomizazion;
begin
  if not WebViewCreated then exit;
  self.DefaultContextMenusEnabled  := FAMCustomization.DefaultContextMenusEnabled;
  self.DefaultScriptDialogsEnabled := FAMCustomization.DefaultScriptDialogsEnabled;
  self.DevToolsEnabled             := FAMCustomization.DevEnabled;
  self.StatusBarEnabled            := FAMCustomization.StatusBarEnabled;
  self.ZoomControlEnabled          := FAMCustomization.ZoomEnabled;
  SetShortCut;
end;

procedure TAMEdgeBrowser.CreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HResult);
var aMsg : String;
begin
  if CacheProperties.ClearCachePathOnStart then
     ClearCachePathAndCreate;

  if Succeeded(AResult) then
  begin
    if not FSavedDefaultBacground then
      SaveDefaultBackGround;
    ApplyColorWebView;
    SetAmCustomizazion;
    ApplyUserAgent;
  end
  else
  begin
    if AResult = HResultFromWin32(ERROR_FILE_NOT_FOUND) then
    begin

      aMsg := 'Could not find Edge installation. ' +
              'Do you have a version installed that''s compatible with this WebView2 SDK version?';
      DoErrorLog('CreateWebViewCompleted',aMsg);
      Application.MessageBox(Pchar(aMsg),'Edge initialisation error', MB_OK or MB_ICONERROR);
    end
    else if AResult = E_FAIL then
    begin
      aMsg := 'Failed to initialise Edge loader';
      DoErrorLog('CreateWebViewCompleted',aMsg);
      Application.MessageBox(Pchar(aMsg), 'Edge initialisation error', MB_OK or MB_ICONERROR)
    end
    else
    begin
      try
        OleCheck(AResult)
      except on E: Exception do
        begin
          aMsg := Format('Failed to initialise Edge: %s', [E.Message]);
          DoErrorLog('CreateWebViewCompleted',aMsg);
          Application.MessageBox(PChar(aMsg),'Edge initialisation error', MB_OK or MB_ICONERROR)
        end;
      end;
    end;
  end;
  if Assigned(OnCreateWebViewCompletedAM) then
    OnCreateWebViewCompletedAM(Sender,AResult);
end;

Function TAMEdgeBrowser.ClearCachePathAndCreate:Boolean;
begin
  Result := false;
  Try
    if not ClearCachePath then exit;
    ForceDirectories(GetCachePath);
    SetFileAttributes(Pchar(GetCachePath), FILE_ATTRIBUTE_HIDDEN);
    Result := TDirectory.Exists(GetCachePath);
    if not Result then
      DoErrorLog('ClearCachePathAndCreate',Format('Directory not exists %s error %s',[GetCachePath,SysErrorMessage(GetLastError)]))
  Except on E: Exception do
    DoErrorLog('ClearCachePathAndCreate',Format('Unable create cache path %s exception %s',[GetCachePath,E.Message]))
  End;
end;

Function TAMEdgeBrowser.ClearCachePath:Boolean;
var aLIstFile    : TArray<String>;
    I            : Integer;
    aImageStream : TMemoryStream;
    aDelFile     : Boolean;
    aBuffer      : Word;
begin
  Result := false;
  Try
    if TDirectory.Exists(GetCachePath) then
    begin
      if Not CacheProperties.RemovePNGCacheFile then
        TDirectory.Delete(GetCachePath,True)
      else
      begin
        {Questa cosa puo rallentare magari farla su thread differente?}
        aLIstFile := TDirectory.GetFiles(GetCachePathFiles,'F*',TSearchOption.soAllDirectories);

        for I := Low(aLIstFile) to High(aLIstFile) do
        begin
          aDelFile     := True;
          aImageStream := TMemoryStream.Create;
          try
            aImageStream.LoadFromFile(aLIstFile[I]);
            aImageStream.Position := 0;
            if aImageStream.Size = 0 then Continue;

            aImageStream.ReadBuffer(aBuffer,2);
            if aBuffer = $5089 then //PNG File
              aDelFile := False;
          finally
            FreeAndNil(aImageStream);
          end;
          if aDelFile then
            TFile.Delete(aLIstFile[I])
        end;

        SetLength(aLIstFile,0);

        //TODO delete others directory ??

        //TODO update DB ?INDEX e DATA ?
      end;
    end;
    Result := true;
  Except on E: Exception do
    DoErrorLog('ClearCachePath',Format('Unable delete cache path %s exception %s',[GetCachePath,E.Message]))
  End;
end;

Function TAMEdgeBrowser.GetCachePath : string;
begin
  if FCacheProperties.UseDefaultCache then
    Result := Self.UserDataFolder
  else if FCacheProperties.CachePathByComponentName then
    Result := TPath.Combine(TPath.GetDirectoryName(Application.ExeName),Format('EdgeCache_%S',[Self.Name]))
  else
    Result := TPath.Combine(TPath.GetDirectoryName(Application.ExeName),'EdgeCache\');
end;

Function TAMEdgeBrowser.GetCachePathFiles : string;
begin
  Result := TPath.Combine(GetCachePath,PATH_CACHE);
end;

function TAMEdgeBrowser.GetHTMLSource: string;
var HTML_Source: string;
    aStart     : DWord;
begin
  Result      := '';
  HTML_Source := '';
  if WebViewCreated then
  begin
    Self.DefaultInterface.ExecuteScript('encodeURI(document.documentElement.outerHTML)',ICoreWebView2ExecuteScriptCompletedHandler(
      function (errorCode: HResult; resultObjectAsJson: PWideChar): HResult stdcall
      begin
        if resultObjectAsJson = 'null' then
          HTML_Source := ''
        else
          HTML_Source := TNetEncoding.URL.Decode(resultObjectAsJson).DeQuotedString('"');
        Result := S_OK;
      end));

    {find a more elegant method than...this.. :( }
    aStart := GetTickCount;
    while HTML_Source = '' do
    begin
      Application.ProcessMessages;

      if GetTickCount - aStart > 4000 then
        HTML_Source := 'Timeout';
    end;
    Result := HTML_Source;
  end;

end;

Function TAMEdgeBrowser.GetBrowserVersionInfo:string;
const SAfterBefore: array[Boolean] of string = ('Before', 'After');
begin
  Result := Format( '%s WebView Creation %S',[SAfterBefore[Self.WebViewCreated],Self.BrowserVersionInfo]);
end;

Procedure TAMEdgeBrowser.SaveScreenShot(const aFilename:string);
begin
  // Manca qualcosa ???
  self.CapturePreview(aFilename);
end;

procedure TAMEdgeBrowser.NewWindowRequested(Sender: TCustomEdgeBrowser; Args: TNewWindowRequestedEventArgs);
var iHandled : integer;
begin
  iHandled := 0;
  if Not FAMCustomization.AllowNewWindows or FAMCustomization.ReadOnly then
    iHandled := 1;

  Args.ArgsInterface.Set_Handled(iHandled);
  if Assigned(FOnNewWindowRequestedAM) then
    FOnNewWindowRequestedAM(Sender,Args)
end;

procedure TAMEdgeBrowser.ProcessFailed(Sender: TCustomEdgeBrowser; FailureType: TOleEnum);
begin
  if FailureType = COREWEBVIEW2_PROCESS_FAILED_KIND_BROWSER_PROCESS_EXITED then
  begin
    if FAMCustomization.AutoRecreateOnFailed then
      self.ReinitializeWebView;
  end;

  if Assigned(FOnProcessFailedAM) then
    FOnProcessFailedAM(Sender,FailureType);
end;

procedure TAMEdgeBrowser.DoExecuteScript(Sender: TCustomEdgeBrowser;
  AResult: HRESULT; const AResultObjectAsJson: string);
begin
  if Succeeded(AResult) then
  begin
    if Assigned(FOnExecuteScriptAM) then
      FOnExecuteScriptAM(Sender,AResultObjectAsJson)
  end
  else if Assigned(FOnErrorExecuteScriptAM) then
    FOnErrorExecuteScriptAM(Sender,AResultObjectAsJson)
end;

procedure TAMEdgeBrowser.ScriptDialogOpening(Sender: TCustomEdgeBrowser;
  Args: TScriptDialogOpeningEventArgs);
var Uri  : PChar;
    Msg  : PChar;
    sUrl : string;
    sMsg : string;
begin
  sMsg := '';
  sUrl := '';
  if Succeeded(Args.ArgsInterface.Get_uri(Uri)) then
  begin
    sUrl := Format('%s',[Uri]);
    CoTaskMemFree(Uri);
  end;

  if Succeeded(Args.ArgsInterface.Get_Message(Msg)) then
  begin
    sMsg := Format('%s',[Msg]);
    CoTaskMemFree(Msg);
  end;

  if Assigned(OnScriptDialogOpeningAM) then
    OnScriptDialogOpeningAM(Sender,Args,sUrl,sMsg);
end;

destructor TAMEdgeBrowser.Destroy;
begin
  FAMCustomization.OnChange := nil;
  FreeAndNil(FAMCustomization);
  FreeAndNil(FCacheProperties);
  inherited;
end;

Procedure TAMEdgeBrowser.DoErrorLog(const aFunction,Description : String);
var aRaise : Boolean;
begin
  aRaise := True;
  if Assigned(FOnLogErrorAm) then
  begin
    aRaise := False;
    FOnLogErrorAm(aFunction,Description,aRaise);
  end;
  if aRaise then
    raise Exception.Create(Format('%s - %s',[aFunction,Description]));
end;

{ TColorWebView }


{ TAMCustomization }

procedure TAMCustomization.Change;
begin
  if Assigned(FOnchange) then
    FOnchange(self);
end;

procedure TAMCustomization.SetDefaultContextMenusEnabled(const Value: Boolean);
begin
  if FDefaultContextMenusEnabled <> Value then
  begin
    FDefaultContextMenusEnabled := Value;
    Change;
  end;
end;

procedure TAMCustomization.SetDefaultScriptDialogsEnabled(const Value: Boolean);
begin
  if FDefaultScriptDialogsEnabled <> Value then
  begin
    FDefaultScriptDialogsEnabled := Value;
    Change;
  end;
end;

procedure TAMCustomization.SetDevEnabled(const Value: Boolean);
begin
  if FDevEnabled <> Value then
  begin
    FDevEnabled := Value;
    Change;
  end;
end;

procedure TAMCustomization.SetDisableShortCut(const Value: Boolean);
begin
  if FDisableShortCut <> Value then
  begin
    FDisableShortCut := Value;
    Change;
  end;
end;

procedure TAMCustomization.SetStatusBarEnabled(const Value: Boolean);
begin
  if FStatusBarEnabled <> Value then
  begin
    FStatusBarEnabled := Value;
    Change;
  end;
end;

procedure TAMCustomization.SetWebMessageEnabled(const Value: Boolean);
begin
  if FWebMessageEnabled <> Value then
  begin
    FWebMessageEnabled := Value;
    Change;
  end;
end;

procedure TAMCustomization.SetZoomEnabled(const Value: Boolean);
begin
  if FZoomEnabled <> Value then
  begin
    FZoomEnabled := Value;
    Change;
  end;
end;

end.
