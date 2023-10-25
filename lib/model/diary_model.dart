import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryModel {
  DateTime dateTime;
  var description;
  var rating;
  String? imagePath;
  /// The unique identifier for the car.
  /// Might be `null` before saving to Firestore.
  final
  String? id;


  DiaryModel(
      {required this.dateTime,
      required this.description,
      required this.rating,
      this.imagePath,
      this.id});

  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime,
      'description': description,
      'rating' : rating,
      'imagePath' : imagePath
    };
  }

  /// Converts a Firestore `DocumentSnapshot` back into a `Todo` object.
  ///
  /// This static method handles the **deserialization** process. It extracts the
  /// data from the Firestore document and constructs a `Todo` object. By providing
  /// this method, it offers an encapsulated way to transform Firestore data back
  /// into custom Dart objects, making CRUD (Create, Read, Update, Delete) operations
  /// easier and more intuitive.
  ///
  /// [doc] is the Firestore `DocumentSnapshot` that contains the data to be deserialized.
  static DiaryModel fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    Timestamp timestamp = map['dateTime'];

    return DiaryModel(
      id: doc.id,
      dateTime: timestamp.toDate(),
      description: map['description'],
      rating: map['rating'],
      imagePath: map['imagePath']
    );
  }
}
