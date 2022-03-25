import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

String contactTable = 'contactTable';
String idColumn = 'idColumn';
String nomeColumn = 'nameColumn';
String emailColumn = 'emailColumn';
String foneColumn = 'foneColumn';
String imgColumn = 'imgColumn';

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  static Database? _database;

  Future<Database> get db async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await initiDb();
      return _database!;
    }
  }

  Future<Database> initiDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'contact.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int newerVersion) async {
        await db.execute('''
        CREATE TABLE $contactTable(
          $idColumn INTEGER PRIMARY KEY,
          $nomeColumn TEXT,
          $emailColumn TEXT,
          $foneColumn TEXT,
          $imgColumn TEXT
          )''');
      },
    );
  }

  Future<int> saveContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.insert(contactTable, contact.toMap());
    // return contact;
  }

  Future<Contact?> getContact(int id) async {
    Database dbContact = await db;
    List<Map<String, dynamic>> maps = await dbContact.query(
      contactTable,
      columns: [
        idColumn,
        nomeColumn,
        emailColumn,
        foneColumn,
        imgColumn,
      ],
      where: '$idColumn = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteContact(int id) async {
    Database dbContact = await db;
    return await dbContact.delete(
      contactTable,
      where: '$idColumn = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(
      contactTable,
      contact.toMap(),
      where: '$idColumn = ?',
      whereArgs: [contact.id],
    );
  }

  Future<List> getAllContact() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery(
      '''SELECT * FROM $contactTable ''',
    );
    List<Contact>? listContact = [];

    for (Map<String, dynamic> m in listMap) {
      listContact.add(
        Contact.fromMap(m),
      );
    }
    return listContact;
  }

  Future<List> deleteAllContact() async {
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery(
      '''SELECT * FROM $contactTable ''',
    );
    List<Contact>? listContact = [];

    for (Map<String, dynamic> m in listMap) {
      listContact.remove(
        Contact.fromMap(m),
      );
    }
    return listContact;
  }

  Future<int?> getNumber() async {
    Database dbContact = await db;
    return Sqflite.firstIntValue(
      await dbContact.rawQuery(
        '''SELECT COUNT(*) FROM $contactTable ''',
      ),
    );
  }

  Future close() async {
    Database dbContact = await db;
    dbContact.close();
  }
}

class Contact {
  int? id;
  String? nome;
  String? email;
  String? telefone;
  String? img;

  Contact();

  Contact.fromMap(Map<String, dynamic> map) {
    id = map[idColumn];
    nome = map[nomeColumn];
    email = map[emailColumn];
    telefone = map[foneColumn];
    img = map[imgColumn];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      nomeColumn: nome,
      emailColumn: email,
      foneColumn: telefone,
      imgColumn: img
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return 'Contact(id: $id, nome: $nome, email: $email, fone: $telefone, img: $img)';
  }
}
