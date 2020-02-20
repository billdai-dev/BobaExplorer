class RemoteConfigAppVersionInfo {
  String _minVersion;
  String _latestVersion;

  RemoteConfigAppVersionInfo(this._minVersion, this._latestVersion);

  String get minVersion => _minVersion;

  String get latestVersion => _latestVersion;
}

class RemoteConfigShop {
  String name;
  _ShopColor color;

  RemoteConfigShop.fromJsonMap(Map<String, dynamic> map)
      : name = map["name"],
        color = _ShopColor.fromJsonMap(map["color"]);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = name;
    data['color'] = color == null ? null : color.toJson();
    return data;
  }
}

class _ShopColor {
  int a;
  int r;
  int g;
  int b;

  _ShopColor.fromJsonMap(Map<String, dynamic> map)
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
