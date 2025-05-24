class Schedule {
  final int id;
  final String guardId;
  final String name;
  final String day;
  final String startTime;
  final String endTime;
  final DateTime? scheduleDate;

  Schedule({
    required this.id,
    required this.guardId,
    required this.name,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.scheduleDate,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    print('Received schedule_date from API: ${json['schedule_date']}');
    print('Raw schedule data: $json');

    DateTime? parsedDate;
    if (json['schedule_date'] != null) {
      try {
        parsedDate = DateTime.parse(json['schedule_date']);
        print('Successfully parsed date: $parsedDate');
      } catch (e) {
        print('Error parsing date: $e');
      }
    }

    return Schedule(
      id: json['id'],
      guardId: json['guard_id'].toString(),
      name: json['name'],
      day: json['day'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      scheduleDate: parsedDate,
    );
  }
}