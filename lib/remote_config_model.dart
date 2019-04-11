class RemoteConfigModel {
  List<Shop> shops;

  RemoteConfigModel.fromJsonMap(Map<String, dynamic> map)
      : shops = List<Shop>.from(map["shops"].map((it) => Shop.fromJsonMap(it)));

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['shops'] =
        shops != null ? this.shops.map((v) => v.toJson()).toList() : null;
    return data;
  }
}

class Shop {
  String name;
  ShopColor color;

  Shop.fromJsonMap(Map<String, dynamic> map)
      : name = map["name"],
        color = ShopColor.fromJsonMap(map["color"]);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = name;
    data['color'] = color == null ? null : color.toJson();
    return data;
  }
}

class ShopColor {
  int a;
  int r;
  int g;
  int b;

  ShopColor.fromJsonMap(Map<String, dynamic> map)
      : a = map["a"],
        r = map["r"],
        g = map["g"],
        b = map["b"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['a'] = a;
    data['r'] = r;
    data['g'] = g;
    data['b'] = b;
    return data;
  }
}
