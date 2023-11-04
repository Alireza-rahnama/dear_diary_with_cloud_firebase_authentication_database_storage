import 'package:dear_diary_with_firebase_auth_storage_database/view/auth_gate.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:dear_diary_with_firebase_auth_storage_database/controller/diary_entry_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../model/diary_model.dart';
import 'diary_entry_view.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// A stateless widget representing the main page where users can view
/// and manage their cars after authentication.
class DiaryLogView extends StatefulWidget {
// Constructor to create a HomePage widget.
  DiaryLogView({Key? key}) : super(key: key);
  static final isDark = _DiaryLogViewState().isDark;
  @override
  State<DiaryLogView> createState() => _DiaryLogViewState();


}

class _DiaryLogViewState extends State<DiaryLogView> {
// Instance of CarService to interact with Firestore for CRUD operations on cars.
  final DiaryController diaryController = DiaryController();
  Month? selectedMonth;
  bool isDark = false;
  List<DiaryModel> filteredEntries = [];
  final TextEditingController searchController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<String?> _uploadImageToFirebaseAndReturnDownlaodUrl(
      String? existingImagePath) async {
    if (_image == null) return existingImagePath;
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

  void _showEditDialog(BuildContext context, DiaryModel diaryEntry, int index) {
    TextEditingController descriptionEditingController =
        TextEditingController();
    descriptionEditingController.text = diaryEntry
        .description; // Initialize the text field with existing content.

    TextEditingController ratingEditingController = TextEditingController();
    ratingEditingController.text = diaryEntry.rating.toString();

    TextEditingController dateEditingController = TextEditingController();
    dateEditingController.text =
        DateFormat('yyyy-MM-dd').format(diaryEntry.dateTime);

    DiaryController diaryController = DiaryController();
    // List<DiaryModel> allEntries = diaryController.getUserDiaries() as List<DiaryModel>;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Diary Entry'),
          content: Column(children: [
            TextField(
              controller: descriptionEditingController,
              decoration: InputDecoration(labelText: "New Description"),
              maxLines: null, // Allows multiple lines of text.
            ),
            TextField(
              controller: ratingEditingController,
              decoration: InputDecoration(labelText: "New Rating"),
              maxLines: null, // Allows multiple lines of text.
            ),
            TextField(
              controller: dateEditingController,
              decoration: InputDecoration(labelText: "New Date"),
              maxLines: null, // Allows multiple lines of text.
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _pickImageFromGallery(),
              child: Text('pick image from gallery'),
            )
          ]),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                // Save the edited content to the diary entry.
                print("long pressed!");
                diaryController.updateDiary(
                    diaryEntry.id,
                    DiaryModel(
                        description: descriptionEditingController.text,
                        rating: int.parse(ratingEditingController.text),
                        dateTime: DateTime.parse(dateEditingController.text),
                        imagePath:
                            await _uploadImageToFirebaseAndReturnDownlaodUrl(
                                diaryEntry.imagePath),
                        id: diaryEntry.id));

                updateState();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Center(child: Text('Entry successfully saved!')),
                      backgroundColor: Colors.deepPurple),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void updateState() async {
    final diaryEntries = await diaryController.getUserDiaries().first;

    setState(() {
      if (selectedMonth?.Number == 0) {
        filteredEntries = diaryEntries;
      } else {
        filteredEntries = (selectedMonth != null)
            ? diaryEntries.where((entry) {
                return entry.dateTime.month == selectedMonth!.Number;
              }).toList()
            : diaryEntries;
      }
      print('filteredEntries.length: ${filteredEntries.length}');
      // Sort the filtered entries in reverse chronological order (newest first)
      filteredEntries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    });
  }

  void applyFilterAndUpdateState3() async {
    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final diaryEntries = await diaryController.getUserDiaries().first;

    setState(() {
      // Initialize filteredEntries with a copy of diaryEntries
      filteredEntries = List<DiaryModel>.from(diaryEntries);

      // Filter based on the search query
      // Or Filter based on the month if it matches one of the month abbreviations
      if (searchController.text.isNotEmpty) {
        filteredEntries = filteredEntries.where((entry) {
          return entry.description
                  .toLowerCase()
                  .contains(searchController.text.toLowerCase()) ||
              convertIntMonthToStringRepresentation(entry.dateTime.month)
                  .contains(searchController.text.toLowerCase());
        }).toList();
      } else {
        filteredEntries = filteredEntries.where((entry) {
          return entry.dateTime.month == selectedMonth!.num;
        }).toList();
      }

      filteredEntries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    });
  }

  String convertIntMonthToStringRepresentation(int month) {
    String representation = '';
    switch (month) {
      case 1:
        representation = 'jan';
        break;
      case 2:
        representation = 'feb';
        break;
      case 3:
        representation = 'mar';
        break;
      case 4:
        representation = 'apr';
        break;
      case 5:
        representation = 'may';
        break;
      case 6:
        representation = 'jun';
        break;
      case 7:
        representation = 'jul';
        break;
      case 8:
        representation = 'aug';
        break;
      case 9:
        representation = 'sep';
        break;
      case 10:
        representation = 'oct';
        break;
      case 11:
        representation = 'nov';
        break;
      case 12:
        representation = 'dec';
        break;
    }
    return representation;
  }

  @override
  void initState() {
    super.initState();
    updateState(); // Initially, load all diary entries
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light);
    // List<DiaryModel> filteredEntries = [];

    return Theme(
        data: themeData,
        child: Scaffold(
// App bar with a title and a logout button.
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.picture_as_pdf),
              color: Colors.white,
              onPressed: () async {
                print("saved pdf file!");
                await exportToPDF(diaryController);
              },
            ),
            backgroundColor: Colors.deepPurple,
            title: Text("Add Diary Entry",
                style: GoogleFonts.pacifico(
                  color: Colors.white,
                  fontSize: 30.0,
                )),
            actions: [
              IconButton(
                color: Colors.white,
                icon: Icon(Icons.logout),
// Sign out the user on pressing the logout button.
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AuthGate(),
                    ),
                  );
                },
              ),
              PopupMenuButton<Month>(
                onSelected: (Month month) async {
                  setState(() {
                    selectedMonth = month;
                  });
                  print("selectedMonth is ${selectedMonth!.name}");
                  applyFilterAndUpdateState3();
                },
                icon: Icon(
                  Icons.filter_list,
                  color: Colors.white,
                ),
                itemBuilder: (BuildContext context) {
                  // Create a list of months for filtering
                  final List<Month> months = [
                    Month(0, 'All'), // January
                    Month(1, 'Jan'), // February
                    Month(2, 'Feb'), // March
                    Month(3, 'Mar'), // April
                    Month(4, 'Apr'), // May
                    Month(5, 'May'), // June
                    Month(6, 'Jun'), // July
                    Month(7, 'Jul'), // August
                    Month(8, 'Aug'), // September
                    Month(9, 'Sep'), // October
                    Month(10, 'Oct'), // November
                    Month(11, 'Nov'), // December
                    Month(12, 'Dec'), // December
                  ];

                  return months.map((Month month) {
                    return PopupMenuItem<Month>(
                      value: month,
                      child: Text(month.Name),
                    );
                  }).toList();
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(48.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SearchAnchor(builder:
                    (BuildContext context, SearchController controller) {
                  return SearchBar(
                    controller: searchController,
                    padding: const MaterialStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0)),
                    onChanged: (_) async {
                      applyFilterAndUpdateState3();
                    },
                    leading: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          applyFilterAndUpdateState3();
                        }),
                    trailing: <Widget>[
                      Tooltip(
                        message: 'Change brightness mode',
                        child: IconButton(
                          isSelected: isDark,
                          onPressed: () {
                            setState(() {
                              isDark = !isDark;
                            });
                          },
                          icon: const Icon(Icons.wb_sunny_outlined),
                          selectedIcon: const Icon(Icons.brightness_2_outlined),
                        ),
                      )
                    ],
                  );
                }, suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                  return List<ListTile>.generate(5, (int index) {
                    final String item = 'item $index';
                    return ListTile(
                      title: Text(item),
                      onTap: () {
                        setState(() {
                          controller.closeView(item);
                        });
                      },
                    );
                  });
                }),
              ),
            ),
          ),

          // Body of the widget using a StreamBuilder to listen for changes
          // in the diary collection and reflect them in the UI in real-time.
          body: StreamBuilder<List<DiaryModel>>(
            stream: diaryController.getUserDiaries(),
            builder: (context, snapshot) {
              // Show a loading indicator until data is fetched from Firestore.
              if (!snapshot.hasData) return CircularProgressIndicator();

              List<DiaryModel> diaries =
                  (!filteredEntries.isEmpty) ? filteredEntries : snapshot.data!;
              diaries.sort((a, b) => b.dateTime.compareTo(a.dateTime));

              DateTime? lastDate;

              return ListView.builder(
                itemCount: diaries.length,
                itemBuilder: (context, index) {
                  final entry = diaries[index];
                  if (lastDate == null ||
                      entry.dateTime.month != lastDate?.month ||
                      entry.dateTime.year != lastDate?.year) {
                    final headerText =
                        DateFormat('MMMM yyyy').format(entry.dateTime);
                    lastDate = entry.dateTime!;
                    return Column(
                      children: [
                        DateHeader(text: headerText),
                        Card(
                          margin: EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onLongPress: () {
                              // Perform your action here when the Card is long-pressed.
                              _showEditDialog(context, entry, index);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BuildImageFromUrl(entry),
                                  Text(
                                    entry.description,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Text(
                                    '${DateFormat('yyyy-MM-dd').format(entry.dateTime)}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    children: [
                                      RatingEvaluator(entry),
                                      Spacer(),
                                      Spacer(),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          // widget.diaryController.deleteDiaryAtIndex(index);
                                          diaryController
                                              .deleteDiary(entry!.id);

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DiaryLogView(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onLongPress: () {
                          // Perform your action here when the Card is long-pressed.
                          _showEditDialog(context, entry, index);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BuildImageFromUrl(entry),
                              Text(
                                entry.description,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 15),
                              Text(
                                '${DateFormat('yyyy-MM-dd').format(entry.dateTime)}',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 15),
                              Row(
                                children: [
                                  RatingEvaluator(entry),
                                  Spacer(),
                                  Spacer(),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      // widget.diaryController.deleteDiaryAtIndex(index);
                                      diaryController.deleteDiary(entry!.id);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DiaryLogView(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
// Floating action button to open a dialog for adding a new diary
          floatingActionButton: FloatingActionButton(
            onPressed: () {
// Display the AddNewDiary when the button is pressed.
              showDialog(
                context: context,
                builder: (context) => NewEntryView.withInheritedTheme(isDark),
              );
            },
            child: Icon(Icons.add),
          ),
        ));
  }
}

Widget BuildImageFromUrl(DiaryModel entry) {
  if (entry.imagePath != null) {
    // If entry.imagePath is not null, display the image from the network
    // return Container(child: Image.network(entry.imagePath!),
    //     height: 100, fit: BoxFit.cover );

    return Card(
      elevation: 4, // Add elevation for a card-like appearance
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8), // Add rounded corners
        child: Image.network(
          entry.imagePath!,
          height: 200,
          width: 400, // Set a fixed size for the image
          fit: BoxFit.cover, // Adjust how the image is displayed
        ),
      ),
    );
  } else {
    // If entry.imagePath is null, display a placeholder or an empty container
    return Container(); // You can customize this to show a placeholder image
  }
}

Row RatingEvaluator(DiaryModel entry) {
  switch (entry.rating) {
    case (1):
      return Row(children: [
        Icon(Icons.star),
      ]);
    case (2):
      return Row(children: [Icon(Icons.star), Icon(Icons.star)]);
    case (3):
      return Row(
          children: [Icon(Icons.star), Icon(Icons.star), Icon(Icons.star)]);
    case (4):
      return Row(children: [
        Icon(Icons.star),
        Icon(Icons.star),
        Icon(Icons.star),
        Icon(Icons.star)
      ]);
    case (5):
      return Row(children: [
        Icon(Icons.star),
        Icon(Icons.star),
        Icon(Icons.star),
        Icon(Icons.star),
        Icon(Icons.star)
      ]);
    default:
      return Row(); // Handle other cases or return an empty row if the rating is not 1-5.
  }
}

class Month {
  int num;
  String name;

  Month(this.num, this.name);

  String get Name {
    return name;
  }

  int get Number {
    return num;
  }
}

Future<void> exportToPDF(DiaryController diaryController) async {
  // Create a new PDF document
  final pdf = pw.Document();

  // Retrieve data from Hive
  final firebaseFetchedDiaries = await diaryController.getUserDiaries();

  List<pw.Widget> list =
      await pdfTextChildren(firebaseFetchedDiaries as List<DiaryModel>);

// In the Page build method:
  // Populate the PDF content with data
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: list,
        );
      },
    ),
  );

  // Save the PDF file
  final directory = await getApplicationDocumentsDirectory();
  print(directory);
  final file = File('${directory.path}/hive_data.pdf');
  // final file = File('fonts/hive_data.pdf');

  await file.writeAsBytes(await pdf.save());
}

Future<List<pw.Widget>> pdfTextChildren(List<DiaryModel> entries) async {
  List<pw.Widget> textList = [];
  // final ttf = File('/Users/alirezarahnama/StudioProjects/dear_diary_with_hive/fonts/Pacifico-Regular.ttf').readAsBytesSync();
  // final ttf = File('../../fonts/Pacifico-Regular.ttf').readAsBytesSync();
  final fontData = await rootBundle.load('fonts/Pacifico-Regular.ttf');
  final ttf = fontData.buffer.asUint8List();
  final font = pw.Font.ttf(ttf.buffer.asByteData());

  for (DiaryModel entry in entries) {
    textList.add(
      pw.Text(
        'On ${DateFormat('yyyy-MM-dd').format(entry.dateTime)}, ${entry.description} was rated ${entry.rating} stars.',
        style: pw.TextStyle(font: font, fontSize: 12),
      ),
    );
  }
  return textList;
}

class DateHeader extends StatelessWidget {
  final String text;

  const DateHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8.0),
        child: Text(text,
            style: GoogleFonts.pacifico(
              color: Colors.deepPurple,
              fontSize: 30.0,
            )));
  }
}
