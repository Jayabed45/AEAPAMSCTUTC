import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ReportsDb {
  ReportsDb._();
  static final ReportsDb instance = ReportsDb._();

  Database? _db;

  Future<void> init() async {
    if (_db != null) return;
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    String dbPath;
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      final dir = await getApplicationDocumentsDirectory();
      dbPath = p.join(dir.path, 'reports.db');
    } else {
      final base = await getDatabasesPath();
      dbPath = p.join(base, 'reports.db');
    }
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS reports(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fileName TEXT NOT NULL,
            localPath TEXT NOT NULL,
            createdAt INTEGER NOT NULL,
            type TEXT NOT NULL,
            vAvg REAL,
            vMax REAL,
            tAvg REAL,
            tMin REAL,
            tMax REAL,
            liters REAL,
            energy REAL
          )
        ''');
      },
    );
  }

  Future<int> insertReport({
    required String fileName,
    required String localPath,
    required DateTime createdAt,
    required String type,
    required Map<String, double> summary,
  }) async {
    final db = _db;
    if (db == null) throw Exception('ReportsDb not initialized');
    return db.insert('reports', {
      'fileName': fileName,
      'localPath': localPath,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'type': type,
      'vAvg': summary['vAvg'],
      'vMax': summary['vMax'],
      'tAvg': summary['tAvg'],
      'tMin': summary['tMin'],
      'tMax': summary['tMax'],
      'liters': summary['liters'],
      'energy': summary['energy'],
    });
  }

  Future<List<Map<String, dynamic>>> listReports({int? limit}) async {
    final db = _db;
    if (db == null) throw Exception('ReportsDb not initialized');
    return db.query('reports', orderBy: 'createdAt DESC', limit: limit);
  }

  Future<int> deleteReport(int id) async {
    final db = _db;
    if (db == null) throw Exception('ReportsDb not initialized');
    return db.delete('reports', where: 'id = ?', whereArgs: [id]);
  }
}
