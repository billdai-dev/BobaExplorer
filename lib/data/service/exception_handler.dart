import 'package:boba_explorer/domain/service/exception_handler.dart';
import 'package:boba_explorer/domain/use_case/domain_exception.dart';

class ExceptionHandler implements IExceptionHandler {
  @override
  DomainException parse(Exception e) {
    assert(() {
      print("Error occurred:$e");
      return true;
    }());
    switch (e.runtimeType) {
      case DomainException:
        return e;
      /*case :
        return DomainException.fbUserNotAvailable();
        break;*/
      default:
        return DomainException.unknownException();
    }
  }
}
