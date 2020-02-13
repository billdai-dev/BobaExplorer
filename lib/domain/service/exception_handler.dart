import 'package:boba_explorer/domain/use_case/domain_exception.dart';

abstract class IExceptionHandler {
  DomainException parse(Exception e);
}
