// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../providers/savings_goal_provider.dart';
// import '../../../data/models/savings_goal.dart';

// class PeriodicSavingScreen extends ConsumerWidget {
//   final SavingsGoal goal;
//   const PeriodicSavingScreen({super.key, required this.goal});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final provider = ref.watch(savingsGoalsProvider.notifier);
//     final currentPeriod = _getCurrentPeriod();
//     // final hasPaid = goal.periodicAmount?.contains(currentPeriod) ?? false;
//     final hasPaid = '';

//     return Scaffold(
//       appBar: AppBar(title: Text(goal.name)),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Mục tiêu: ${goal.targetAmount}'),
//             Text('Đã tiết kiệm: ${goal.currentAmount}'),
//             Text('Kỳ hiện tại: $currentPeriod'),
//             Text('Mô tả: ${goal.description ?? ""}'),
//             const SizedBox(height: 24),
//             hasPaid
//                 ? const Text('Đã nộp kỳ này',
//                     style: TextStyle(color: Colors.green))
//                 : ElevatedButton(
//                     onPressed: () async {
//                       final amount = await showDialog<double>(
//                         context: context,
//                         builder: (context) => _AddAmountDialog(),
//                       );
//                       if (amount != null && amount > 0) {
//                         provider.addAmountToGoal(goal.id!, amount);
//                         provider.markPeriodAsPaid(goal.id!, currentPeriod);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                               content: Text(
//                                   'Đã nộp $amount cho kỳ $currentPeriod!')),
//                         );
//                       }
//                     },
//                     child: const Text('Nộp kỳ này'),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _AddAmountDialog extends StatefulWidget {
//   @override
//   State<_AddAmountDialog> createState() => _AddAmountDialogState();
// }

// class _AddAmountDialogState extends State<_AddAmountDialog> {
//   final _controller = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Nhập số tiền muốn nộp'),
//       content: TextField(
//         controller: _controller,
//         keyboardType: TextInputType.number,
//         decoration: const InputDecoration(hintText: 'Số tiền'),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Hủy'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             final value = double.tryParse(_controller.text);
//             Navigator.pop(context, value);
//           },
//           child: const Text('Xác nhận'),
//         ),
//       ],
//     );
//   }
// }

// String _getCurrentPeriod() {
//   final now = DateTime.now();
//   return '${now.month}/${now.year}';
// }
