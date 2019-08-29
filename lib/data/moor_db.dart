import 'package:moor_flutter/moor_flutter.dart';

part 'moor_db.g.dart';

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
class BobaDatabase extends _$BobaDatabase {
  BobaDatabase()
      : super(FlutterQueryExecutor.inDatabaseFolder(path: 'db.sqlite'));

  @override
  int get schemaVersion => 1;

  Stream<List<FavoriteShop>> watchFavoriteShops() {
    return (select(favoriteShops)
          ..orderBy([
            (shop) => OrderingTerm(
                expression: shop.updatedTs, mode: OrderingMode.desc)
          ]))
        .watch();
  }

  Future<void> addFavoriteShop(FavoriteShop shop) async {
    shop = shop.copyWith(createdTs: DateTime.now(), updatedTs: DateTime.now());
    String docId = shop.docId;
    final shops = await (select(favoriteShops)
          ..where((shop) => shop.docId.equals(docId)))
        .get();
    if (shops == null || shops.isEmpty) {
      return into(favoriteShops).insert(shop);
    }
    return (update(favoriteShops)..where((shop) => shop.docId.equals(docId)))
        .write(shop);
  }

  Future<void> deleteFavoriteShop(String docId) {
    return (delete(favoriteShops)..where((shop) => shop.docId.equals(docId)))
        .go();
  }
}
