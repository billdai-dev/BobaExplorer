import 'dart:async';

import 'package:boba_explorer/domain/entity/tea_shop.dart';
import 'package:boba_explorer/domain/repository/tea_shop/tea_shop_repository.dart';
import 'package:boba_explorer/domain/service/exception_handler.dart';
import 'package:boba_explorer/domain/use_case/use_case.dart';

class FindTeaShopUseCase extends ParamUseCase<FindTeaShopParam, List<TeaShop>> {
  final ITeaShopRepository _teaShopRepository;

  FindTeaShopUseCase(
      this._teaShopRepository, IExceptionHandler exceptionHandler)
      : super(exceptionHandler);

  @override
  Future buildUseCaseFuture(FindTeaShopParam param) async {
    return _teaShopRepository
        .getTeaShops(
            lat: param.lat,
            lng: param.lng,
            radius: param.radius,
            shopNames: param.shopNames)
        .first;
  }
}

class FindTeaShopParam {
  double lat;
  double lng;
  double radius;
  Set<String> shopNames;

  FindTeaShopParam(this.lat, this.lng, {this.radius = 0.5, this.shopNames});
}
