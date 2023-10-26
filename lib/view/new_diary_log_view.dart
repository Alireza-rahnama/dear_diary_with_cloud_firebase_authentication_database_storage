import 'package:dear_diary_with_firebase_auth_storage_database/view/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:dear_diary_with_firebase_auth_storage_database/controller/diary_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
  const DiaryLogView({Key? key}) : super(key: key);

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
              onPressed: () {
                // Save the edited content to the diary entry.
                print("long pressed!");
                diaryController.updateDiary(
                    diaryEntry.id,
                    DiaryModel(
                        description: descriptionEditingController.text,
                        rating: int.parse(ratingEditingController.text),
                        dateTime: DateTime.parse(dateEditingController.text),
                        id: diaryEntry.id));

                updateState();
                Navigator.of(context).pop();
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
      // filteredEntries = [];
      if (selectedMonth?.Number == 0) {
        filteredEntries = diaryEntries;
      } else {
        filteredEntries = (selectedMonth != null)
            ? diaryEntries.where((entry) {
                return entry.dateTime.month == selectedMonth!.Number;
              }).toList()
            : diaryEntries;
      }

      // Sort the filtered entries in reverse chronological order (newest first)
      filteredEntries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    });
  }

  void applyFilterAndUpdateState() async {
    final diaryEntries = await diaryController.getUserDiaries().first;
    // filteredEntries = [];
    setState(() {
      if (searchController.text == null) {
        filteredEntries = diaryEntries;
      } else {
        filteredEntries = (searchController.text != null)
            ? diaryEntries.where((entry) {
                print(searchController.text);
                return entry.description
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase());
              }).toList()
            : diaryEntries;
      }

      // Sort the filtered entries in reverse chronological order (newest first)
      filteredEntries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light);
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
                    onChanged: (_) {
                      applyFilterAndUpdateState();
                    },
                    leading: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          applyFilterAndUpdateState();
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
              // final diaries = snapshot.data!;
              // final diaries = filteredEntries;
              final diaries =
                  (!filteredEntries.isEmpty) ? filteredEntries : snapshot.data!;

              diaries.sort((a, b) => b.dateTime.compareTo(a.dateTime));

              return ListView.builder(
                itemCount: diaries.length,
                itemBuilder: (context, index) {
                  final entry = diaries[index];

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
                            Text(
                              entry.description,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
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
                                  color: Colors.black,
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
                builder: (context) => NewEntryView(),
              );
            },
            child: Icon(Icons.add),
          ),
        ));
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
