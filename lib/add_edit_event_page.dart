import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_page.dart';

class AddEditEventPage extends StatefulWidget {
  final DateTime selectedDate;
  final CalendarEventData<Object?>? eventToEdit;

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
  String? _locationName;
  LatLng? _locationCoords;

  @override
  void initState() {
    super.initState();
    if (widget.eventToEdit != null) {
      _title = widget.eventToEdit!.title;
      _description = widget.eventToEdit!.description ?? '';
      _date = widget.eventToEdit!.date;
      _startTime = TimeOfDay.fromDateTime(widget.eventToEdit!.startTime!);
      _endTime = TimeOfDay.fromDateTime(widget.eventToEdit!.endTime!);
      if (widget.eventToEdit!.event is Map<String, dynamic>) {
        final Map<String, dynamic> location = widget.eventToEdit!.event as Map<String, dynamic>;
        _locationCoords = LatLng(location['latitude'] as double, location['longitude'] as double);
        _locationName = location['name'] as String;
      }
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
              Row(
                children: [
                  Text(
                    'Selected Date: ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () async {
                      final newDate = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (newDate != null) {
                        setState(() {
                          _date = newDate;
                        });
                      }
                    },
                    child: Text('${_date.toString().split(' ')[0]}'),
                  ),
                ],
              ),

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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Location: ${_locationName ?? 'Not set'}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),

                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MapPage(initialLocation: _locationCoords)),
                      );
                      if (result != null) {
                        setState(() {
                          _locationCoords = result['coords'];
                          _locationName = result['name'];
                        });
                      }
                    },
                    child: Text('Set Location'),
                  ),
                ],
              ),

              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final event = CalendarEventData<Object?>(
                      title: _title,
                      description: _description,
                      date: _date,
                      startTime: DateTime(_date.year, _date.month, _date.day, _startTime.hour, _startTime.minute),
                      endTime: DateTime(_date.year, _date.month, _date.day, _endTime.hour, _endTime.minute),
                      // location: _locationName,
                      // You might need to extend CalendarEventData to include locationCoords
                      event: _locationName != null
                          ? {'latitude': _locationCoords!.latitude, 'longitude': _locationCoords!.longitude, 'name':  _locationName}
                          : null,
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
