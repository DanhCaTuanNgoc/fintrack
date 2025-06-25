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
  // ID của sổ chi tiêu để lưu giao dịch
  final int? bookId;

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
    this.bookId,
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
    int? bookId,
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
      bookId: bookId ?? this.bookId,
    );
  }

  // Tính toán ngày đến hạn tiếp theo dựa trên tần suất
  DateTime calculateNextDueDate() {
    // Nếu chưa có ngày thanh toán gần nhất, sử dụng ngày bắt đầu
    final baseDate = lastPaidDate ?? startDate;

    switch (frequency) {
      case 'daily':
        // Ngày tiếp theo
        return DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day + 1,
        );
      case 'weekly':
        // Tuần tiếp theo, cùng ngày trong tuần
        return DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day + 7,
        );
      case 'monthly':
        // Tháng tiếp theo, cùng ngày
        int nextMonth = baseDate.month + 1;
        int nextYear = baseDate.year;
        if (nextMonth > 12) {
          nextMonth = 1;
          nextYear++;
        }
        // Đảm bảo ngày hợp lệ (ví dụ: 31/01 -> 28/02 hoặc 29/02)
        int day = baseDate.day;
        while (day > 28) {
          try {
            DateTime(nextYear, nextMonth, day);
            break;
          } catch (e) {
            day--;
          }
        }
        return DateTime(nextYear, nextMonth, day);
      case 'yearly':
        // Năm tiếp theo, cùng ngày tháng
        int nextYear = baseDate.year + 1;
        // Đảm bảo ngày hợp lệ (ví dụ: 29/02/2024 -> 28/02/2025)
        int day = baseDate.day;
        while (day > 28) {
          try {
            DateTime(nextYear, baseDate.month, day);
            break;
          } catch (e) {
            day--;
          }
        }
        return DateTime(nextYear, baseDate.month, day);
      default:
        return baseDate;
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
      'book_id': bookId,
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
      bookId: map['book_id'],
    );
  }
}
