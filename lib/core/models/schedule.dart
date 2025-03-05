class Schedule {
  final int id;
  final String guardId;
  final String name;
  final String day;
  final String startTime;
  final String endTime;

  Schedule({
    required this.id,
    required this.guardId,
    required this.name,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      guardId: json['guard_id'].toString(),
      name: json['name'],
      day: json['day'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}