unit AMEdgeStructure;

interface


type

  {BackGround color WebView}
  COREWEBVIEW2_COLOR = packed record
    A : BYTE;
    R : BYTE;
    G : BYTE;
    B : BYTE;
  end;
  TCOREWEBVIEW2_COLOR = COREWEBVIEW2_COLOR;

  // Kind of cookie SameSite status used in the ICoreWebView2Cookie interface.
  /// These fields match those as specified in https://developer.mozilla.org/docs/Web/HTTP/Cookies#.
  /// Learn more about SameSite cookies here: https://tools.ietf.org/html/draft-west-first-party-cookies-07
  TCookieSameSiteKind          = (
    /// None SameSite type. No restrictions on cross-site requests.
    cskNone,
    /// Lax SameSite type. The cookie will be sent with "same-site" requests, and with "cross-site" top level navigation.
    cskLax,
    /// Strict SameSite type. The cookie will only be sent along with "same-site" requests.
    cskStrict);

  /// Kind of cross origin resource access allowed for host resources during download.
  /// Note that other normal access checks like same origin DOM access check and [Content
  /// Security Policy](https://developer.mozilla.org/docs/Web/HTTP/CSP) still apply.
  /// The following table illustrates the host resource cross origin access according to
  /// access context and `COREWEBVIEW2_HOST_RESOURCE_ACCESS_KIND`.
  ///
  /// Cross Origin Access Context | DENY | ALLOW | DENY_CORS
  /// --- | --- | --- | ---
  /// From DOM like src of img, script or iframe element| Deny | Allow | Allow
  /// From Script like Fetch or XMLHttpRequest| Deny | Allow | Deny

  THostResourceAccessKind      = (
    /// All cross origin resource access is denied, including normal sub resource access
    /// as src of a script or image element.
    hrakDeny,
    /// All cross origin resource access is allowed, including accesses that are
    /// subject to Cross-Origin Resource Sharing(CORS) check. The behavior is similar to
    /// a web site sends back http header Access-Control-Allow-Origin: *.
    hrakAllow,
    /// Cross origin resource access is allowed for normal sub resource access like
    /// as src of a script or image element, while any access that subjects to CORS check
    /// will be denied.
    /// See [Cross-Origin Resource Sharing](https://developer.mozilla.org/docs/Web/HTTP/CORS)
    /// for more information.
    hrakDenyCors);

  // State of the download operation.
  TEdgeDownloadState           = (
    /// The download is in progress.
    edsInProgress,
    /// The connection with the file host was broken. The `InterruptReason` property
    /// can be accessed from `ICoreWebView2DownloadOperation`. See
    /// `COREWEBVIEW2_DOWNLOAD_INTERRUPT_REASON` for descriptions of kinds of
    /// interrupt reasons. Host can check whether an interrupted download can be
    /// resumed with the `CanResume` property on the `ICoreWebView2DownloadOperation`.
    /// Once resumed, a download is in the `COREWEBVIEW2_DOWNLOAD_STATE_IN_PROGRESS` state.
    edsInterrupted,
    /// The download completed successfully.
    edsCompleted);

  /// Reason why a download was interrupted.
  TEdgeDownloadInterruptReason = (
    edirNone,
    /// Generic file error.
    edirFileFailed,
    /// Access denied due to security restrictions.
    edirFileAccessDenied,
    /// Disk full. User should free some space or choose a different location to
    /// store the file.
    edirFileNoSpace,
    /// Result file path with file name is too long.
    edirFileNameTooLong,
    /// File is too large for file system.
    edirFileTooLarge,
    /// Microsoft Defender Smartscreen detected a virus in the file.
    edirFileMalicious,
    /// File was in use, too many files opened, or out of memory.
    edirFileTransientError,
    /// File blocked by local policy.
    edirFileBlockedByPolicy,
    /// Security check failed unexpectedly. Microsoft Defender SmartScreen could
    /// not scan this file.
    edirFileSecurityCheckFailed,
    /// Seeking past the end of a file in opening a file, as part of resuming an
    /// interrupted download. The file did not exist or was not as large as
    /// expected. Partially downloaded file was truncated or deleted, and download
    /// will be restarted automatically.
    edirFileTooShort,
    /// Partial file did not match the expected hash and was deleted. Download
    /// will be restarted automatically.
    edirFileHashMismatch,
    /// Generic network error. User can retry the download manually.
    edirNetworkFailed,
    /// Network operation timed out.
    edirNetworkTimeout,
    /// Network connection lost. User can retry the download manually.
    edirNetworkDisconnected,
    /// Server has gone down. User can retry the download manually.
    edirNetworkServerDown,
    /// Network request invalid because original or redirected URI is invalid, has
    /// an unsupported scheme, or is disallowed by network policy.
    edirNetworkInvalidRequest,
    /// Generic server error. User can retry the download manually.
    edirServerFailed,
    /// Server does not support range requests.
    edirServerNoRange,
    /// Server does not have the requested data.
    edirServerBadContent,
    /// Server did not authorize access to resource.
    edirServerUnauthorized,
    /// Server certificate problem.
    edirServerCertificateProblem,
    /// Server access forbidden.
    edirServerForbidden,
    /// Unexpected server response. Responding server may not be intended server.
    /// User can retry the download manually.
    edirServerUnexpectedResponse,
    /// Server sent fewer bytes than the Content-Length header. Content-length
    /// header may be invalid or connection may have closed. Download is treated
    /// as complete unless there are
    /// [strong validators](https://tools.ietf.org/html/rfc7232#section-2) present
    /// to interrupt the download.
    edirServerContentLengthMismatch,
    /// Unexpected cross-origin redirect.
    edirServerCrossOriginRedirect,
    /// User canceled the download.
    edirUserCanceled,
    /// User shut down the WebView. Resuming downloads that were interrupted
    /// during shutdown is not yet supported.
    edirUserShutdown,
    /// User paused the download.
    edirUserPaused,
    /// WebView crashed.
    edirDownloadProcessCrashed);

implementation

end.
