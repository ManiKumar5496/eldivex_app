// class SupportTicket {
//   final String ticketId;
//   final String title;
//   final String category;
//   final String userName;
//   final String status; // Open, In Progress, Resolved
//   final String priority; // Low, Medium, High, Urgent
//   final DateTime createdAt;
//
//   SupportTicket({
//     required this.ticketId,
//     required this.title,
//     required this.category,
//     required this.userName,
//     required this.status,
//     required this.priority,
//     required this.createdAt,
//   });
//
//   factory SupportTicket.fromJson(Map<String, dynamic> json) {
//     return SupportTicket(
//       ticketId: json['ticket_id'] ?? '',
//       title: json['title'] ?? '',
//       category: json['category'] ?? '',
//       userName: json['user_name'] ?? '',
//       status: json['status'] ?? '',
//       priority: json['priority'] ?? '',
//       createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
//     );
//   }
// }
