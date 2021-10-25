unit AMEdgeInterface;

interface

uses WebView2,AMEdgeStructure,Winapi.Windows,Winapi.ActiveX;

type
  ICoreWebView2Frame             = interface;
  ICoreWebView2DownloadOperation = interface;
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
    function get_AreBrowserAcceleratorKeysEnabled(out areBrowserAcceleratorKeysEnabled:Integer):HRESULT;stdcall;
    /// Sets the `AreBrowserAcceleratorKeysEnabled` property
    function put_AreBrowserAcceleratorKeysEnabled(areBrowserAcceleratorKeysEnabled:Integer):HRESULT;stdcall;
  end;

  // Event args for the DOMContentLoaded event.
  ICoreWebView2DOMContentLoadedEventArgs = interface(IUnknown)
    ['{16B1E21A-C503-44F2-84C9-70ABA5031283}']
    /// The ID of the navigation which corresponds to other navigation ID properties on other navigation events.
    function get_navigation_id(out navigation_id:Largeuint):HRESULT;stdcall;
  end;

  /// Receives `DOMContentLoaded` events.
  ICoreWebView2DOMContentLoadedEventHandler = interface(IUnknown)
    ['{4BAC7E9C-199E-49ED-87ED-249303ACF019}']
    /// Provides the event args for the corresponding event.
    function invoke(const sender: ICoreWebView2; const args:ICoreWebView2DOMContentLoadedEventArgs):HRESULT;stdcall;
  end;

  /// Event args for the WebResourceResponseReceived event.
  ICoreWebView2WebResourceResponseReceivedEventArgs = interface(IUnknown)
    ['{D1DB483D-6796-4B8B-80FC-13712BB716F4}']
    /// The request object for the web resource, as committed. This includes
    /// headers added by the network stack that were not be included during the
    /// associated WebResourceRequested event, such as Authentication headers.
    /// Modifications to this object have no effect on how the request is
    /// processed as it has already been sent.
    function get_request(out request:ICoreWebView2WebResourceRequest):HRESULT;stdcall;
    function get_response(out response:ICoreWebView2WebResourceRequest):HRESULT;stdcall;
  end;

  /// Receives `WebResourceResponseReceived` events.
  ICoreWebView2WebResourceResponseReceivedEventHandler = interface(IUnknown)
    ['{7DE9898A-24F5-40C3-A2DE-D4F458E69828}']
    /// Provides the event args for the corresponding event.
    function invoke(const sender: ICoreWebView2;const args:ICoreWebView2WebResourceResponseReceivedEventArgs):HRESULT;stdcall;
  end;

  ICoreWebView2Cookie = interface(IUnknown)
    ['{AD26D6BE-1486-43E6-BF87-A2034006CA21}']
    /// Cookie name.
    function get_name(out name:PWideChar):HRESULT;stdcall;
    /// Cookie value.
    function get_value(out value:PWideChar):HRESULT;stdcall;
    /// Set the cookie value property.
    function put_value(value:PWideChar):HRESULT;stdcall;
    /// The domain for which the cookie is valid.
    /// The default is the host that this cookie has been received from.
    /// Note that, for instance, ".bing.com", "bing.com", and "www.bing.com" are
    /// considered different domains.
    function get_domain(out domain:PWideChar):HRESULT;stdcall;
    /// The path for which the cookie is valid. The default is "/", which means
    /// this cookie will be sent to all pages on the Domain.
    function get_path(out path:PWideChar):HRESULT;stdcall;
     /// The expiration date and time for the cookie as the number of seconds since the UNIX epoch.
    /// The default is -1.0, which means cookies are session cookies by default.
    function get_expires(out expires:Double):HRESULT;stdcall;
    /// Set the Expires property. Cookies are session cookies and will not be
    /// persistent if Expires is set to -1.0. NaN, infinity, and any negative
    /// value set other than -1.0 is disallowed.
    function put_expires(expires:Double):HRESULT;stdcall;
    /// SameSite status of the cookie which represents the enforcement mode of the cookie.
    /// The default is COREWEBVIEW2_COOKIE_SAME_SITE_KIND_LAX.
    function get_same_site(out same_site:TCookieSameSiteKind):HRESULT;stdcall;
    /// Set the SameSite property.
    function put_same_site(same_site:TCookieSameSiteKind):HRESULT;stdcall;
    /// The security level of this cookie. True if the client is only to return
    /// the cookie in subsequent requests if those requests use HTTPS.
    /// The default is false.
    /// Note that cookie that requests COREWEBVIEW2_COOKIE_SAME_SITE_KIND_NONE but
    /// is not marked Secure will be rejected.
    function get_is_secure(out is_secure:Integer):HRESULT;stdcall;
    /// Set the IsSecure property.
    function put_is_secure(is_secure:Integer):HRESULT;stdcall;
    /// Whether this is a session cookie. The default is false.
    function get_is_session(out is_session:Integer):HRESULT;stdcall;
  end;
  /// A list of cookie objects. See `ICoreWebView2Cookie`.
  /// \snippet ScenarioCookieManagement.cpp GetCookies
  ICoreWebView2CookieList = interface(IUnknown)
    ['{F7F6F714-5D2A-43C6-9503-346ECE02D186}']
    /// The number of cookies contained in the ICoreWebView2CookieList.
    function get_count(count:SYSUINT):HRESULT;stdcall;
    /// Gets the cookie object at the given index.
    function get_value_at_index(index:SYSUINT;out cookie:ICoreWebView2Cookie):HRESULT;stdcall;
  end;


  /// Receives the result of the `GetCookies` method.  The result is written to
  /// the cookie list provided in the `GetCookies` method call.
  ICoreWebView2GetCookiesCompletedHandler = interface(IUnknown)
    ['{5A4F5069-5C15-47C3-8646-F4DE1C116670}']
    /// Provides the completion status of the corresponding asynchronous method
    /// call.
    function invoke(errorCode: HRESULT;cookie_list:ICoreWebView2CookieList):HRESULT;stdcall;
  end;

  /// Creates, adds or updates, gets, or or view the cookies. The changes would
  /// apply to the context of the user profile. That is, other WebViews under the
  /// same user profile could be affected.
  ICoreWebView2CookieManager = interface(IUnknown)
    ['{177CD9E7-B6F5-451A-94A0-5D7A3A4C4141}']
    /// Create a cookie object with a specified name, value, domain, and path.
    /// One can set other optional properties after cookie creation.
    /// This only creates a cookie object and it is not added to the cookie
    /// manager until you call AddOrUpdateCookie.
    /// Leading or trailing whitespace(s), empty string, and special characters
    /// are not allowed for name.
    /// See ICoreWebView2Cookie for more details.
    function create_cookie(name,value,domain,path:PWideChar;out cookie:ICoreWebView2Cookie):HRESULT;stdcall;
    /// Creates a cookie whose params matches those of the specified cookie.
    function copy_cookie(cookie_param:ICoreWebView2Cookie;out cookie:ICoreWebView2Cookie):HRESULT;stdcall;
    /// Gets a list of cookies matching the specific URI.
    /// If uri is empty string or null, all cookies under the same profile are
    /// returned.
    /// You can modify the cookie objects by calling
    /// ICoreWebView2CookieManager::AddOrUpdateCookie, and the changes
    /// will be applied to the webview.
    /// \snippet ScenarioCookieManagement.cpp GetCookies
    function get_cookies(uri:PWideChar;const handler:ICoreWebView2GetCookiesCompletedHandler):HRESULT;stdcall;
    /// Adds or updates a cookie with the given cookie data; may overwrite
    /// cookies with matching name, domain, and path if they exist.
    /// This method will fail if the domain of the given cookie is not specified.
    /// \snippet ScenarioCookieManagement.cpp AddOrUpdateCookie
    function add_or_update_cookie(const cookie:ICoreWebView2Cookie):HRESULT;stdcall;
    /// Deletes a cookie whose name and domain/path pair
    /// match those of the specified cookie.
    function delete_cookie(const cookie:ICoreWebView2Cookie):HRESULT;stdcall;
    /// Deletes cookies with matching name and uri.
    /// Cookie name is required.
    /// All cookies with the given name where domain
    /// and path match provided URI are deleted.
    function delete_cookies(name,uri:PWideChar):HRESULT;stdcall;
    /// Deletes all cookies under the same profile.
    /// This could affect other WebViews under the same user profile.
    function delete_all_cookies:HRESULT;stdcall;
  end;

  /// A continuation of the ICoreWebView2 interface.
  ICoreWebView2_2 = interface(ICoreWebView2)
    ['{9E8F0CF8-E670-4B5E-B2BC-73E061E3184C}']
    /// Add an event handler for the DOMContentLoaded event.
    /// DOMContentLoaded is raised when the initial html document has been parsed.
    /// This aligns with the the document's DOMContentLoaded event in html.
    ///
    /// \snippet ScenarioDOMContentLoaded.cpp DOMContentLoaded
    function add_DOMContentLoaded(const event_handler:ICoreWebView2DOMContentLoadedEventHandler;out token:EventRegistrationToken):HRESULT;stdcall;
    /// Remove an event handler previously added with add_DOMContentLoaded.
    function remove_DOMContentLoaded(token: EventRegistrationToken):HRESULT;stdcall;
    /// Add an event handler for the WebResourceResponseReceived event.
    /// WebResourceResponseReceived is raised when the WebView receives the
    /// response for a request for a web resource (any URI resolution performed by
    /// the WebView; such as HTTP/HTTPS, file and data requests from redirects,
    /// navigations, declarations in HTML, implicit favicon lookups, and fetch API
    /// usage in the document). The host app can use this event to view the actual
    /// request and response for a web resource. There is no guarantee about the
    /// order in which the WebView processes the response and the host app's
    /// handler runs. The app's handler will not block the WebView from processing
    /// the response.
    /// \snippet ScenarioAuthentication.cpp WebResourceResponseReceived
    function add_WebResourceResponseReceived(const event_handler:ICoreWebView2WebResourceResponseReceivedEventHandler;out token:EventRegistrationToken):HRESULT;stdcall;
    /// Remove an event handler previously added with
    /// add_WebResourceResponseReceived.
    function remove_WebResourceResponseReceived(token:EventRegistrationToken):HRESULT;stdcall;
    /// Gets the cookie manager object associated with this ICoreWebView2.
    /// See ICoreWebView2CookieManager.
    ///
    /// \snippet ScenarioCookieManagement.cpp CookieManager
    function get_CookieManager(out cookie_manager:ICoreWebView2CookieManager):HRESULT;stdcall;
    /// Exposes the CoreWebView2Environment used to create this CoreWebView2.
    function get_Environment(out environment:ICoreWebView2Environment):HRESULT;stdcall;
    /// Navigates using a constructed WebResourceRequest object. This lets you
    /// provide post data or additional request headers during navigation.
    /// The headers in the WebResourceRequest override headers
    /// added by WebView2 runtime except for Cookie headers.
    /// Method can only be either "GET" or "POST". Provided post data will only
    /// be sent only if the method is "POST" and the uri scheme is HTTP(S).
    /// \snippet ScenarioNavigateWithWebResourceRequest.cpp NavigateWithWebResourceRequest
    function NavigateWithWebResourceRequest(const request:ICoreWebView2WebResourceRequest):HRESULT;stdcall;
  end;

  ICoreWebView2TrySuspendCompletedHandler = interface(IUnknown)
    ['{00F206A7-9D17-4605-91F6-4E8E4DE192E3}']
    /// Provides the result of the TrySuspend operation.
    /// See [Sleeping Tabs FAQ](https://techcommunity.microsoft.com/t5/articles/sleeping-tabs-faq/m-p/1705434)
    /// for conditions that might prevent WebView from being suspended. In those situations,
    /// isSuccessful will be false and errorCode is S_OK.
    function invoke(errorCode: HRESULT;is_successful:integer):HRESULT;stdcall;
  end;

  /// A continuation of the ICoreWebView2_2 interface.
  ICoreWebView2_3 = interface(ICoreWebView2_2)
    ['{A0D6DF20-3B92-416D-AA0C-437A9C727857}']
   /// An app may call the `TrySuspend` API to have the WebView2 consume less memory.
    /// This is useful when a Win32 app becomes invisible, or when a Universal Windows
    /// Platform app is being suspended, during the suspended event handler before completing
    /// the suspended event.
    /// The CoreWebView2Controller's IsVisible property must be false when the API is called.
    /// Otherwise, the API fails with `HRESULT_FROM_WIN32(ERROR_INVALID_STATE)`.
    /// Suspending is similar to putting a tab to sleep in the Edge browser. Suspending pauses
    /// WebView script timers and animations, minimizes CPU usage for the associated
    /// browser renderer process and allows the operating system to reuse the memory that was
    /// used by the renderer process for other processes.
    /// Note that Suspend is best effort and considered completed successfully once the request
    /// is sent to browser renderer process. If there is a running script, the script will continue
    /// to run and the renderer process will be suspended after that script is done.
    /// See [Sleeping Tabs FAQ](https://techcommunity.microsoft.com/t5/articles/sleeping-tabs-faq/m-p/1705434)
    /// for conditions that might prevent WebView from being suspended. In those situations,
    /// the completed handler will be invoked with isSuccessful as false and errorCode as S_OK.
    /// The WebView will be automatically resumed when it becomes visible. Therefore, the
    /// app normally does not have to call `Resume` explicitly.
    /// The app can call `Resume` and then `TrySuspend` periodically for an invisible WebView so that
    /// the invisible WebView can sync up with latest data and the page ready to show fresh content
    /// when it becomes visible.
    /// All WebView APIs can still be accessed when a WebView is suspended. Some APIs like Navigate
    /// will auto resume the WebView. To avoid unexpected auto resume, check `IsSuspended` property
    /// before calling APIs that might change WebView state.
    ///
    /// \snippet ViewComponent.cpp ToggleIsVisibleOnMinimize
    ///
    /// \snippet ViewComponent.cpp Suspend
    ///
    function try_suspend(const handler: ICoreWebView2TrySuspendCompletedHandler):HRESULT;stdcall;
    /// Resumes the WebView so that it resumes activities on the web page.
    /// This API can be called while the WebView2 controller is invisible.
    /// The app can interact with the WebView immediately after `Resume`.
    /// WebView will be automatically resumed when it becomes visible.
    ///
    /// \snippet ViewComponent.cpp ToggleIsVisibleOnMinimize
    ///
    /// \snippet ViewComponent.cpp Resume
    ///
    function resume :HRESULT;stdcall;
    /// Whether WebView is suspended.
    /// `TRUE` when WebView is suspended, from the time when TrySuspend has completed
    ///  successfully until WebView is resumed.
    function get_is_suspended(out is_suspended:integer):HRESULT;stdcall;
   /// Sets a mapping between a virtual host name and a folder path to make available to web sites
    /// via that host name.
    ///
    /// After setting the mapping, documents loaded in the WebView can use HTTP or HTTPS URLs at
    /// the specified host name specified by hostName to access files in the local folder specified
    /// by folderPath.
    ///
    /// This mapping applies to both top-level document and iframe navigations as well as subresource
    /// references from a document. This also applies to web workers including dedicated/shared worker
    /// and service worker, for loading either worker scripts or subresources
    /// (importScripts(), fetch(), XHR, etc.) issued from within a worker.
    /// For virtual host mapping to work with service worker, please keep the virtual host name
    /// mappings consistent among all WebViews sharing the same browser instance. As service worker
    /// works independently of WebViews, we merge mappings from all WebViews when resolving virutal
    /// host name, inconsistent mappings between WebViews would lead unexpected bevavior.
    ///
    /// Due to a current implementation limitation, media files accessed using virtual host name can be
    /// very slow to load.
    /// As the resource loaders for the current page might have already been created and running,
    /// changes to the mapping might not be applied to the current page and a reload of the page is
    /// needed to apply the new mapping.
    ///
    /// Both absolute and relative paths are supported for folderPath. Relative paths are interpreted
    /// as relative to the folder where the exe of the app is in.
    ///
    /// accessKind specifies the level of access to resources under the virtual host from other sites.
    ///
    /// For example, after calling
    /// ```cpp
    ///    SetVirtualHostNameToFolderMapping(
    ///        L"appassets.example", L"assets",
    ///        COREWEBVIEW2_HOST_RESOURCE_ACCESS_KIND_DENY);
    /// ```
    /// navigating to `https://appassets.example/my-local-file.html` will
    /// show content from my-local-file.html in the assets subfolder located on disk under the same
    /// path as the app's executable file.
    ///
    /// You should typically choose virtual host names that are never used by real sites.
    /// If you own a domain such as example.com, another option is to use a subdomain reserved for
    /// the app (like my-app.example.com).
    ///
    /// [RFC 6761](https://tools.ietf.org/html/rfc6761) has reserved several special-use domain
    /// names that are guaranteed to not be used by real sites (for example, .example, .test, and
    /// .invalid.)
    ///
    /// Apps should use distinct domain names when mapping folder from different sources that
    /// should be isolated from each other. For instance, the app might use app-file.example for
    /// files that ship as part of the app, and book1.example might be used for files containing
    /// books from a less trusted source that were previously downloaded and saved to the disk by
    /// the app.
    ///
    /// The host name used in the APIs is canonicalized using Chromium's host name parsing logic
    /// before being used internally.
    ///
    /// All host names that are canonicalized to the same string are considered identical.
    /// For example, `EXAMPLE.COM` and `example.com` are treated as the same host name.
    /// An international host name and its Punycode-encoded host name are considered the same host
    /// name. There is no DNS resolution for host name and the trailing '.' is not normalized as
    /// part of canonicalization.
    ///
    /// Therefore `example.com` and `example.com.` are treated as different host names. Similarly,
    /// `virtual-host-name` and `virtual-host-name.example.com` are treated as different host names
    /// even if the machine has a DNS suffix of `example.com`.
    ///
    /// Specify the minimal cross-origin access necessary to run the app. If there is not a need to
    /// access local resources from other origins, use COREWEBVIEW2_HOST_RESOURCE_ACCESS_KIND_DENY.
    ///
    /// \snippet AppWindow.cpp AddVirtualHostNameToFolderMapping
    ///
    /// \snippet AppWindow.cpp LocalUrlUsage
    function set_virtual_host_name_to_folder_mapping(host_name,folder_path:PWideChar;access_kind:THostResourceAccessKind):HRESULT;stdcall;
    /// Clears a host name mapping for local folder that was added by `SetVirtualHostNameToFolderMapping`.
    function clear_virtual_host_name_to_folder_mapping(host_name:PWideChar):HRESULT;stdcall;
  end;

  /// Receives `FrameNameChanged` event.
  ICoreWebView2FrameNameChangedEventHandler = interface(IUnknown)
    ['{435c7dc8-9baa-11eb-a8b3-0242ac130003}']
    /// Provides the result for the iframe name changed event.
    /// No event args exist and the `args` parameter is set to `null`.
    function invoke(const sender: ICoreWebView2Frame;const args:IUnknown):HRESULT;stdcall;
  end;
  /// Receives `FrameDestroyed` event.
  ICoreWebView2FrameDestroyedEventHandler = interface(IUnknown)
    ['{59dd7b4c-9baa-11eb-a8b3-0242ac130003}']
    /// Provides the result for the iframe destroyed event.
    /// No event args exist and the `args` parameter is set to `null`.
    function invoke(const sender: ICoreWebView2Frame;const args:IUnknown):HRESULT;stdcall;
  end;

  /// WebView2Frame provides direct access to the iframes information.
  ICoreWebView2Frame = interface(IUnknown)
    ['{f1131a5e-9ba9-11eb-a8b3-0242ac130003}']
    /// The name of the iframe from the iframe html tag declaring it.
    /// Calling this method fails if it is called after the iframe is destroyed.
    function get_name(out name :PWideChar):HRESULT;stdcall;
    /// Raised when the iframe changes its window.name property.
    function add_name_changed(const event_handler:ICoreWebView2FrameNameChangedEventHandler;out token:EventRegistrationToken):HRESULT;stdcall;
    /// Remove an event handler previously added with add_NameChanged.
    function remove_name_changed(token:EventRegistrationToken):HRESULT;stdcall;
   /// Add the provided host object to script running in the iframe with the
    /// specified name for the list of the specified origins. The host object
    /// will be accessible for this iframe only if the iframe's origin during
    /// access matches one of the origins which are passed. The provided origins
    /// will be normalized before comparing to the origin of the document.
    /// So the scheme name is made lower case, the host will be punycode decoded
    /// as appropriate, default port values will be removed, and so on.
    /// This means the origin's host may be punycode encoded or not and will match
    /// regardless. If list contains malformed origin the call will fail.
    /// The method can be called multiple times in a row without calling
    /// RemoveHostObjectFromScript for the same object name. It will replace
    /// the previous object with the new object and new list of origins.
    /// List of origins will be treated as following:
    /// 1. empty list - call will succeed and object will be added for the iframe
    /// but it will not be exposed to any origin;
    /// 2. list with origins - during access to host object from iframe the
    /// origin will be checked that it belongs to this list;
    /// 3. list with "*" element - host object will be available for iframe for
    /// all origins. We suggest not to use this feature without understanding
    /// security implications of giving access to host object from from iframes
    /// with unknown origins.
    /// Calling this method fails if it is called after the iframe is destroyed.
    /// \snippet ScenarioAddHostObject.cpp AddHostObjectToScriptWithOrigins
    /// For more information about host objects navigate to
    /// ICoreWebView2::AddHostObjectToScript.
    function add_host_object_to_script_with_origins(name:PWideChar;out Object_:OleVariant;origins_count:SYSINT;origins:PWideChar):HRESULT;stdcall;
   /// Remove the host object specified by the name so that it is no longer
    /// accessible from JavaScript code in the iframe. While new access
    /// attempts are denied, if the object is already obtained by JavaScript code
    /// in the iframe, the JavaScript code continues to have access to that
    /// object. Calling this method for a name that is already removed or was
    /// never added fails. If the iframe is destroyed this method will return fail
    /// also.
    function remove_host_object_from_script(name:PWideChar):HRESULT;stdcall;
    /// The Destroyed event is raised when the iframe corresponding
    /// to this CoreWebView2Frame object is removed or the document
    /// containing that iframe is destroyed
    function add_destroyed(const event_handler:ICoreWebView2FrameDestroyedEventHandler;out token: EventRegistrationToken):HRESULT;stdcall;
    /// Remove an event handler previously added with add_Destroyed.
    function remove_destroyed(token: EventRegistrationToken):HRESULT;stdcall;
    /// Check whether a frame is destroyed. Returns true during
    /// the Destroyed event.
    function is_destroyed(out destroyed:integer):HRESULT;stdcall;
  end;

  /// Event args for the `FrameCreated` events.
  ICoreWebView2FrameCreatedEventArgs = interface(IUnknown)
    ['{4d6e7b5e-9baa-11eb-a8b3-0242ac130003}']
    /// The frame which was created.
    function get_frame(out frame:ICoreWebView2Frame):HRESULT;stdcall;
  end;

  /// Receives `FrameCreated` event.
  ICoreWebView2FrameCreatedEventHandler = interface(IUnknown)
    ['{38059770-9baa-11eb-a8b3-0242ac130003}']
    /// Provides the result for the iframe created event.
    function invoke(const sender: ICoreWebView2;const args:ICoreWebView2FrameCreatedEventArgs):HRESULT;stdcall;
  end;

  /// Implements the interface to receive `BytesReceivedChanged` event.  Use the
  /// `ICoreWebView2DownloadOperation.BytesReceived` property to get the received
  /// bytes count.
  ICoreWebView2BytesReceivedChangedEventHandler = interface(IUnknown)
    ['{828e8ab6-d94c-4264-9cef-5217170d6251}']
     /// Provides the event args for the corresponding event. No event args exist
    /// and the `args` parameter is set to `null`.
    function invoke(const sender: ICoreWebView2DownloadOperation;const args:IUnknown):HRESULT;stdcall;
  end;

  /// Implements the interface to receive `EstimatedEndTimeChanged` event. Use the
  /// `ICoreWebView2DownloadOperation.EstimatedEndTime` property to get the new
  /// estimated end time.
  ICoreWebView2EstimatedEndTimeChangedEventHandler = interface(IUnknown)
    ['{28f0d425-93fe-4e63-9f8d-2aeec6d3ba1e}']
    /// Provides the event args for the corresponding event. No event args exist
    /// and the `args` parameter is set to `null`.
    function invoke(const sender: ICoreWebView2DownloadOperation;const args:IUnknown):HRESULT;stdcall;
  end;

  /// Implements the interface to receive `StateChanged` event. Use the
  /// `ICoreWebView2DownloadOperation.State` property to get the current state,
  /// which can be in progress, interrupted, or completed. Use the
  /// `ICoreWebView2DownloadOperation.InterruptReason` property to get the
  /// interrupt reason if the download is interrupted.
  ICoreWebView2StateChangedEventHandler = interface(IUnknown)
    ['{81336594-7ede-4ba9-bf71-acf0a95b58dd}']
    /// Provides the event args for the corresponding event. No event args exist
    /// and the `args` parameter is set to `null`.
    function invoke(const sender: ICoreWebView2DownloadOperation;const args:IUnknown):HRESULT;stdcall;
  end;

  /// Represents a download operation. Gives access to the download's metadata
  /// and supports a user canceling, pausing, or resuming the download.
  ICoreWebView2DownloadOperation = interface(IUnknown)
    ['{3d6b6cf2-afe1-44c7-a995-c65117714336}']
    /// Add an event handler for the `BytesReceivedChanged` event.
    ///
    /// \snippet ScenarioCustomDownloadExperience.cpp BytesReceivedChanged
    function add_bytes_received_changed(const event_handler:ICoreWebView2BytesReceivedChangedEventHandler;out token:EventRegistrationToken):HRESULT;stdcall;
    /// Remove an event handler previously added with `add_BytesReceivedChanged`.
    function remove_bytes_received_changed(token:EventRegistrationToken):HRESULT;stdcall;
    /// Add an event handler for the `EstimatedEndTimeChanged` event.
    function add_estimated_end_time_changed(const event_handler:ICoreWebView2EstimatedEndTimeChangedEventHandler;out token:EventRegistrationToken):HRESULT;stdcall;
    /// Remove an event handler previously added with `add_EstimatedEndTimeChanged`.
    function remove_estimated_end_time_changed(token:EventRegistrationToken):HRESULT;stdcall;
    /// Add an event handler for the `StateChanged` event.
    ///
    /// \snippet ScenarioCustomDownloadExperience.cpp StateChanged
    function add_state_changed(const event_handler:ICoreWebView2StateChangedEventHandler;out token:EventRegistrationToken):HRESULT;stdcall;
    /// Remove an event handler previously added with `add_StateChanged`.
    function remove_state_changed(token:EventRegistrationToken):HRESULT;stdcall;
    /// The URI of the download.
    function get_uri(out uri:PWideChar):HRESULT;stdcall;
    /// The Content-Disposition header value from the download's HTTP response.
    function get_content_disposition(out content_disposition:PWideChar):HRESULT;stdcall;
    /// MIME type of the downloaded content.
    function get_mime_type(out mime_type:PWideChar):HRESULT;stdcall;
    /// The expected size of the download in total number of bytes based on the
    /// HTTP Content-Length header. Returns -1 if the size is unknown.
    function get_total_bytes_to_receive(out total_bytes_to_receive:Int64):HRESULT;stdcall;
    /// The number of bytes that have been written to the download file.
    function get_bytes_received(out bytes_received:Int64):HRESULT;stdcall;
    /// The estimated end time in [ISO 8601 Date and Time Format](https://www.iso.org/iso-8601-date-and-time-format.html).
    function get_estimated_end_time(out mime_type:PWideChar):HRESULT;stdcall;    ///
    /// The absolute path to the download file, including file name. Host can change
    /// this from `ICoreWebView2DownloadStartingEventArgs`.
    function get_result_file_path(out result_file_path:PWideChar):HRESULT;stdcall;
    /// The state of the download. A download can be in progress, interrupted, or
    /// completed. See `COREWEBVIEW2_DOWNLOAD_STATE` for descriptions of states.
    function get_state(out download_state: TEdgeDownloadState ):HRESULT;stdcall;
    /// The reason why connection with file host was broken.
    function get_interrupt_reason(out interrupt_reason: TEdgeDownloadInterruptReason ):HRESULT;stdcall;
    /// Cancels the download. If canceled, the default download dialog shows
    /// that the download was canceled. Host should set the `Cancel` property from
    /// `ICoreWebView2SDownloadStartingEventArgs` if the download should be
    /// canceled without displaying the default download dialog.
    function Cancel :HRESULT;stdcall;
    /// Pauses the download. If paused, the default download dialog shows that the
    /// download is paused. No effect if download is already paused. Pausing a
    /// download changes the state to `COREWEBVIEW2_DOWNLOAD_STATE_INTERRUPTED`
    /// with `InterruptReason` set to `COREWEBVIEW2_DOWNLOAD_INTERRUPT_REASON_USER_PAUSED`.
    function Pause :HRESULT;stdcall;
    /// Resumes a paused download. May also resume a download that was interrupted
    /// for another reason, if `CanResume` returns true. Resuming a download changes
    /// the state from `COREWEBVIEW2_DOWNLOAD_STATE_INTERRUPTED` to
    /// `COREWEBVIEW2_DOWNLOAD_STATE_IN_PROGRESS`.
    function Resume :HRESULT;stdcall;
   /// Returns true if an interrupted download can be resumed. Downloads with
    /// the following interrupt reasons may automatically resume without you
    /// calling any methods:
    /// `COREWEBVIEW2_DOWNLOAD_INTERRUPT_REASON_SERVER_NO_RANGE`,
    /// `COREWEBVIEW2_DOWNLOAD_INTERRUPT_REASON_FILE_HASH_MISMATCH`,
    /// `COREWEBVIEW2_DOWNLOAD_INTERRUPT_REASON_FILE_TOO_SHORT`.
    /// In these cases download progress may be restarted with `BytesReceived`
    /// reset to 0.
    function get_can_resume(out can_resume:integer) :HRESULT;stdcall;
  end;

  /// Event args for the `DownloadStarting` event.
  ICoreWebView2DownloadStartingEventArgs = interface(IUnknown)
    ['{e99bbe21-43e9-4544-a732-282764eafa60}']
    /// Returns the `ICoreWebView2DownloadOperation` for the download that
    /// has started.
    function get_download_operation(out download_operation:ICoreWebView2DownloadOperation):HRESULT;stdcall;
    /// The host may set this flag to cancel the download. If canceled, the
    /// download save dialog is not displayed regardless of the
    /// `Handled` property.
    function get_cancel(out cancel:integer):HRESULT;stdcall;
    /// Sets the `Cancel` property.
    function put_cancel(cancel:integer):HRESULT;stdcall;
    /// The path to the file. If setting the path, the host should ensure that it
    /// is an absolute path, including the file name, and that the path does not
    /// point to an existing file. If the path points to an existing file, the
    /// file will be overwritten. If the directory does not exist, it is created.
    function get_result_file_path(out result_file_path:PWideChar):HRESULT;stdcall;
    /// Sets the `ResultFilePath` property.
    function put_result_file_path(result_file_path:PWideChar):HRESULT;stdcall;
    /// The host may set this flag to `TRUE` to hide the default download dialog
    /// for this download. The download will progress as normal if it is not
    /// canceled, there will just be no default UI shown. By default the value is
    /// `FALSE` and the default download dialog is shown.
    function get_handled(out handled:integer):HRESULT;stdcall;
    /// Sets the `Handled` property.
    function put_handled(handled:integer):HRESULT;stdcall;
    /// Returns an `ICoreWebView2Deferral` object.  Use this operation to
    /// complete the event at a later time.
    function get_deferral(out deferral :ICoreWebView2Deferral):HRESULT;stdcall;
  end;

  /// Add an event handler for the `DownloadStarting` event.
  ICoreWebView2DownloadStartingEventHandler = interface(IUnknown)
    ['{efedc989-c396-41ca-83f7-07f845a55724}']
    /// Provides the event args for the corresponding event.
    function invoke(const sender: ICoreWebView2;const args:ICoreWebView2DownloadStartingEventArgs):HRESULT;stdcall;
  end;

  /// A continuation of the ICoreWebView2_3 interface to support FrameCreated and
  /// DownloadStarting events.
  ICoreWebView2_4 = interface(ICoreWebView2_3)
   ['{20d02d59-6df2-42dc-bd06-f98a694b1302}']
    /// Raised when a new iframe is created. Use the
    /// CoreWebView2Frame.add_Destroyed to listen for when this iframe goes
    /// away.
    function add_frame_created(const event_handler:ICoreWebView2FrameCreatedEventHandler;out token:EventRegistrationToken):HRESULT;stdcall;
    /// Remove an event handler previously added with add_FrameCreated.
    function remove_frame_created(token:EventRegistrationToken):HRESULT;stdcall;
    /// Add an event handler for the `DownloadStarting` event. This event is
    /// raised when a download has begun, blocking the default download dialog,
    /// but not blocking the progress of the download.
    ///
    /// The host can choose to cancel a download, change the result file path,
    /// and hide the default download dialog.
    /// If the host chooses to cancel the download, the download is not saved, no
    /// dialog is shown, and the state is changed to
    /// COREWEBVIEW2_DOWNLOAD_STATE_INTERRUPTED with interrupt reason
    /// COREWEBVIEW2_DOWNLOAD_INTERRUPT_REASON_USER_CANCELED. Otherwise, the
    /// download is saved to the default path after the event completes,
    /// and default download dialog is shown if the host did not choose to hide it.
    /// The host can change the visibility of the download dialog using the
    /// `Handled` property. If the event is not handled, downloads complete
    /// normally with the default dialog shown.
    ///
    /// \snippet ScenarioCustomDownloadExperience.cpp DownloadStarting
    function add_download_starting(const event_handler:ICoreWebView2DownloadStartingEventHandler;out token:EventRegistrationToken):HRESULT;stdcall;
    // Remove an event handler previously added with `add_DownloadStarting`.
    function remove_download_starting(token:EventRegistrationToken):HRESULT;stdcall;
  end;

implementation

end.
