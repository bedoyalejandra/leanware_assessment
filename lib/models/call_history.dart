class CallHistoryModel {
  String? id;
  bool incoming;
  DateTime date;
  int duration;

  CallHistoryModel({
    required this.incoming,
    required this.date,
    required this.duration,
    this.id,
  });

  factory CallHistoryModel.fromJson(String id, Map<String, dynamic> json) =>
      CallHistoryModel(
        id: id,
        incoming: json["incoming"],
        date: json["date"].toDate(),
        duration: json["duration"],
      );

  Map<String, dynamic> toJson() => {
        "incoming": incoming,
        "date": date,
        "duration": duration,
      };
}
