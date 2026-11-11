sealed class ApiException implements Exception {
  const ApiException();
}

// no response at all: SocketException or a timeout
class NoConnectionException extends ApiException {
  const NoConnectionException();
}

// their server: 5xx
class ServerException extends ApiException {
  const ServerException(this.status);
  final int status;
}

// my request: 4xx
class NotFoundException extends ApiException {
  const NotFoundException();
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException();
}

// JSON we could not read: a bug report, not a Retry
class BadResponseException extends ApiException {
  const BadResponseException([this.detail]);
  final String? detail;

  @override
  String toString() => 'BadResponseException($detail)';
}
