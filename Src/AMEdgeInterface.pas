unit AMEdgeInterface;

interface

uses WebView2,AMEdgeStructure,Winapi.Windows;

type
  /// A continuation of the ICoreWebView2Controller2 interface.
  ICoreWebView2Controller2 = interface(ICoreWebView2Controller)
    ['{C979903E-D4CA-4228-92EB-47EE3FA96EAB}']
    /// The `DefaultBackgroundColor` property is the color WebView renders
    /// underneath all web content. This means WebView renders this color when
    /// there is no web content loaded such as before the initial navigation or
    /// between navigations. This also means web pages with undefined css
    /// background properties or background properties containing transparent
    /// pixels will render their contents over this color. Web pages with defined
    /// and opaque background properties that span the page will obscure the
    /// `DefaultBackgroundColor` and display normally. The default value for this
    /// property is white to resemble the native browser experience.
    ///
    /// The Color is specified by the COREWEBVIEW2_COLOR that represents an RGBA
    /// value. The `A` represents an Alpha value, meaning
    /// `DefaultBackgroundColor` can be transparent. In the case of a transparent
    /// `DefaultBackgroundColor` WebView will render hosting app content as the
    /// background. This Alpha value is not supported on Windows 7. Any `A` value
    /// other than 255 will result in E_INVALIDARG on Windows 7.
    /// It is supported on all other WebView compatible platforms.
    ///
    /// Semi-transparent colors are not currently supported by this API and
    /// setting `DefaultBackgroundColor` to a semi-transparent color will fail
    /// with E_INVALIDARG. The only supported alpha values are 0 and 255, all
    /// other values will result in E_INVALIDARG.
    /// `DefaultBackgroundColor` can only be an opaque color or transparent.
    ///
    /// \snippet ViewComponent.cpp DefaultBackgroundColor
    function get_DefaultBackgroundColor(out backgroundColor : TCOREWEBVIEW2_COLOR) : HRESULT; stdcall;
    // Sets the `DefaultBackgroundColor` property.
    function put_DefaultBackgroundColor(backgroundColor : TCOREWEBVIEW2_COLOR) : HRESULT; stdcall;
  end;

  /// A continuation of the ICoreWebView2Settings interface that manages the user agent}
  ICoreWebView2Settings2 = interface(ICoreWebView2Settings)
    ['{EE9A0F68-F46C-4E32-AC23-EF8CAC224D2A}']

    /// Returns the User Agent. The default value is the default User Agent of the
    /// Microsoft Edge browser.
    ///
    /// \snippet SettingsComponent.cpp UserAgent
    function get_UserAgent(out userAgent:PWideChar):HRESULT;stdcall;
    /// Sets the `UserAgent` property. This property may be overridden if
    /// the User-Agent header is set in a request. If the parameter is empty
    /// the User Agent will not be updated and the current User Agent will remain.
    function put_UserAgent(userAgent:PWideChar):HRESULT;stdcall;
  end;

  /// A continuation of the ICoreWebView2Settings interface that manages whether
  /// browser accelerator keys are enabled.
  ICoreWebView2Settings3 = interface(ICoreWebView2Settings2)
    ['{FDB5AB74-AF33-4854-84F0-0A631DEB5EBA}']
    /// When this setting is set to FALSE, it disables all accelerator keys that
    /// access features specific to a web browser, including but not limited to:
    ///  - Ctrl-F and F3 for Find on Page
    ///  - Ctrl-P for Print
    ///  - Ctrl-R and F5 for Reload
    ///  - Ctrl-Plus and Ctrl-Minus for zooming
    ///  - Ctrl-Shift-C and F12 for DevTools
    ///  - Special keys for browser functions, such as Back, Forward, and Search
    ///
    /// It does not disable accelerator keys related to movement and text editing,
    /// such as:
    ///  - Home, End, Page Up, and Page Down
    ///  - Ctrl-X, Ctrl-C, Ctrl-V
    ///  - Ctrl-A for Select All
    ///  - Ctrl-Z for Undo
    ///
    /// Those accelerator keys will always be enabled unless they are handled in
    /// the `AcceleratorKeyPressed` event.
    ///
    /// This setting has no effect on the `AcceleratorKeyPressed` event.  The event
    /// will be fired for all accelerator keys, whether they are enabled or not.
    ///
    /// The default value for `AreBrowserAcceleratorKeysEnabled` is TRUE.
    ///
    /// \snippet SettingsComponent.cpp AreBrowserAcceleratorKeysEnabled
    function get_AreBrowserAcceleratorKeysEnabled(out areBrowserAcceleratorKeysEnabled:BOOL):HRESULT;stdcall;
    /// Sets the `AreBrowserAcceleratorKeysEnabled` property
    function put_AreBrowserAcceleratorKeysEnabled(areBrowserAcceleratorKeysEnabled:BOOL):HRESULT;stdcall;
  end;


implementation

end.
