import 'package:boba_explorer/data/repository/mapper.dart';
import 'package:boba_explorer/domain/entity/tea_shop.dart';
import 'package:moor_flutter/moor_flutter.dart';

part 'moor_db.g.dart';

abstract class IDatabase {
  Stream<List<TeaShop>> watchFavoriteShops();

  Future<void> addFavoriteShop(TeaShop shop);

  Future<void> addFavoriteShops(List<TeaShop> shops);

  Future<void> deleteFavoriteShop(String docId);

  Future<void> deleteAllFavoriteShops();
}

class FavoriteShops extends Table {
  TextColumn get docId => text()();

  TextColumn get shopName => text()();

  TextColumn get branchName => text()();

  TextColumn get phone => text().nullable()();

  TextColumn get city => text()();

  TextColumn get district => text()();

  TextColumn get address => text()();

  TextColumn get geoHash => text()();

  RealColumn get lat => real()();

  RealColumn get lng => real()();

  DateTimeColumn get createdTs => dateTime().nullable()();

  DateTimeColumn get updatedTs => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {docId};
}

// This will make moor generate a class called "Category" to represent a row in this table.
// By default, "Categorie" would have been used because it only strips away the trailing "s"
// in the table name.
/*@DataClassName("Category")
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text()();
}*/

// this annotation tells moor to prepare a database class that uses both of the
// tables we just defined. We'll see how to use that database class in a moment.
@UseMoor(tables: [FavoriteShops])
class BobaDatabase extends _$BobaDatabase implements IDatabase {
  BobaDatabase()
      : super(FlutterQueryExecutor.inDatabaseFolder(path: 'db.sqlite'));

  @override
  int get schemaVersion => 1;

  @override
  Stream<List<TeaShop>> watchFavoriteShops() {
    return (select(favoriteShops)
          ..orderBy([
            (shop) => OrderingTerm(
                expression: shop.updatedTs, mode: OrderingMode.desc)
          ]))
        .watch()
        .map((favoriteShops) => favoriteShops
            .map((favoriteShop) => Mapper.favoriteShopToTeaShop(favoriteShop))
            .toList());
  }

  @override
  Future<void> addFavoriteShop(TeaShop shop) async {
    FavoriteShop favoriteShop = Mapper.teaShopToFavoriteShop(shop)
        .copyWith(createdTs: DateTime.now(), updatedTs: DateTime.now());
    String docId = favoriteShop.docId;
    final shops = await (select(favoriteShops)
          ..where((shop) => shop.docId.equals(docId)))
        .get();
    if (shops == null || shops.isEmpty) {
      return into(favoriteShops).insert(favoriteShop);
    }
    return (update(favoriteShops)..where((shop) => shop.docId.equals(docId)))
        .write(favoriteShop);
  }

  @override
  Future<void> addFavoriteShops(List<TeaShop> shops) async {
    List<FavoriteShop> favoriteShops = shops.map((teaShop) =>
        Mapper.teaShopToFavoriteShop(teaShop)
            .copyWith(createdTs: DateTime.now(), updatedTs: DateTime.now()));
    /*shops.map((shop) {
      return shop.copyWith(
          createdTs: DateTime.now(), updatedTs: DateTime.now());
    }).toList();*/
    await into(this.favoriteShops).insertAll(favoriteShops, orReplace: true);

    (delete(this.favoriteShops).go()).then((_) =>
        into(this.favoriteShops).insertAll(favoriteShops, orReplace: true));
    //String docId = shop.docId;
    /*final shops = await (select(favoriteShops)
      ..where((shop) => shop.docId.equals(docId)))
        .get();
    if (shops == null || shops.isEmpty) {
      return into(favoriteShops).insert(shop);
    }
    return (update(favoriteShops)..where((shop) => shop.docId.equals(docId)))
        .write(shop);*/
  }

  @override
  Future<void> deleteFavoriteShop(String docId) {
    return (delete(favoriteShops)..where((shop) => shop.docId.equals(docId)))
        .go();
  }

  @override
  Future<void> deleteAllFavoriteShops() {
    return delete(favoriteShops).go();
  }
}
