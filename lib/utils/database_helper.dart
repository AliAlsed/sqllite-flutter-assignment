import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:notekeeper/models/note.dart';

class DatabaseHelper{
  static DatabaseHelper _databasehelper; //Singleton DatabaseHelper
  static Database _database; // Singleton Database
  String noteTable="note_table";
  String colId="id";
  String colTitle="title";
  String colDescription="description";
  String colPriorty ="priority";
  String colDate ="date";
  // *****************
  DatabaseHelper._createInstance();
  factory DatabaseHelper(){
    if(_databasehelper ==null){
      _databasehelper =DatabaseHelper._createInstance();
    }
    return _databasehelper;
  }
  Future<Database> get database async{
		if (_database == null) {
			_database = await initializeDatabase();
		}
		return _database;
  }
  Future<Database> initializeDatabase() async{
		// Get the directory path for both Android and iOS to store database.
		Directory directory = await getApplicationDocumentsDirectory();
		String path = directory.path + 'notes.db';

		// Open/create the database at a given path
		var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb );
		return notesDatabase;
  }
  	void _createDb(Database db, int newVersion) async {

		await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
				'$colDescription TEXT, $colPriorty INTEGER, $colDate TEXT)');
	}

  Future<List<Map<String,dynamic>>> getNotesMapList() async{
		Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
		var result = await db.query(noteTable, orderBy: '$colPriorty ASC');
		return result;
  }
  Future<int> insertNote(Note note) async{
    Database db=await this.database;
    var result = db.insert(noteTable, note.toMap());
    return result; 
  }
    Future<int> updatetNote(Note note) async{
    Database db=await this.database;
    var result = db.update(noteTable, note.toMap(),where: '$colId =?',whereArgs: [note.id]);
    return result; 
  }
  Future<int> deleteNote(int id) async{
        Database db=await this.database;
        var result=await db.delete(noteTable,where: '$colId = ?',whereArgs: [id] );
        return result;
  }

  Future<int> getCount() async{
    Database db=await this.database;
    String sql='SELECT COUNT (x) from $noteTable';
    List<Map<String,dynamic>> x=await db.rawQuery(sql);
    int result =Sqflite.firstIntValue(x);
    return result;
  }

  	// Get the 'Map List' [ List<Map> ] and convert it to 'Note List' [ List<Note> ]
	Future<List<Note>> getNoteList() async {

		var noteMapList = await getNotesMapList(); // Get 'Map List' from database
		int count = noteMapList.length;         // Count the number of map entries in db table

		List<Note> noteList = List<Note>();
		// For loop to create a 'Note List' from a 'Map List'
		for (int i = 0; i < count; i++) {
			noteList.add(Note.fromMapObject(noteMapList[i]));
		}

		return noteList;
	}
  

}