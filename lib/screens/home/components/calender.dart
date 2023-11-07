import 'package:flutter/material.dart';
import 'package:shop_app/screens/home/home_screen.dart';
import 'package:table_calendar/table_calendar.dart';

import 'utils.dart';

class Calender extends StatefulWidget {
  static String routeName = "/calender";
  @override
  _CalenderState createState() => _CalenderState();
}

class _CalenderState extends State<Calender> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOn; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Date Range'),
        actions: [
          InkWell(
            onTap: () {
              if (_rangeStart != null && _rangeEnd != null) {
                // If a date range is selected, navigate to a new page and pass the range.
                // print(_rangeStart);
                // print(_rangeEnd);
                Navigator.pushReplacementNamed(context, HomeScreen.routeName, arguments: {
                  'rangeStart': _rangeStart,
                  'rangeEnd': _rangeEnd,
                });
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Date Range Not Selected'),
                      content: Text('Please select a date range before proceeding.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'OK',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 6, 14, 12),
              decoration: BoxDecoration(
                color: Colors.orange, // Change the button color as needed
                borderRadius: BorderRadius.circular(8.0), // Adjust the border radius
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3), // Shadow color
                    spreadRadius: 1, // Spread radius
                    blurRadius: 2, // Blur radius
                    offset: Offset(0, 2), // Offset of the shadow
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Adjust padding
              child: Text(
                'Select Range',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16, // Adjust the font size as needed
                  fontWeight: FontWeight.bold, // Adjust the font weight as needed
                ),
              ),
            ),
          ),
        ],
      ),
      body: TableCalendar(
        firstDay: kFirstDay,
        lastDay: kLastDay,
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        rangeStartDay: _rangeStart,
        rangeEndDay: _rangeEnd,
        calendarFormat: _calendarFormat,
        rangeSelectionMode: _rangeSelectionMode,
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _rangeStart = null; // Important to clean those
              _rangeEnd = null;
              _rangeSelectionMode = RangeSelectionMode.toggledOff;
            });
          }
        },
        onRangeSelected: (start, end, focusedDay) {
          setState(() {
            _selectedDay = null;
            _focusedDay = focusedDay;
            _rangeStart = start;
            _rangeEnd = end;
            _rangeSelectionMode = RangeSelectionMode.toggledOn;
          });
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },

        calendarStyle: CalendarStyle( // Define a custom calendar styl
          rangeHighlightColor: Colors.orange.withOpacity(0.3),
          rangeStartDecoration: BoxDecoration(
            color: Colors.orange, // Change the selected date color to orange
            shape: BoxShape.circle,
          ),
          rangeEndDecoration: BoxDecoration(
            color: Colors.orange, // Change the selected date color to orange
            shape: BoxShape.circle,
          ),
          isTodayHighlighted: false,
        ),
      ),
    );
  }
}