// import 'package:dear_diary_with_hive/controller/diary_entry_service.dart';
// import 'package:dear_diary_with_hive/model/diary_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controller/diary_entry_service.dart';
import '../model/diary_model.dart';
import 'diary_list_view..dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NewEntryView extends StatefulWidget {
  bool isDark;

  NewEntryView.withInheritedTheme(this.isDark);

  @override
  // _NewEntryViewState createState() => _NewEntryViewState();
  _NewEntryViewState createState() =>
      _NewEntryViewState.withInheritedTheme(isDark);
}

class _NewEntryViewState extends State<NewEntryView> {
  final TextEditingController descriptionController = TextEditingController();
  double rating = 3.0; // Initial rating value
  DateTime selectedDate = DateTime.now(); // Initial date value
  late String description;
  String? imagePath;
  var diaryController = DiaryController();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  late bool isDark;

  _NewEntryViewState.withInheritedTheme(bool isDark) {
    this.isDark = isDark;
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  Future<String?> _uploadImageToFirebaseAndReturnDownlaodUrl() async {
    if (_image == null) return null;
    String? downloadURL = null;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return null;
    final firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('images/${currentUser.uid}/${_image!.name}');

    try {
      final uploadTask = await firebaseStorageRef.putFile(File(_image!.path));
      if (uploadTask.state == TaskState.success) {
        downloadURL = await firebaseStorageRef.getDownloadURL();

        print("Uploaded to: $downloadURL");
      }
    } catch (e) {
      print("Failed to upload image: $e");
    }
    return downloadURL;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  void _saveDiaryEntry() async {
    description = descriptionController.text;
    imagePath = await _uploadImageToFirebaseAndReturnDownlaodUrl();
    if (description == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Center(child: Text('Description can not be left empty!')),
            backgroundColor: Colors.deepPurple),
      );
      return;
    }
    DiaryModel diaryEntry = DiaryModel(
        dateTime: selectedDate,
        description: description,
        rating: rating.toInt(),
        imagePath: imagePath);

    bool successfullyAdded =
        await diaryController.addDiaryWithDateCheck(diaryEntry);

    descriptionController.clear();
    print('rating is: $rating');
    try {
      if (successfullyAdded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Entry successfully saved!'),
              backgroundColor: Colors.deepPurple),
        );
        print('isDark in diary entry view is: $isDark');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DiaryLogView.WithPersistedTheme(isDark)),
        );

      } else if (!successfullyAdded) {
        // Show the error dialog when the button is pressed
        showDialog(
          context: context,
          builder: (context) {
            return ErrorDialog();
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Unexpected error ocured: $e'),
            backgroundColor: Colors.deepPurple),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light);

    return Theme(
        data: themeData,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.deepPurple,
            title: Text("Add Diary Entry",
                style: GoogleFonts.pacifico(
                  color: Colors.white,
                  fontSize: 30.0,
                )),
            leading: IconButton(
                icon: Icon(Icons.arrow_back_outlined),
                tooltip: 'Go back',
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => DiaryLogView()),
                  // );
                }),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter your description (max 140 characters)',
                  ),
                  maxLength: 140, // Set the maximum character limit
                  maxLines: null, // Allow multiple lines of text
                ),
                Text('Enter your description (max 140 characters)',
                    style: TextStyle(
                      color: Colors.grey, // Customize the hint text color
                      fontSize: 12, // Customize the hint text font size
                    )),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Rate Your Day: ${rating.toInt()} Stars'),
                    Slider(
                      value: rating,
                      min: 1,
                      max: 5,
                      onChanged: (newRating) {
                        setState(() {
                          rating = newRating;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('Date: ${selectedDate.toLocal()}'.split(' ')[0]),
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      child: Text(
                          '${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _pickImageFromGallery,
                  child: Text('Add Image from Gallery'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _pickImageFromCamera,
                  child: Text('Add Image from Camera'),
                ),
                SizedBox(height: 60),
                ElevatedButton(
                  onPressed: _saveDiaryEntry,
                  child: Text('Save Entry'),
                ),
              ],
            ),
          ),
        )
    );
  }
}

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Error Exception'),
      content: const Text('Entry already exists for this date!'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
