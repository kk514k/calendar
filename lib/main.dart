import 'package:calendar/tips.dart';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'add_edit_event_page.dart';
import 'about_us_page.dart';
import 'notification_service.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'map_page.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init(); // Initialize notification service
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController()..addAll(_events),
      child: MaterialApp(
        title: 'Flutter Calendar App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: LandingPage(),
      ),
    );
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/calendar_background.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Welcome to Your Calendar',
                    textStyle: const TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                totalRepeatCount: 1,
                onFinished: () {
                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scheduleNotifications(); // Schedule notifications for existing events
  }

  void _scheduleNotifications() {
    for (var event in _events) {
      _scheduleNotificationForEvent(event);
    }
  }

  void _scheduleNotificationForEvent(CalendarEventData event) {
    if (event.startTime != null) {
      _notificationService.showNotification(
        event.hashCode,
        'Upcoming Event: ${event.title}',
        'You have an event "${event.title}" scheduled for tomorrow at ${_formatTime(event.startTime!)}.',
        event.startTime!,
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar App'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Month'),
            Tab(text: 'Week'),
            Tab(text: 'Day'),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Calendar'),
              onTap: () {
                Navigator.pop(context);  // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About Us'),
              onTap: () {
                Navigator.pop(context);  // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutUsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.question_answer),
              title: Text('Tips'),
              onTap: () {
                Navigator.pop(context);  // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Tips()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.question_answer),
              title: Text('Maps'),
              onTap: () {
                Navigator.pop(context);  // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MapPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MonthView(
            onEventTap: (event, date) => _showEventDetails(context, [event]),
          ),
          WeekView(
            onEventTap: (events, date) => _showEventDetails(context, events),
          ),
          DayView(
            onEventTap: (events, date) => _showEventDetails(context, events),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditEventPage(context, DateTime.now()),
        child: Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddEditEventPage(BuildContext context, DateTime selectedDate, {CalendarEventData? eventToEdit}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditEventPage(selectedDate: selectedDate, eventToEdit: eventToEdit),
      ),
    ).then((newEvent) {
      if (newEvent != null) {
        setState(() {});
        if (eventToEdit != null) {
          // Cancel the old notification
          _notificationService.cancelNotification(eventToEdit.hashCode);
        }
        // Schedule notification for the new or updated event
        _scheduleNotificationForEvent(newEvent);
      }
    });
  }

  void _showEventDetails(
      BuildContext context, List<CalendarEventData<Object?>> events) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Event Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: events
              .map((event) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(event.description ?? 'No description'),
                      Text(_formatEventTime(event)),
                      Divider(),
                    ],
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToAddEditEventPage(context, events[0].date, eventToEdit: events[0]);
            },
            child: Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              CalendarControllerProvider.of(context).controller.remove(events[0]);
              _notificationService.cancelNotification(events[0].hashCode); // Cancel notification when deleting event
              Navigator.of(context).pop();
              setState(() {});  // Refresh the page after deleting
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatEventTime(CalendarEventData event) {
    if (event.startTime != null && event.endTime != null) {
      return '${_formatTimeOfDay(TimeOfDay.fromDateTime(event.startTime!))} - '
          '${_formatTimeOfDay(TimeOfDay.fromDateTime(event.endTime!))}';
    } else if (event.startTime != null) {
      return 'Starts at ${_formatTimeOfDay(TimeOfDay.fromDateTime(event.startTime!))}';
    } else if (event.endTime != null) {
      return 'Ends at ${_formatTimeOfDay(TimeOfDay.fromDateTime(event.endTime!))}';
    } else {
      return 'All-day event';
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

List<CalendarEventData> _events = [
  CalendarEventData(
    date: DateTime.now(),
    title: "Project meeting",
    description: "Discuss project milestones and assign tasks.",
    startTime: DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 18, 30),
    endTime: DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day, 22),
  ),
  CalendarEventData(
    date: DateTime.now().add(Duration(days: 1)),
    title: "Team Lunch",
    description: "Monthly team bonding lunch at the nearby restaurant.",
    startTime: DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day + 1, 12, 0),
    endTime: DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day + 1, 13, 30),
  ),
  // Add more sample events as needed
];
