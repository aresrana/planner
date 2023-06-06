import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Test());
  }
}

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  Map<DateTime, List<List<String>>> cellDataMap = {}; // Map to hold entered details for each date
  DateTime selectedDate = DateTime.now(); // Variable to store the selected date

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  List<TableRow> generateTableRows(BuildContext context) {
    List<TableRow> rows = [];

    // Retrieve the data for the selected date
    List<List<String>> cellDataList = cellDataMap[selectedDate] ?? [];

    for (int row = 5; row <= 13; row++) {
      List<Widget> rowDataChildren = [];

      for (int col = 0; col < 4; col++) {
        Widget cell;

        if (col == 0) {
          cell = TableCell(
            child: Container(
              height: 50.0,
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: Center(
                child: Text(
                  '${row}:00',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        } else {
          cell = TableCell(
            child: GestureDetector(
              onTap: () {
                if (col != 0) {
                  _showCardForm(context, row, col);
                }
              },
              child: Container(
                height: 50.0,
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Center(
                  child: Text(
                    cellDataList.isNotEmpty
                        ? cellDataList[row - 5][col - 1]
                        : '',
                  ),
                ),
              ),
            ),
          );
        }

        rowDataChildren.add(cell);
      }

      rows.add(TableRow(children: rowDataChildren));
    }

    return rows;
  }
  void _showCardForm(BuildContext context, int row, int col) async {
    if (selectedDate.isBefore(DateTime.now())) {
      // Display the data for the past date, no editing allowed
      String data = cellDataMap[selectedDate]?[row - 5][col - 1] ?? '';
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('You can just view the data'),
            content: Text(data),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    } else {
      // Allow editing for the current and future dates
      TextEditingController _textEditingController = TextEditingController(
        text: cellDataMap[selectedDate]?[row - 5][col - 1] ?? '',
      );

      String? result = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Enter Details'),
            content: TextField(
              controller: _textEditingController,
              decoration: InputDecoration(hintText: 'Enter details'),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(_textEditingController.text);
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );

      if (result != null) {
        setState(() {
          cellDataMap[selectedDate] ??= List.generate(
            9,
                (index) => List.filled(4, ''),
          );
          cellDataMap[selectedDate]![row - 5][col - 1] = result;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table Example'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    _selectDate(context);
                  },
                  icon: Icon(Icons.calendar_today),
                ),
                SizedBox(width: 8.0),
                Text(
                  "${selectedDate.day}-${selectedDate.month}-${selectedDate.year}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Table(
              defaultColumnWidth: FlexColumnWidth(1),
              children: const [
                TableRow(
                  children: [
                    SizedBox(width: 50.0), // Empty space for the 1st column
                    TableCell(
                      child: Center(
                        child: Text(
                          'Drum',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Center(
                        child: Text(
                          'Bass Guitar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Center(
                        child: Text(
                          'Electric Guitar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Table(
                border: TableBorder.all(),
                children: generateTableRows(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
