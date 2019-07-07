class InternalRequest {
  final Uri _url;
  final int version;
  final String endpoint;
  final RequestMethod method;

  InternalRequest(Uri url, String method)
      : _url = url,
        version = _extractVersion(url),
        endpoint = _extractEndpoint(url),
        method = _extractMethod(method);

  static int _extractVersion(Uri url) {
    var version = url.pathSegments[0];

    if (version.startsWith(RegExp('v[0-9]*'))) {
      return int.tryParse(version.substring(1));
    } else {
      return 1;
    }
  }

  static String _extractEndpoint(Uri url) {
    var version = url.pathSegments[0];

    if (version.startsWith(RegExp('v[0-9]*'))) {
      return url.pathSegments[1];
    } else {
      return url.pathSegments[0];
    }
  }

  static RequestMethod _extractMethod(String method) {
    if (method == 'GET') {
      return RequestMethod.GET;
    } else if (method == 'PUT') {
      return RequestMethod.PUT;
    } else if (method == 'DELETE') {
      return RequestMethod.DELETE;
    } else if (method == 'POST') {
      return RequestMethod.POST;
    } else if (method == 'UPDATE') {
      return RequestMethod.UPDATE;
    }

    return null;
  }

  String queryParameters(String paramName) => _url.queryParameters[paramName];
}

enum RequestMethod { GET, PUT, DELETE, POST, UPDATE }
