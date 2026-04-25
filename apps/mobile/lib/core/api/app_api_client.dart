import 'dart:convert';
import 'dart:io';

import 'package:mobile/core/auth/app_session_store.dart';
import 'package:mobile/core/api/app_api_entry_mode.dart';

enum AppApiMethod { get, post, put, delete }

class AppApiConfig {
  static String get cloudRuntimeBaseUrl => AppApiEntryTarget.cloudBaseUrl;
  static String get tunnelBaseUrl => AppApiEntryTarget.sshTunnelBaseUrl;
  static String get defaultBaseUrl => AppApiEntryTarget.defaultBaseUrl;
  static String? _runtimeBaseUrlOverride;

  AppApiConfig({
    required String baseUrl,
    this.entryMode,
    this.defaultHeaders = const <String, String>{},
    this.requestTimeout = const Duration(seconds: 5),
  }) : baseUrl = AppApiEntryTarget.requireApprovedBaseUrl(
         baseUrl,
         entryMode: entryMode,
       );

  factory AppApiConfig.fromEnvironment() {
    final runtimeBaseUrl = Platform.environment['APP_BFF_BASE_URL']?.trim();
    final runtimeActorId = Platform.environment['APP_BFF_ACTOR_ID']?.trim();
    final runtimeUserId = Platform.environment['APP_BFF_USER_ID']?.trim();
    final runtimeEntryMode = Platform.environment['APP_RUNTIME_ENTRY_MODE'];
    const compileTimeBaseUrl = String.fromEnvironment('APP_BFF_BASE_URL');
    const compileTimeActorId = String.fromEnvironment('APP_BFF_ACTOR_ID');
    const compileTimeUserId = String.fromEnvironment('APP_BFF_USER_ID');
    const compileTimeEntryMode = String.fromEnvironment(
      'APP_RUNTIME_ENTRY_MODE',
    );
    final defaultHeaders = <String, String>{};
    final actorId = compileTimeActorId.isNotEmpty
        ? compileTimeActorId
        : runtimeActorId != null && runtimeActorId.isNotEmpty
        ? runtimeActorId
        : '';
    final userId = compileTimeUserId.isNotEmpty
        ? compileTimeUserId
        : runtimeUserId != null && runtimeUserId.isNotEmpty
        ? runtimeUserId
        : '';
    if (actorId.isNotEmpty) {
      defaultHeaders['x-actor-id'] = actorId;
    }
    if (userId.isNotEmpty) {
      defaultHeaders['x-user-id'] = userId;
    }

    final requestedEntryMode =
        AppApiEntryTarget.parse(compileTimeEntryMode) ??
        AppApiEntryTarget.parse(runtimeEntryMode);
    final resolvedEntryMode =
        requestedEntryMode ?? AppApiEntryTarget.defaultEntryMode();
    final resolvedBaseUrl = compileTimeBaseUrl.isNotEmpty
        ? compileTimeBaseUrl
        : runtimeBaseUrl != null && runtimeBaseUrl.isNotEmpty
        ? runtimeBaseUrl
        : AppApiEntryTarget.defaultBaseUrlForMode(resolvedEntryMode);

    return AppApiConfig(
      baseUrl: resolvedBaseUrl,
      entryMode:
          requestedEntryMode ??
          AppApiEntryTarget.inferFromBaseUrl(resolvedBaseUrl),
      defaultHeaders: defaultHeaders,
      requestTimeout: const Duration(seconds: 5),
    );
  }

  final String baseUrl;
  final AppApiEntryMode? entryMode;
  final Map<String, String> defaultHeaders;
  final Duration requestTimeout;

  static void installRuntimeBaseUrlOverride(String? baseUrl) {
    final value = baseUrl?.trim();
    _runtimeBaseUrlOverride = value == null || value.isEmpty
        ? null
        : AppApiEntryTarget.requireApprovedBaseUrl(value);
  }

  static void resetRuntimeBaseUrlOverride() {
    _runtimeBaseUrlOverride = null;
  }

  String get effectiveBaseUrl {
    final override = _runtimeBaseUrlOverride?.trim();
    if (override != null && override.isNotEmpty) {
      return override;
    }
    return baseUrl;
  }

  AppApiEntryMode get effectiveEntryMode =>
      entryMode ?? AppApiEntryTarget.inferFromBaseUrl(effectiveBaseUrl);

  bool get isStagingLikeEnvironment =>
      AppApiEntryTarget.isStagingLikeEnvironment(
        effectiveBaseUrl,
        entryMode: effectiveEntryMode,
      );

  String get userFacingEnvironmentLabel => AppApiEntryTarget.userFacingLabel(
    effectiveBaseUrl,
    entryMode: effectiveEntryMode,
  );

  Uri resolveCanonicalPath(
    String canonicalPath, {
    Map<String, String>? queryParameters,
  }) {
    final baseUri = Uri.parse(effectiveBaseUrl);
    final basePath = _normalizeBasePath(baseUri.path);
    final canonicalSuffix = canonicalPath.startsWith('/api/app')
        ? canonicalPath.substring('/api/app'.length)
        : canonicalPath;
    final path = basePath.endsWith('/api/app')
        ? _joinPath(basePath, canonicalSuffix)
        : _joinPath(basePath, canonicalPath);

    return baseUri.replace(
      path: path,
      queryParameters: queryParameters == null || queryParameters.isEmpty
          ? null
          : queryParameters,
    );
  }

  Uri resolveEndpoint(String endpoint) {
    final parsed = Uri.tryParse(endpoint);
    if (parsed != null && parsed.hasScheme) {
      return parsed;
    }

    if (endpoint.startsWith('/api/app')) {
      return resolveCanonicalPath(endpoint);
    }

    final baseUri = Uri.parse(effectiveBaseUrl);
    final path = _joinPath(_normalizeBasePath(baseUri.path), endpoint);
    return baseUri.replace(path: path);
  }

  String _normalizeBasePath(String path) {
    if (path.isEmpty) {
      return '';
    }

    return path.endsWith('/') ? path.substring(0, path.length - 1) : path;
  }

  String _joinPath(String left, String right) {
    final normalizedLeft = left.endsWith('/')
        ? left.substring(0, left.length - 1)
        : left;
    final normalizedRight = right.startsWith('/') ? right.substring(1) : right;

    if (normalizedLeft.isEmpty) {
      return '/$normalizedRight';
    }

    return '$normalizedLeft/$normalizedRight';
  }
}

class AppApiRequest {
  const AppApiRequest({
    required this.method,
    required this.canonicalPath,
    required this.uri,
    this.body,
    this.headers = const <String, String>{},
  });

  final AppApiMethod method;
  final String canonicalPath;
  final Uri uri;
  final Object? body;
  final Map<String, String> headers;
}

class AppApiUploadRequest {
  const AppApiUploadRequest({
    required this.method,
    required this.url,
    required this.headers,
    required this.bodyBytes,
  });

  final String method;
  final String url;
  final Map<String, String> headers;
  final List<int> bodyBytes;
}

class AppApiResponse {
  const AppApiResponse({
    required this.statusCode,
    required this.uri,
    this.body,
    this.headers = const <String, String>{},
  });

  final int statusCode;
  final Uri uri;
  final Object? body;
  final Map<String, String> headers;
}

abstract class AppApiTransport {
  Future<AppApiResponse> send(AppApiRequest request);

  Future<AppApiResponse> upload(AppApiUploadRequest request);
}

class HttpAppApiTransport implements AppApiTransport {
  HttpAppApiTransport({HttpClient? httpClient})
    : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

  @override
  Future<AppApiResponse> send(AppApiRequest request) async {
    final httpRequest = await _httpClient.openUrl(
      request.method.name.toUpperCase(),
      request.uri,
    );

    request.headers.forEach(httpRequest.headers.set);

    if (request.body != null) {
      httpRequest.headers.set(
        HttpHeaders.contentTypeHeader,
        'application/json; charset=utf-8',
      );
      httpRequest.add(utf8.encode(jsonEncode(request.body)));
    }

    final response = await httpRequest.close();
    return _toResponse(response, request.uri);
  }

  @override
  Future<AppApiResponse> upload(AppApiUploadRequest request) async {
    final uri = Uri.parse(request.url);
    final httpRequest = await _httpClient.openUrl(request.method, uri);
    request.headers.forEach(httpRequest.headers.set);
    httpRequest.contentLength = request.bodyBytes.length;
    httpRequest.add(request.bodyBytes);
    final response = await httpRequest.close();
    return _toResponse(response, uri);
  }

  Future<AppApiResponse> _toResponse(
    HttpClientResponse response,
    Uri fallbackUri,
  ) async {
    final responseBody = await utf8.decoder.bind(response).join();
    Object? decodedBody;

    if (responseBody.isNotEmpty) {
      try {
        decodedBody = jsonDecode(responseBody);
      } on FormatException {
        decodedBody = responseBody;
      }
    }

    final headers = <String, String>{};
    response.headers.forEach((String name, List<String> values) {
      headers[name] = values.join(',');
    });

    return AppApiResponse(
      statusCode: response.statusCode,
      uri: fallbackUri,
      body: decodedBody,
      headers: headers,
    );
  }
}

class FakeAppApiTransport implements AppApiTransport {
  FakeAppApiTransport({
    Map<String, Future<AppApiResponse> Function(AppApiRequest request)>?
    handlers,
    Future<AppApiResponse> Function(AppApiUploadRequest request)? uploadHandler,
  }) : _handlers =
           handlers ??
           <String, Future<AppApiResponse> Function(AppApiRequest request)>{},
       _uploadHandler = uploadHandler;

  final Map<String, Future<AppApiResponse> Function(AppApiRequest request)>
  _handlers;
  final Future<AppApiResponse> Function(AppApiUploadRequest request)?
  _uploadHandler;
  final List<AppApiRequest> requests = <AppApiRequest>[];
  final List<AppApiUploadRequest> uploads = <AppApiUploadRequest>[];

  @override
  Future<AppApiResponse> send(AppApiRequest request) async {
    requests.add(request);
    final key = '${request.method.name.toUpperCase()} ${request.canonicalPath}';
    final handler = _handlers[key];
    if (handler == null) {
      throw StateError('Missing fake handler for $key');
    }

    return handler(request);
  }

  @override
  Future<AppApiResponse> upload(AppApiUploadRequest request) async {
    uploads.add(request);
    final handler = _uploadHandler;
    if (handler == null) {
      return AppApiResponse(statusCode: 200, uri: Uri.parse(request.url));
    }

    return handler(request);
  }
}

class AppApiClient {
  AppApiClient({AppApiConfig? config, AppApiTransport? transport})
    : config = config ?? AppApiConfig.fromEnvironment(),
      transport = transport ?? HttpAppApiTransport();

  final AppApiConfig config;
  final AppApiTransport transport;

  Future<AppApiResponse> _sendWithTimeout(AppApiRequest request) {
    return transport
        .send(request)
        .timeout(
          config.requestTimeout,
          onTimeout: () => throw SocketException(
            'request timed out: ${request.method.name.toUpperCase()} ${request.canonicalPath}',
          ),
        );
  }

  Future<AppApiResponse> _uploadWithTimeout(AppApiUploadRequest request) {
    return transport
        .upload(request)
        .timeout(
          config.requestTimeout,
          onTimeout: () => throw SocketException(
            'request timed out: ${request.method} ${request.url}',
          ),
        );
  }

  Future<AppApiResponse> get(
    String canonicalPath, {
    Map<String, String>? queryParameters,
  }) {
    return _sendWithTimeout(
      AppApiRequest(
        method: AppApiMethod.get,
        canonicalPath: canonicalPath,
        uri: config.resolveCanonicalPath(
          canonicalPath,
          queryParameters: queryParameters,
        ),
        headers: _resolvedHeaders(),
      ),
    );
  }

  Future<AppApiResponse> getEndpoint(String endpoint) {
    return _sendWithTimeout(
      AppApiRequest(
        method: AppApiMethod.get,
        canonicalPath: endpoint,
        uri: config.resolveEndpoint(endpoint),
        headers: _resolvedHeaders(),
      ),
    );
  }

  Future<AppApiResponse> post(String canonicalPath, {Object? body}) {
    return _sendWithTimeout(
      AppApiRequest(
        method: AppApiMethod.post,
        canonicalPath: canonicalPath,
        uri: config.resolveCanonicalPath(canonicalPath),
        body: body,
        headers: _resolvedHeaders(),
      ),
    );
  }

  Future<AppApiResponse> put(String canonicalPath, {Object? body}) {
    return _sendWithTimeout(
      AppApiRequest(
        method: AppApiMethod.put,
        canonicalPath: canonicalPath,
        uri: config.resolveCanonicalPath(canonicalPath),
        body: body,
        headers: _resolvedHeaders(),
      ),
    );
  }

  Future<AppApiResponse> delete(String canonicalPath) {
    return _sendWithTimeout(
      AppApiRequest(
        method: AppApiMethod.delete,
        canonicalPath: canonicalPath,
        uri: config.resolveCanonicalPath(canonicalPath),
        headers: _resolvedHeaders(),
      ),
    );
  }

  Future<AppApiResponse> postEndpoint(String endpoint, {Object? body}) {
    return _sendWithTimeout(
      AppApiRequest(
        method: AppApiMethod.post,
        canonicalPath: endpoint,
        uri: config.resolveEndpoint(endpoint),
        body: body,
        headers: _resolvedHeaders(),
      ),
    );
  }

  Map<String, String> _resolvedHeaders() {
    return <String, String>{
      ...config.defaultHeaders,
      ...AppSessionStore.instance.authorizationHeaders,
    };
  }

  Future<AppApiResponse> upload({
    required String method,
    required String url,
    required Map<String, String> headers,
    required List<int> bodyBytes,
  }) {
    return _uploadWithTimeout(
      AppApiUploadRequest(
        method: method,
        url: url,
        headers: headers,
        bodyBytes: bodyBytes,
      ),
    );
  }
}
