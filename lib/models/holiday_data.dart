class HolidayData {
  final String month;
  final String day;
  final String name;
  final String type;

  HolidayData({
    required this.month,
    required this.day,
    required this.name,
    required this.type,
  });

  factory HolidayData.fromJson(Map<String, dynamic> json) {
    return HolidayData(
      month: json['month'],
      day: json['day'],
      name: json['name'],
      type: json['type'],
    );
  }
}
