// Model đại diện cho hóa đơn định kỳ
class PeriodicInvoice {
  // ID duy nhất của hóa đơn
  final String id;
  // Tên hóa đơn
  final String name;
  // Số tiền cần thanh toán
  final double amount;
  // Ngày bắt đầu tính hóa đơn
  final DateTime startDate;
  // Tần suất thanh toán (daily, weekly, monthly, yearly)
  final String frequency;
  // Danh mục chi tiêu
  final String category;
  // Mô tả thêm về hóa đơn
  final String description;
  // Trạng thái đã thanh toán hay chưa
  final bool isPaid;
  // Ngày thanh toán gần nhất
  final DateTime? lastPaidDate;
  // Ngày đến hạn tiếp theo
  final DateTime? nextDueDate;

  // Constructor với các tham số bắt buộc và tùy chọn
  PeriodicInvoice({
    required this.id,
    required this.name,
    required this.amount,
    required this.startDate,
    required this.frequency,
    required this.category,
    required this.description,
    this.isPaid = false,
    this.lastPaidDate,
    this.nextDueDate,
  });

  // Phương thức tạo bản sao với các thuộc tính có thể thay đổi
  PeriodicInvoice copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? startDate,
    String? frequency,
    String? category,
    String? description,
    bool? isPaid,
    DateTime? lastPaidDate,
    DateTime? nextDueDate,
  }) {
    return PeriodicInvoice(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      frequency: frequency ?? this.frequency,
      category: category ?? this.category,
      description: description ?? this.description,
      isPaid: isPaid ?? this.isPaid,
      lastPaidDate: lastPaidDate ?? this.lastPaidDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
    );
  }

  // Tính toán ngày đến hạn tiếp theo dựa trên tần suất
  DateTime calculateNextDueDate() {
    final now = DateTime.now();
    if (lastPaidDate == null) {
      return startDate;
    }

    switch (frequency) {
      case 'daily':
        // Ngày tiếp theo, bắt đầu từ 00:00
        return DateTime(
          lastPaidDate!.year,
          lastPaidDate!.month,
          lastPaidDate!.day + 1,
        );
      case 'weekly':
        // Tuần tiếp theo, bắt đầu từ thứ 2
        final daysUntilMonday = (8 - lastPaidDate!.weekday) % 7;
        return DateTime(
          lastPaidDate!.year,
          lastPaidDate!.month,
          lastPaidDate!.day + daysUntilMonday,
        );
      case 'monthly':
        // Tháng tiếp theo, ngày 1
        return DateTime(
          lastPaidDate!.year,
          lastPaidDate!.month + 1,
          1,
        );
      case 'yearly':
        // Năm tiếp theo, ngày 1 tháng 1
        return DateTime(
          lastPaidDate!.year + 1,
          1,
          1,
        );
      default:
        return lastPaidDate!;
    }
  }

  // Kiểm tra xem hóa đơn có quá hạn không
  bool isOverdue() {
    if (isPaid) return false;
    final nextDue = nextDueDate ?? calculateNextDueDate();
    final now = DateTime.now();

    // So sánh chỉ ngày, tháng, năm
    return now.year > nextDue.year ||
        (now.year == nextDue.year && now.month > nextDue.month) ||
        (now.year == nextDue.year &&
            now.month == nextDue.month &&
            now.day > nextDue.day);
  }

  // Kiểm tra hóa đơn sắp đến hạn (ví dụ trước 2 ngày)
  bool isAlmostDue({int daysBefore = 2}) {
    if (isPaid) return false;
    final nextDue = nextDueDate ?? calculateNextDueDate();
    final now = DateTime.now();
    final diff =
        nextDue.difference(DateTime(now.year, now.month, now.day)).inDays;
    return diff > 0 && diff <= daysBefore;
  }

  // Chuyển đổi đối tượng thành Map để lưu vào database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'start_date': startDate.toIso8601String(),
      'frequency': frequency,
      'category': category,
      'description': description,
      'is_paid': isPaid ? 1 : 0,
      'last_paid_date': lastPaidDate?.toIso8601String(),
      'next_due_date': nextDueDate?.toIso8601String(),
    };
  }

  // Tạo đối tượng từ Map lấy ra từ database
  factory PeriodicInvoice.fromMap(Map<String, dynamic> map) {
    return PeriodicInvoice(
      id: map['id'],
      name: map['name'],
      amount: map['amount'],
      startDate: DateTime.parse(map['start_date']),
      frequency: map['frequency'],
      category: map['category'],
      description: map['description'],
      isPaid: map['is_paid'] == 1,
      lastPaidDate: map['last_paid_date'] != null
          ? DateTime.tryParse(map['last_paid_date'])
          : null,
      nextDueDate: map['next_due_date'] != null
          ? DateTime.tryParse(map['next_due_date'])
          : null,
    );
  }
}
