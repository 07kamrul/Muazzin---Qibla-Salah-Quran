import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/hadith_model.dart';
import '../../models/mosque_model.dart';
import '../../models/prayer_times_model.dart';

/// SQLite database helper — singleton.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  static const _dbName    = 'muazzin.db';
  static const _dbVersion = 1;

  // ── Table names ───────────────────────────────────────────────────────────
  static const _tPrayerCache = 'prayer_times_cache';
  static const _tMosques     = 'mosques';
  static const _tHadiths     = 'hadiths';
  static const _tBookmarks   = 'bookmarks';
  static const _tRamadan     = 'ramadan_calendar';

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path   = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tPrayerCache (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        location_key TEXT NOT NULL,
        date         TEXT NOT NULL,
        fajr         TEXT NOT NULL,
        shuruq       TEXT NOT NULL,
        dhuhr        TEXT NOT NULL,
        asr          TEXT NOT NULL,
        maghrib      TEXT NOT NULL,
        isha         TEXT NOT NULL,
        tahajjud     TEXT NOT NULL,
        ishraq       TEXT NOT NULL,
        duha         TEXT NOT NULL,
        created_at   TEXT NOT NULL,
        UNIQUE(location_key, date)
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tMosques (
        id                  TEXT PRIMARY KEY,
        name_bn             TEXT NOT NULL,
        name_en             TEXT,
        latitude            REAL NOT NULL,
        longitude           REAL NOT NULL,
        district            TEXT,
        upazila             TEXT,
        division            TEXT,
        address_bn          TEXT,
        address_en          TEXT,
        jamat_times         TEXT,
        facilities          TEXT,
        verification_status TEXT,
        distance_km         REAL,
        updated_at          TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tHadiths (
        id                  INTEGER PRIMARY KEY,
        arabic_text         TEXT,
        bangla_translation  TEXT NOT NULL,
        english_translation TEXT NOT NULL,
        source              TEXT NOT NULL,
        book_name           TEXT NOT NULL,
        hadith_number       TEXT NOT NULL,
        narrator            TEXT,
        day_of_year         INTEGER UNIQUE NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tBookmarks (
        type       TEXT NOT NULL,
        item_id    TEXT NOT NULL,
        created_at TEXT NOT NULL,
        PRIMARY KEY (type, item_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tRamadan (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        year          INTEGER NOT NULL,
        day           INTEGER NOT NULL,
        hijri_date    TEXT NOT NULL,
        sehri_end     TEXT NOT NULL,
        iftar_time    TEXT NOT NULL,
        is_last_ten   INTEGER NOT NULL DEFAULT 0,
        UNIQUE(year, day)
      )
    ''');
  }

  // ── Prayer Times ──────────────────────────────────────────────────────────

  Future<void> cachePrayerTimes(
    String locationKey,
    List<PrayerTimesModel> times,
  ) async {
    final db    = await database;
    final now   = DateTime.now().toIso8601String();
    final batch = db.batch();

    for (final t in times) {
      batch.insert(
        _tPrayerCache,
        {
          'location_key': locationKey,
          'date':         t.date.toIso8601String(),
          'fajr':         t.fajr.toIso8601String(),
          'shuruq':       t.shuruq.toIso8601String(),
          'dhuhr':        t.dhuhr.toIso8601String(),
          'asr':          t.asr.toIso8601String(),
          'maghrib':      t.maghrib.toIso8601String(),
          'isha':         t.isha.toIso8601String(),
          'tahajjud':     t.tahajjud.toIso8601String(),
          'ishraq':       t.ishraq.toIso8601String(),
          'duha':         t.duha.toIso8601String(),
          'created_at':   now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<PrayerTimesModel?> getCachedPrayerTimes(
    String locationKey,
    DateTime date,
  ) async {
    final db   = await database;
    final dateStr = DateTime(date.year, date.month, date.day).toIso8601String();

    final rows = await db.query(
      _tPrayerCache,
      where: 'location_key = ? AND date LIKE ?',
      whereArgs: [locationKey, '${dateStr.substring(0, 10)}%'],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    final row = rows.first;

    return PrayerTimesModel(
      date:        DateTime.parse(row['date'] as String),
      locationKey: row['location_key'] as String,
      fajr:        DateTime.parse(row['fajr']    as String),
      shuruq:      DateTime.parse(row['shuruq']  as String),
      dhuhr:       DateTime.parse(row['dhuhr']   as String),
      asr:         DateTime.parse(row['asr']     as String),
      maghrib:     DateTime.parse(row['maghrib'] as String),
      isha:        DateTime.parse(row['isha']    as String),
      tahajjud:    DateTime.parse(row['tahajjud'] as String),
      ishraq:      DateTime.parse(row['ishraq']  as String),
      duha:        DateTime.parse(row['duha']    as String),
    );
  }

  // ── Mosques ───────────────────────────────────────────────────────────────

  Future<void> saveMosques(List<MosqueModel> mosques) async {
    final db    = await database;
    final now   = DateTime.now().toIso8601String();
    final batch = db.batch();

    for (final m in mosques) {
      batch.insert(
        _tMosques,
        {
          'id':                  m.id,
          'name_bn':             m.nameBn,
          'name_en':             m.nameEn,
          'latitude':            m.latitude,
          'longitude':           m.longitude,
          'district':            m.district,
          'upazila':             m.upazila,
          'division':            m.division,
          'address_bn':          m.addressBn,
          'address_en':          m.addressEn,
          'jamat_times':         jsonEncode(m.jamatTimes.toJson()),
          'facilities':          jsonEncode(m.facilities.toJson()),
          'verification_status': m.verificationStatus.name,
          'updated_at':          now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<MosqueModel>> getMosquesNearby(
    double lat,
    double lng,
    double radiusKm,
  ) async {
    final db  = await database;
    final deg = radiusKm / 111.0;

    final rows = await db.query(
      _tMosques,
      where: 'latitude BETWEEN ? AND ? AND longitude BETWEEN ? AND ?',
      whereArgs: [lat - deg, lat + deg, lng - deg * 1.5, lng + deg * 1.5],
    );

    return rows.map((row) {
      final jamatJson = jsonDecode(row['jamat_times'] as String? ?? '{}') as Map<String, dynamic>;
      final facJson   = jsonDecode(row['facilities']  as String? ?? '{}') as Map<String, dynamic>;
      final mosque    = MosqueModel(
        id:                  row['id']      as String,
        nameBn:              row['name_bn'] as String,
        nameEn:              row['name_en'] as String? ?? '',
        latitude:            (row['latitude']  as num).toDouble(),
        longitude:           (row['longitude'] as num).toDouble(),
        district:            row['district']   as String? ?? '',
        upazila:             row['upazila']    as String? ?? '',
        division:            row['division']   as String?,
        addressBn:           row['address_bn'] as String?,
        addressEn:           row['address_en'] as String?,
        jamatTimes:          JamatTimesModel.fromJson(jamatJson),
        facilities:          FacilitiesModel.fromJson(facJson),
        verificationStatus:  VerificationStatus.values.firstWhere(
          (s) => s.name == row['verification_status'],
          orElse: () => VerificationStatus.unverified,
        ),
      );
      return mosque.withDistance(lat, lng);
    }).where((m) => (m.distanceKm ?? double.infinity) <= radiusKm).toList()
      ..sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));
  }

  // ── Hadiths ───────────────────────────────────────────────────────────────

  Future<void> saveHadiths(List<HadithModel> hadiths) async {
    final db    = await database;
    final batch = db.batch();
    for (final h in hadiths) {
      batch.insert(_tHadiths, h.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<HadithModel?> getDailyHadith(DateTime date) async {
    final db    = await database;
    final start = DateTime(date.year);
    final doy   = date.difference(start).inDays + 1;

    var rows = await db.query(_tHadiths, where: 'day_of_year = ?', whereArgs: [doy], limit: 1);
    if (rows.isEmpty) {
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $_tHadiths')) ?? 0;
      if (count == 0) return null;
      final wrapped = (doy % count) + 1;
      rows = await db.query(_tHadiths, where: 'day_of_year = ?', whereArgs: [wrapped], limit: 1);
    }
    if (rows.isEmpty) return null;
    return HadithModel.fromJson(Map<String, dynamic>.from(rows.first));
  }

  Future<HadithModel?> getHadithById(int id) async {
    final db   = await database;
    final rows = await db.query(_tHadiths, where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return HadithModel.fromJson(Map<String, dynamic>.from(rows.first));
  }

  // ── Bookmarks ─────────────────────────────────────────────────────────────

  Future<void> addBookmark(String type, String itemId) async {
    final db = await database;
    await db.insert(
      _tBookmarks,
      {'type': type, 'item_id': itemId, 'created_at': DateTime.now().toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeBookmark(String type, String itemId) async {
    final db = await database;
    await db.delete(_tBookmarks, where: 'type = ? AND item_id = ?', whereArgs: [type, itemId]);
  }

  Future<List<String>> getBookmarks(String type) async {
    final db   = await database;
    final rows = await db.query(_tBookmarks, columns: ['item_id'], where: 'type = ?', whereArgs: [type], orderBy: 'created_at DESC');
    return rows.map((r) => r['item_id'] as String).toList();
  }

  Future<bool> isBookmarked(String type, String itemId) async {
    final db   = await database;
    final rows = await db.query(_tBookmarks, where: 'type = ? AND item_id = ?', whereArgs: [type, itemId], limit: 1);
    return rows.isNotEmpty;
  }
}
