import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dear_diary_with_firebase_auth_storage_database/model/diary_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/diary_model2.dart';

/// A service class that provides methods to perform CRUD operations
/// on user's cars stored in Firestore.
class DiaryController2 {
  /// The currently authenticated user from Firebase.
  final user = FirebaseAuth.instance.currentUser;

  /// A reference to the Firestore collection where the cars for
  /// the current user are stored.
  final CollectionReference diaryCollection2;

  /// Constructor initializes the reference to the Firestore collection
  /// specific to the current user's car details.
  DiaryController2()
      : diaryCollection2 = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('diaries2');

  /// Adds a new diary entry to Firestore and returns the document reference.
  Future<bool> addDiaryWithDateCheck(DiaryModel2 diaryEntry) async {
    bool shouldAdd = true;

    final snapshot =
    await getUserDiaries().first; // Wait for the first snapshot

    for (DiaryModel2 diary in snapshot) {
      if (diary.dateTime.day == diaryEntry.dateTime.day) {
        shouldAdd = false;
        break;
      }
    }

    if (shouldAdd) {
      await diaryCollection2.add(diaryEntry.toMap());
    }
    return shouldAdd;
  }

  /// Updates details of an existing [diary] in Firestore.
  Future<void> updateDiary(String? diaryToUpdateId, DiaryModel2 diary) async {
    return await diaryCollection2.doc(diary.id).update(diary.toMap());
  }

  /// Deletes a car with the specified [id] from Firestore.
  Future<void> deleteDiary(String? id) async {
    return await diaryCollection2.doc(id).delete();
  }

  /// Retrieves a stream of a list of `DairyModel` objects associated
  /// with the current user from Firestore.
  Stream<List<DiaryModel2>> getUserDiaries() {
    return diaryCollection2.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => DiaryModel2.fromMap(doc)).toList();
    });
  }
}
