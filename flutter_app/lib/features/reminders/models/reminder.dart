class Reminder {
  final String id;
  final String financialRecordId;
  final int daysBefore;
  final bool notificationEnabled;
  final bool alarmEnabled;
  final bool voiceEnabled;

  Reminder({
    required this.id,
    required this.financialRecordId,
    required this.daysBefore,
    required this.notificationEnabled,
    required this.alarmEnabled,
    required this.voiceEnabled,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      financialRecordId: json['financial_record_id'],
      daysBefore: json['days_before'],
      notificationEnabled: json['notification_enabled'],
      alarmEnabled: json['alarm_enabled'],
      voiceEnabled: json['voice_enabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'days_before': daysBefore,
      'notification_enabled': notificationEnabled,
      'alarm_enabled': alarmEnabled,
      'voice_enabled': voiceEnabled,
    };
  }
}
