// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import '../controller/diary_controller.dart';
// import '../model/diary_model.dart';
// import 'diary_entry_view.dart';
// import 'package:pdf/widgets.dart' as pw;
//
// class DiaryLogsListView extends StatefulWidget {
//   DiaryController diaryController = DiaryController();
//
//   @override
//   _DiaryLogsListViewState createState() => _DiaryLogsListViewState();
// }
//
// class _DiaryLogsListViewState extends State<DiaryLogsListView> {
//   Month? selectedMonth;
//   late List<DiaryModel> filteredEntries;
//
//   void updateState() {
//     setState(() {
//       List<DiaryModel> diaryEntries = widget.diaryController.getUserDiaries() as List<DiaryModel>;
//
//       filteredEntries = [];
//       if (selectedMonth?.Number == 0) {
//         filteredEntries = diaryEntries;
//       } else {
//         filteredEntries = (selectedMonth != null)
//             ? diaryEntries.where((entry) {
//           return entry.dateTime.month == selectedMonth!.Number;
//         }).toList()
//             : diaryEntries;
//       }
//
//       // Sort the filtered entries in reverse chronological order (newest first)
//       filteredEntries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
//     });
//   }
//
//   void _showEditDialog(BuildContext context, DiaryModel diaryEntry, int index) {
//     TextEditingController descriptionEditingController = TextEditingController();
//     descriptionEditingController.text = diaryEntry.description; // Initialize the text field with existing content.
//
//     TextEditingController ratingEditingController = TextEditingController();
//     ratingEditingController.text = diaryEntry.rating.toString();
//
//     TextEditingController dateEditingController = TextEditingController();
//     dateEditingController.text = DateFormat('yyyy-MM-dd').format(diaryEntry.dateTime);
//
//     DiaryController diaryController = DiaryController();
//     List<DiaryModel> allEntries = diaryController.getUserDiaries() as List<DiaryModel>;
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Edit Diary Entry'),
//           content: Column(children: [
//             TextField(
//               controller: descriptionEditingController,
//               decoration: InputDecoration(labelText: "New Description"),
//               maxLines: null, // Allows multiple lines of text.
//             ),
//             TextField(
//               controller: ratingEditingController,
//               decoration: InputDecoration(labelText: "New Rating"),
//               maxLines: null, // Allows multiple lines of text.
//             ),
//             TextField(
//               controller: dateEditingController,
//               decoration: InputDecoration(labelText: "New Date"),
//               maxLines: null, // Allows multiple lines of text.
//             )
//           ]),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text('Save'),
//               onPressed: () {
//                 // Save the edited content to the diary entry.
//
//                 diaryController.updateDiary(DiaryModel(description: descriptionEditingController.text,
//                     rating: int.parse(ratingEditingController.text), dateTime: DateTime.parse(dateEditingController.text)));
//
//                 updateState();
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context){
//     // Get all diary entries
//     final diaryEntries = await widget.diaryController.getUserDiaries().first;
//
//     filteredEntries = [];
//     if (selectedMonth?.Number == 0) {
//       filteredEntries = diaryEntries;
//     } else {
//       filteredEntries = (selectedMonth != null)
//           ? diaryEntries.where((entry) {
//         return entry.dateTime.month == selectedMonth!.Number;
//       }).toList()
//           : diaryEntries;
//     }
//
//     // Sort the filtered entries in reverse chronological order (newest first)
//     filteredEntries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
//
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.add),
//           tooltip: 'Add New Entry',
//           color: Colors.white,
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => NewEntryView()),
//             );
//           },
//         ),
//         backgroundColor: Colors.deepPurple,
//         title: Text(
//           'Diary Entries',
//           style: GoogleFonts.pacifico(
//             color: Colors.white,
//             fontSize: 30.0,
//           ),
//         ),
//         actions: <Widget>[
//           IconButton(
//             icon: Icon(Icons.picture_as_pdf),
//             color: Colors.white,
//             onPressed: () async {
//               print("saved pdf file!");
//               await exportToPDF(widget.diaryController);
//             },
//           ),
//           // Add a filter button for selecting a month
//           PopupMenuButton<Month>(
//             onSelected: (Month month) {
//               setState(() {
//                 selectedMonth = month;
//               });
//             },
//             icon: Icon(
//               Icons.filter_list,
//               color: Colors.white,
//             ),
//             itemBuilder: (BuildContext context) {
//               // Create a list of months for filtering
//               final List<Month> months = [
//                 Month(0, 'All'), // January
//                 Month(1, 'Jan'), // February
//                 Month(2, 'Feb'), // March
//                 Month(3, 'Mar'), // April
//                 Month(4, 'Apr'), // May
//                 Month(5, 'May'), // June
//                 Month(6, 'Jun'), // July
//                 Month(7, 'Jul'), // August
//                 Month(8, 'Aug'), // September
//                 Month(9, 'Sep'), // October
//                 Month(10, 'Oct'), // November
//                 Month(11, 'Nov'), // December
//                 Month(12, 'Dec'), // December
//               ];
//
//               return months.map((Month month) {
//                 return PopupMenuItem<Month>(
//                   value: month,
//                   child: Text(month.Name),
//                 );
//               }).toList();
//             },
//           ),
//         ],
//       ),
//       body: ListView.builder(
//         itemCount: filteredEntries.length,
//         itemBuilder: (context, index) {
//           final entry = filteredEntries[index];
//
//           return Card(
//             margin: EdgeInsets.all(8.0),
//             child: GestureDetector(
//               onLongPress: () {
//                 // Perform your action here when the Card is long-pressed.
//                 _showEditDialog(context, entry, index);
//               },
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       entry.description,
//                       style: TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(height: 15),
//                     Text(
//                       '${DateFormat('yyyy-MM-dd').format(entry.dateTime)}',
//                       style: TextStyle(fontSize: 14),
//                     ),
//                     SizedBox(height: 15),
//                     Row(
//                       children: [
//                         RatingEvaluator(entry),
//                         Spacer(),
//                         Spacer(),
//                         IconButton(
//                           icon: Icon(Icons.delete),
//                           color: Colors.black,
//                           onPressed: () {
//                             // widget.diaryController.deleteDiaryAtIndex(index);
//                             widget.diaryController.deleteDiary(entry!.id);
//
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => DiaryLogsListView(),
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
// // Rest of your code...
// }
//
// Future<void> exportToPDF(DiaryController diaryController) async {
//   // Create a new PDF document
//   final pdf = pw.Document();
//
//   // Retrieve data from Hive
//   final firebaseFetchedDiaries = await diaryController.getUserDiaries();
//
//   List<pw.Widget> list = await pdfTextChildren(firebaseFetchedDiaries as List<DiaryModel>);
//
// // In the Page build method:
//   // Populate the PDF content with data
//   pdf.addPage(
//     pw.Page(
//       build: (pw.Context context) {
//         return pw.Column(
//           children: list,
//         );
//       },
//     ),
//   );
//
//   // Save the PDF file
//   final directory = await getApplicationDocumentsDirectory();
//   print(directory);
//   final file = File('${directory.path}/hive_data.pdf');
//   // final file = File('fonts/hive_data.pdf');
//
//   await file.writeAsBytes(await pdf.save());
// }
//
// Future<List<pw.Widget>> pdfTextChildren(List<DiaryModel> entries) async {
//   List<pw.Widget> textList = [];
//   // final ttf = File('/Users/alirezarahnama/StudioProjects/dear_diary_with_hive/fonts/Pacifico-Regular.ttf').readAsBytesSync();
//   // final ttf = File('../../fonts/Pacifico-Regular.ttf').readAsBytesSync();
//   final fontData = await rootBundle.load('fonts/Pacifico-Regular.ttf');
//   final ttf = fontData.buffer.asUint8List();
//   final font = pw.Font.ttf(ttf.buffer.asByteData());
//
//   for (DiaryModel entry in entries) {
//     textList.add(
//       pw.Text(
//         'On ${DateFormat('yyyy-MM-dd').format(entry.dateTime)}, ${entry.description} was rated ${entry.rating} stars.',
//         style: pw.TextStyle(font: font, fontSize: 12),
//       ),
//     );
//   }
//   return textList;
// }
//
// Row RatingEvaluator(DiaryModel entry) {
//   switch (entry.rating) {
//     case (1):
//       return Row(children: [
//         Icon(Icons.star),
//       ]);
//     case (2):
//       return Row(children: [Icon(Icons.star), Icon(Icons.star)]);
//     case (3):
//       return Row(
//           children: [Icon(Icons.star), Icon(Icons.star), Icon(Icons.star)]);
//     case (4):
//       return Row(children: [
//         Icon(Icons.star),
//         Icon(Icons.star),
//         Icon(Icons.star),
//         Icon(Icons.star)
//       ]);
//     case (5):
//       return Row(children: [
//         Icon(Icons.star),
//         Icon(Icons.star),
//         Icon(Icons.star),
//         Icon(Icons.star),
//         Icon(Icons.star)
//       ]);
//     default:
//       return Row(); // Handle other cases or return an empty row if the rating is not 1-5.
//   }
// }
//
// class Month {
//   int num;
//   String name;
//
//   Month(this.num, this.name);
//
//   String get Name {
//     return name;
//   }
//
//   int get Number {
//     return num;
//   }
// }
//
//
