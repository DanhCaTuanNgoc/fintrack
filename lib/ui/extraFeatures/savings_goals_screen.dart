import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers_barrel.dart';
import '../../data/models/savings_goal.dart';
import '../widget/widget_barrel.dart';

class SavingsGoalsScreen extends ConsumerStatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  ConsumerState<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends ConsumerState<SavingsGoalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ref.watch(themeColorProvider);
    final savingsGoalsState = ref.watch(savingsGoalsProvider);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: themeColor,
          elevation: 0,
          title: const Text(
            'Mục tiêu tiết kiệm',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Mục tiêu tiết kiệm button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: themeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.savings,
                                color: themeColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tiết kiệm linh hoạt',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Không có kế hoạch, gửi tiền theo tâm trạng của bạn',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: themeColor,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Hóa đơn định kỳ button
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: themeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.calendar_month,
                                color: themeColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tiết kiệm định kỳ',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Gửi tiền theo định kỳ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: themeColor,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildFlexibleSavingsTab(
      Color themeColor, AsyncValue<List<SavingsGoal>> savingsGoalsState) {
    return savingsGoalsState.when(
      data: (goals) {
        final flexibleGoals = goals.where((g) => g.type == 'flexible').toList();

        if (flexibleGoals.isEmpty) {
          return _buildEmptyState(
            themeColor,
            'Tiết kiệm linh hoạt',
            'Không có kế hoạch, gửi theo sở thích',
            Icons.savings,
            () =>
                _showCreateGoalModal(context, themeColor, goalType: 'flexible'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: flexibleGoals.length,
          itemBuilder: (context, index) {
            final goal = flexibleGoals[index];
            return _buildGoalCard(goal, themeColor);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(savingsGoalsProvider),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodicSavingsTab(
      Color themeColor, AsyncValue<List<SavingsGoal>> savingsGoalsState) {
    return savingsGoalsState.when(
      data: (goals) {
        final periodicGoals = goals.where((g) => g.type == 'periodic').toList();

        if (periodicGoals.isEmpty) {
          return _buildEmptyState(
            themeColor,
            'Tiết kiệm định kỳ',
            'Gửi tiền định kỳ theo chu kỳ',
            Icons.schedule,
            () =>
                _showCreateGoalModal(context, themeColor, goalType: 'periodic'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: periodicGoals.length,
          itemBuilder: (context, index) {
            final goal = periodicGoals[index];
            return _buildGoalCard(goal, themeColor);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(savingsGoalsProvider),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    Color themeColor,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onAddPressed,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 64,
                  color: themeColor,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAddPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Tạo mục tiêu mới',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(SavingsGoal goal, Color themeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    goal.type == 'flexible' ? Icons.savings : Icons.schedule,
                    color: themeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (goal.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          goal.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        goal.progressText,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditGoalDialog(context, goal, themeColor);
                    } else if (value == 'add') {
                      _showAddAmountDialog(context, goal, themeColor);
                    } else if (value == 'delete') {
                      _showDeleteGoalDialog(context, goal);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'add',
                      child: Row(
                        children: [
                          Icon(Icons.add, size: 20),
                          SizedBox(width: 8),
                          Text('Thêm tiền'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Chỉnh sửa'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xóa', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Progress bar
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              value: goal.progressPercentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                goal.isCompleted ? Colors.green : themeColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showCreateGoalModal(BuildContext context, Color themeColor,
      {String? goalType}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateSavingsGoalModal(
        themeColor: themeColor,
        initialGoalType: goalType,
      ),
    );
  }

  void _showEditGoalDialog(
      BuildContext context, SavingsGoal goal, Color themeColor) {
    final TextEditingController nameController =
        TextEditingController(text: goal.name);
    final TextEditingController descriptionController =
        TextEditingController(text: goal.description);
    final TextEditingController targetAmountController =
        TextEditingController(text: goal.targetAmount.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chỉnh sửa mục tiêu'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên mục tiêu',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: targetAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Số tiền mục tiêu',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = nameController.text.trim();
                final newDescription = descriptionController.text.trim();
                final newTargetAmount =
                    double.tryParse(targetAmountController.text);

                if (newName.isNotEmpty &&
                    newTargetAmount != null &&
                    newTargetAmount > 0) {
                  final updatedGoal = goal.copyWith(
                    name: newName,
                    description: newDescription,
                    targetAmount: newTargetAmount,
                  );
                  ref
                      .read(savingsGoalsProvider.notifier)
                      .updateSavingsGoal(updatedGoal);
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cập nhật thành công'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: themeColor),
              child: const Text('Lưu', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAddAmountDialog(
      BuildContext context, SavingsGoal goal, Color themeColor) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thêm tiền vào mục tiêu'),
          content: TextField(
            controller: amountController,
            decoration: const InputDecoration(
              labelText: 'Số tiền',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  ref
                      .read(savingsGoalsProvider.notifier)
                      .addAmountToGoal(goal.id!, amount);
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Đã thêm ${amount.toStringAsFixed(0)} vào mục tiêu'),
                      backgroundColor: const Color(0xFF4CAF50),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: themeColor),
              child: const Text('Thêm', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteGoalDialog(BuildContext context, SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa mục tiêu'),
          content: Text('Bạn có chắc chắn muốn xóa mục tiêu "${goal.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await ref
                    .read(savingsGoalsProvider.notifier)
                    .deleteSavingsGoal(goal);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Xóa thành công'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xóa', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
