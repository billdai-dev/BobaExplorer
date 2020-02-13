class DomainException implements Exception {
  final String _errMsg;

  DomainException([this._errMsg]);

  String get errMsg => _errMsg;

  factory DomainException.resourceNotAvailable([String _errMsg]) =>
      ResourceNotAvailableException(_errMsg);

  factory DomainException.unknownException([String _errMsg]) =>
      UnknownException(_errMsg);
}

class ResourceNotAvailableException extends DomainException {
  ResourceNotAvailableException([String errMsg]) : super(errMsg);
}

class UnknownException extends DomainException {
  UnknownException([String errMsg]) : super(errMsg);
}
