import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryModel2 {
  DateTime dateTime;
  var description;
  var rating;
  String? imagePath;
  List<String?>? imagePathList;
  final String? id;

  DiaryModel2({
    required this.dateTime,
    required this.description,
    required this.rating,
    this.imagePath,
    this.imagePathList,
    this.id,
  });

  Map<String, dynamic> toMap() {
    return {
      'dateTime': dateTime,
      'description': description,
      'rating': rating,
      'imagePath': imagePath,
      'imagePathList': imagePathList,
    };
  }

  static DiaryModel2 fromMap(DocumentSnapshot doc) {
    Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    Timestamp timestamp = map['dateTime'];

    return DiaryModel2(
      id: doc.id,
      dateTime: timestamp.toDate(),
      description: map['description'],
      rating: map['rating'],
      imagePath: map['imagePath'],
      imagePathList: map['imagePathList'] != null
          ? List<String?>.from(map['imagePathList'])
          : null,
    );
  }
}
