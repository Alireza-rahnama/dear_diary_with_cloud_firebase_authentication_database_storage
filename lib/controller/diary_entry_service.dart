import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dear_diary_with_firebase_auth_storage_database/model/diary_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// A service class that provides methods to perform CRUD operations
/// on user's cars stored in Firestore.
class DiaryController {
  /// The currently authenticated user from Firebase.
  final user = FirebaseAuth.instance.currentUser;

  /// A reference to the Firestore collection where the cars for
  /// the current user are stored.
  final CollectionReference diaryCollection;

  /// Constructor initializes the reference to the Firestore collection
  /// specific to the current user's car details.
  DiaryController()
      : diaryCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('diaries');

  /// Adds a new diary entry to Firestore and returns the document reference.
  Future<bool> addDiaryWithDateCheck(DiaryModel diaryEntry) async {
    bool shouldAdd = true;

    final snapshot =
        await getUserDiaries().first; // Wait for the first snapshot

    for (DiaryModel diary in snapshot) {
      if (diary.dateTime.day == diaryEntry.dateTime.day) {
        shouldAdd = false;
        break;
      }
    }

    if (shouldAdd) {
      await diaryCollection.add(diaryEntry.toMap());
    }
    return shouldAdd;
  }

  /// Updates details of an existing [diary] in Firestore.
  Future<void> updateDiary(String? diaryToUpdateId, DiaryModel diary) async {
    return await diaryCollection.doc(diary.id).update(diary.toMap());
  }

  /// Deletes a car with the specified [id] from Firestore.
  Future<void> deleteDiary(String? id) async {
    return await diaryCollection.doc(id).delete();
  }

  /// Retrieves a stream of a list of `DairyModel` objects associated
  /// with the current user from Firestore.
  Stream<List<DiaryModel>> getUserDiaries() {
    return diaryCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => DiaryModel.fromMap(doc)).toList();
    });
  }
}
