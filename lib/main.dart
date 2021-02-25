//  Copyright (c) 2019 Aleksander Woźniak
//  Licensed under Apache License v2.0

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'clock_view.dart';

// Example holidays
final Map<DateTime, List> _holidays = {
  DateTime(2020, 1, 1): ['New Year\'s Day'],
  DateTime(2020, 1, 6): ['Epiphany'],
  DateTime(2020, 2, 14): ['Valentine\'s Day'],
  DateTime(2020, 4, 21): ['Easter Sunday'],
  DateTime(2020, 4, 22): ['Easter Monday'],
};

final eventTypes = ['Study', 'WorkOut', 'Date', 'HangOut'];

enum EventType {
  study,
  WorkOut,
  Date,
  HangOut,
}

class SingleEvent {
  SingleEvent({
    this.name,
    this.description,
    this.type,
    this.isallday,
  });

  String type;
  String name;
  String description = 'No Description';
  bool isallday = false;
}

void main() {
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Table Calendar Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(title: 'Table Calendar Demo'),
      },
      //home: MyHomePage(title: 'Table Calendar Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  Map<DateTime, List> _events;
  List _selectedEvents;
  DateTime _selectedDay;
  AnimationController _animationController;
  CalendarController _calendarController;

  double _listViewOpacity;

  @override
  void initState() {
    super.initState();
    final _now = DateTime.now();
    _selectedDay = DateTime(_now.year, _now.month, _now.day);

    print('Selected Day in initState: $_selectedDay');

    _events = {
      _selectedDay.subtract(Duration(days: 30)): [
        SingleEvent(name: 'Event A0'),
        SingleEvent(name: 'Event B0'),
        SingleEvent(name: 'Event C0')
      ],
      _selectedDay.subtract(Duration(days: 27)): [
        SingleEvent(name: 'Event A1')
      ],
      _selectedDay.subtract(Duration(days: 20)): [
        SingleEvent(name: 'Event A2'),
        SingleEvent(name: 'Event B2'),
        SingleEvent(name: 'Event C2'),
        SingleEvent(name: 'Event D2'),
        SingleEvent(name: 'Event E2')
      ],
      _selectedDay.subtract(Duration(days: 16)): [
        SingleEvent(name: 'Event A3'),
        SingleEvent(name: 'Event B3')
      ],
      _selectedDay.subtract(Duration(days: 10)): [
        SingleEvent(name: 'Event A4'),
        SingleEvent(name: 'Event B4'),
        SingleEvent(name: 'Event C4')
      ],
      _selectedDay.subtract(Duration(days: 4)): [
        SingleEvent(name: 'Event A5'),
        SingleEvent(name: 'Event B5'),
        SingleEvent(name: 'Event C5')
      ],
    };

    _selectedEvents = _events[_selectedDay] ?? [];
    _calendarController = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();

    _listViewOpacity = 0.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedEvents = events;
      _selectedDay = DateTime(day.year, day.month, day.day);

      if (_selectedEvents.isNotEmpty) {
        _calendarController.setCalendarFormat(CalendarFormat.week);
        _listViewOpacity = 1.0;
      } else {
        _calendarController.setCalendarFormat(CalendarFormat.month);
        _listViewOpacity = 0.0;
      }
    });
  }

  void _onVisibleDaysChanged(DateTime first, DateTime last,
      CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(DateTime first, DateTime last,
      CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          ClockView(),
          _buildTableCalendarWithBuilders(),
          const SizedBox(height: 8.0),
          _buildButtons(),
          const SizedBox(height: 8.0),
          _buildEventList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _createNewScheduleDialog(context);
          },
          child: Icon(Icons.add)),
    );
  }

  // More advanced TableCalendar configuration (using Builders & Styles)
  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      locale: 'ko_KR',
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
        CalendarFormat.week: 'Week',
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
        holidayStyle: TextStyle().copyWith(color: Colors.blue[800]),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
      ),
      headerStyle: HeaderStyle(
        centerHeaderTitle: true,
        formatButtonTextStyle:
        TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.deepOrange[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color: Colors.deepOrange[300],
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            color: Colors.amber[400],
            width: 100,
            height: 100,
            child: Text(
              '${date.day}',
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }

          if (holidays.isNotEmpty) {
            children.add(
              Positioned(
                right: -2,
                top: -2,
                child: _buildHolidaysMarker(),
              ),
            );
          }

          return children;
        },
      ),
      onDaySelected: (date, events, holidays) {
        _onDaySelected(date, events, holidays);
        _animationController.forward(from: 0.0);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
            ? Colors.brown[500]
            : _calendarController.isToday(date)
            ? Colors.brown[300]
            : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  Widget _buildButtons() {
    return Column(
      children: <Widget>[
        SizedBox(height: 8.0),
      ],
    );
  }

  Widget _buildEventsListButton(Icon _icon, VoidCallback _onPressed) {
    return ButtonTheme(
      minWidth: 20.0,
      height: 20.0,
      child: IconButton(
        padding: EdgeInsets.only(right: 20.0),
        icon: _icon,
        onPressed: _onPressed,
      ),
    );
  }

  _createNewScheduleDialog(BuildContext context) {
    TextEditingController scheduleNameController = TextEditingController();
    TextEditingController scheduleDescriptionController =
    TextEditingController();
    bool _isAllDaySchedule = false;
    var _selectedTypeValue = 'Study';

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Dialog(
                  backgroundColor: Colors.white,
                  insetPadding: EdgeInsets.all(10),
                  child: Stack(
                    overflow: Overflow.visible,
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListView(
                          children: <Widget>[
                            Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text("Name"),
                                  SizedBox(
                                    width: 300,
                                    height: 30,
                                    child: TextField(
                                      controller: scheduleNameController,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ]),
                            Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  Text("Description"),
                                  SizedBox(
                                    width: 300,
                                    height: 30,
                                    child: TextField(
                                      controller: scheduleDescriptionController,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                ]),
                            Row(
                              children: <Widget>[
                                Checkbox(
                                    value: _isAllDaySchedule,
                                    onChanged: (value) {
                                      setState(() {
                                        _isAllDaySchedule = !_isAllDaySchedule;
                                        print(
                                            'checkbox clicked $_isAllDaySchedule');
                                      });
                                    }),
                                Text(
                                  'All-Day Schedule',
                                  style: TextStyle(fontSize: 10.0),
                                ),
                                DropdownButton(
                                  value: _selectedTypeValue,
                                  items: eventTypes.map((value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedTypeValue = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                _buildEventsListButton(Icon(Icons.check), () {
                                  setState(() {
                                    if (scheduleDescriptionController.text ==
                                        '')
                                      scheduleDescriptionController.text =
                                      'No Description';
                                    _events[_selectedDay] =
                                        _events[_selectedDay] ?? [];
                                    _events[_selectedDay].add(SingleEvent(
                                      name: scheduleNameController.text,
                                      description:
                                      scheduleDescriptionController.text,
                                      isallday: _isAllDaySchedule,
                                      type: _selectedTypeValue,
                                    ));
                                  });
                                  Navigator.of(context).pop();
                                }),
                                _buildEventsListButton(Icon(Icons.clear), () {
                                  Navigator.of(context).pop();
                                }),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              });
        });
  }

  Widget _buildEventList() {
    return Builder(builder: (context) {
      return Opacity(
        opacity: _listViewOpacity,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: Colors.white24,
            border: Border(top: BorderSide(color: Colors.grey)),
          ),
          child: ListView(shrinkWrap: true, children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
              _buildEventsListButton(Icon(Icons.add), () {
                setState(() {
                  print('CALLBACK: add icon on pressed');
                  _createNewScheduleDialog(context);
                });
              }),
              _buildEventsListButton(Icon(Icons.clear), () {
                setState(() {
                  print('CALLBACK: clear icon on pressed');
                  _listViewOpacity = 0.0;
                  _calendarController.setCalendarFormat(CalendarFormat.month);
                });
              }),
            ]),
            SizedBox(
              height: 20.0,
            ),
            ListView(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              children: _selectedEvents.map((event) {

                Icon _eventIcon = Icon(Icons.schedule);

                if (event.type == 'Study') {
                  _eventIcon = Icon(Icons.menu_book_outlined);
                }

                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey),
                    ),
                    //borderRadius: BorderRadius.circular(12.0),
                  ),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    leading: _eventIcon,
                    title: Text(event.name),
                    subtitle: Text(event.description ?? 'No Description'),
                    onTap: () => print('$event tapped!'),
                  ),
                );
              }).toList(),
            ),
          ]),
        ),
      );
    });
  }
}
