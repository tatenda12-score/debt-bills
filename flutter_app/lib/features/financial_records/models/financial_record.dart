enum Direction {
  owedToMe('OWED_TO_ME'),
  iOwe('I_OWE');

  final String value;
  const Direction(this.value);

  factory Direction.fromJson(String json) {
    return values.firstWhere((e) => e.value == json, orElse: () => Direction.owedToMe);
  }
}

enum Status {
  pending('PENDING'),
  paid('PAID'),
  cancelled('CANCELLED'),
  overdue('OVERDUE');

  final String value;
  const Status(this.value);

  factory Status.fromJson(String json) {
    return values.firstWhere((e) => e.value == json, orElse: () => Status.pending);
  }
}

enum Category {
  rent('RENT'),
  schoolFees('SCHOOL_FEES'),
  salary('SALARY'),
  loan('LOAN'),
  maintenance('MAINTENANCE'),
  utilities('UTILITIES'),
  subscription('SUBSCRIPTION'),
  personal('PERSONAL'),
  business('BUSINESS'),
  other('OTHER');

  final String value;
  const Category(this.value);

  factory Category.fromJson(String json) {
    return values.firstWhere((e) => e.value == json, orElse: () => Category.other);
  }
}

enum RecurrenceType {
  none('NONE'),
  daily('DAILY'),
  weekly('WEEKLY'),
  monthly('MONTHLY'),
  yearly('YEARLY'),
  custom('CUSTOM');

  final String value;
  const RecurrenceType(this.value);

  factory RecurrenceType.fromJson(String json) {
    return values.firstWhere((e) => e.value == json, orElse: () => RecurrenceType.none);
  }
}

class FinancialRecord {
  final String id;
  final Direction direction;
  final String title;
  final String? description;
  final String? personOrOrganization;
  final double amount;
  final String currency;
  final Category category;
  final DateTime? dueDate;
  final Status status;
  final RecurrenceType recurrenceType;
  final String? recurrenceInterval;

  FinancialRecord({
    required this.id,
    required this.direction,
    required this.title,
    this.description,
    this.personOrOrganization,
    required this.amount,
    required this.currency,
    required this.category,
    this.dueDate,
    required this.status,
    required this.recurrenceType,
    this.recurrenceInterval,
  });

  factory FinancialRecord.fromJson(Map<String, dynamic> json) {
    return FinancialRecord(
      id: json['id'],
      direction: Direction.fromJson(json['direction']),
      title: json['title'],
      description: json['description'],
      personOrOrganization: json['person_or_organization'],
      amount: double.parse(json['amount'].toString()),
      currency: json['currency'],
      category: Category.fromJson(json['category']),
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      status: Status.fromJson(json['status']),
      recurrenceType: RecurrenceType.fromJson(json['recurrence_type']),
      recurrenceInterval: json['recurrence_interval'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'direction': direction.value,
      'title': title,
      'description': description,
      'person_or_organization': personOrOrganization,
      'amount': amount,
      'currency': currency,
      'category': category.value,
      'due_date': dueDate?.toIso8601String().split('T')[0],
      'status': status.value,
      'recurrence_type': recurrenceType.value,
      'recurrence_interval': recurrenceInterval,
    };
  }
}
