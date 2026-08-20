class SyncRecord {
  final String id;
  final Map<String, dynamic> data;
  final DateTime updatedAt;
  final bool isSynced;
  final bool isDeleted; // 👈 naya field

  SyncRecord({
    required this.id,
    required this.data,
    required this.updatedAt,
    this.isSynced = true,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'data': data,
    'updatedAt': updatedAt.toIso8601String(),
    'isSynced': isSynced,
    'isDeleted': isDeleted,
  };

  factory SyncRecord.fromMap(Map<String, dynamic> map) => SyncRecord(
    id: map['id'],
    data: Map<String, dynamic>.from(map['data']),
    updatedAt: DateTime.parse(map['updatedAt']),
    isSynced: map['isSynced'] ?? true,
    isDeleted: map['isDeleted'] ?? false,
  );
}
