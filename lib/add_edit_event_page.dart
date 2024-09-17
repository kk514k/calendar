import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';

class AddEditEventPage extends StatefulWidget {
  final DateTime selectedDate;
  final CalendarEventData? eventToEdit;

  AddEditEventPage({Key? key, required this.selectedDate, this.eventToEdit}) : super(key: key);

  @override
  _AddEditEventPageState createState() => _AddEditEventPageState();
}

class _AddEditEventPageState extends State<AddEditEventPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime _date;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    if (widget.eventToEdit != null) {
      _title = widget.eventToEdit!.title;
      _description = widget.eventToEdit!.description ?? '';
      _date = widget.eventToEdit!.date;
      _startTime = TimeOfDay.fromDateTime(widget.eventToEdit!.startTime!);
      _endTime = TimeOfDay.fromDateTime(widget.eventToEdit!.endTime!);
    } else {
      _date = widget.selectedDate;
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventToEdit != null ? 'Edit Event' : 'Add Event'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selected Date: ${_date.toString().split(' ')[0]}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: widget.eventToEdit?.title ?? '',
                decoration: InputDecoration(labelText: 'Event Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                initialValue: widget.eventToEdit?.description ?? '',
                decoration: InputDecoration(labelText: 'Description/Note'),
                maxLines: 3,
                onSaved: (value) => _description = value ?? '',
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _startTime,
                      );
                      if (time != null) {
                        setState(() => _startTime = time);
                      }
                    },
                    child: Text('Start Time: ${_startTime.format(context)}'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _endTime,
                      );
                      if (time != null) {
                        setState(() => _endTime = time);
                      }
                    },
                    child: Text('End Time: ${_endTime.format(context)}'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final event = CalendarEventData(
                      title: _title,
                      description: _description,
                      date: _date,
                      startTime: DateTime(_date.year, _date.month, _date.day, _startTime.hour, _startTime.minute),
                      endTime: DateTime(_date.year, _date.month, _date.day, _endTime.hour, _endTime.minute),
                    );

                    if (widget.eventToEdit != null) {
                      // Update existing event
                      CalendarControllerProvider.of(context).controller.update(widget.eventToEdit!, event);
                    } else {
                      // Add new event
                      CalendarControllerProvider.of(context).controller.add(event);
                    }

                    Navigator.of(context).pop(event); // Return the event
                  }
                },
                child: Text(widget.eventToEdit != null ? 'Update Event' : 'Add Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}