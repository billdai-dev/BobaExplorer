import 'package:boba_explorer/data/local_storage.dart';
import 'package:boba_explorer/data/network.dart';
import 'package:meta/meta.dart';

class BaseRepo {
  Network _network;

  @protected
  Network get network => _network;

  LocalStorage _localStorage;

  @protected
  LocalStorage get localStorage => _localStorage;

  BaseRepo({Network network, LocalStorage localStorage}) {
    _network = network ?? Network.getInstance();
    _localStorage = localStorage ?? LocalStorage.getInstance();
  }
}
