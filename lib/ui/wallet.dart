import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  bool _showAmounts = true;
  List<Map<String, String>> wallets = [];

  @override
  void initState() {
    super.initState();
    _loadWallets();
  }

  Future<void> _loadWallets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? walletsJson = prefs.getString('wallets');
    if (walletsJson != null) {
      final List<dynamic> walletsList = jsonDecode(walletsJson);
      setState(() {
        wallets = walletsList
            .map((wallet) => Map<String, String>.from(wallet))
            .toList();
      });
    }
  }

  Future<void> _saveWallets() async {
    final prefs = await SharedPreferences.getInstance();
    final String walletsJson = jsonEncode(wallets);
    await prefs.setString('wallets', walletsJson);
  }

  // Hàm định dạng số tiền với dấu chấm phân cách hàng nghìn
  String _formatBalance(String balance) {
    String number = balance.replaceAll(' đ', '').replaceAll(',', '');
    String formatted = '';
    int length = number.length;
    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        formatted += '.';
      }
      formatted += number[i];
    }
    return '$formatted đ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Ví của tôi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF2D3142),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showAmounts ? Icons.visibility : Icons.visibility_off,
              color: const Color(0xFF2D3142),
            ),
            onPressed: () {
              setState(() {
                _showAmounts = !_showAmounts;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF2D3142)),
            onPressed: () {
              _showAddWalletModal(context);
            },
          ),
        ],
      ),
      body: wallets.isEmpty ? _buildEmptyState() : _buildWalletList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  size: 64,
                  color: Color(0xFF6C63FF),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Chưa có ví nào',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Hãy tạo ví đầu tiên của bạn',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _showAddWalletModal(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tạo ví mới',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: wallets.length,
      itemBuilder: (context, index) {
        return _buildWalletItem(wallets[index], index);
      },
    );
  }

  Widget _buildWalletItem(Map<String, String> wallet, int index) {
    IconData icon = wallet['type'] == 'cash' ? Icons.money : Icons.account_balance;
    String formattedBalance = _formatBalance(wallet['balance'] ?? '0 đ');

    return GestureDetector(
      onTap: () {
        _openWalletDetail(wallet, index);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet['name'] ?? 'Không tên',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _showAmounts ? formattedBalance : '******',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF2D3142)),
          ],
        ),
      ),
    );
  }

  void _showAddWalletModal(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    String walletType = 'cash';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Thêm ví mới', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tên ví',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số dư ban đầu',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: walletType,
                decoration: InputDecoration(
                  labelText: 'Loại ví',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Ví tiền mặt')),
                  DropdownMenuItem(value: 'bank', child: Text('Ví ngân hàng')),
                ],
                onChanged: (value) {
                  walletType = value!;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      wallets.add({
                        'name': nameController.text,
                        'balance': '${balanceController.text} đ',
                        'type': walletType,
                      });
                      _saveWallets();
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Thêm ví', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openWalletDetail(Map<String, String> wallet, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletDetailPage(
          wallet: wallet,
          onDelete: () {
            setState(() {
              wallets.removeAt(index);
              _saveWallets();
            });
            Navigator.pop(context);
          },
          onEdit: (newWallet) {
            setState(() {
              wallets[index] = newWallet;
              _saveWallets();
            });
          },
        ),
      ),
    );
  }
}

class WalletDetailPage extends StatelessWidget {
  final Map<String, String> wallet;
  final VoidCallback onDelete;
  final Function(Map<String, String>) onEdit;

  const WalletDetailPage({
    super.key,
    required this.wallet,
    required this.onDelete,
    required this.onEdit,
  });

  String _formatBalance(String balance) {
    String number = balance.replaceAll(' đ', '').replaceAll(',', '');
    String formatted = '';
    int length = number.length;
    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        formatted += '.';
      }
      formatted += number[i];
    }
    return '$formatted đ';
  }

  @override
  Widget build(BuildContext context) {
    IconData icon = wallet['type'] == 'cash' ? Icons.money : Icons.account_balance;
    String formattedBalance = _formatBalance(wallet['balance'] ?? '0 đ');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(wallet['name'] ?? 'Chi tiết ví'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              _showEditWalletModal(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4A45B1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wallet['name'] ?? 'Không tên',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Số dư: $formattedBalance',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Loại ví: ${wallet['type'] == 'cash' ? 'Tiền mặt' : 'Ngân hàng'}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditWalletModal(BuildContext context) {
    final nameController = TextEditingController(text: wallet['name']);
    final balanceController = TextEditingController(text: wallet['balance']?.replaceAll(' đ', '').replaceAll('.', ''));
    String walletType = wallet['type'] ?? 'cash';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Sửa ví', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tên ví',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số dư',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: walletType,
                decoration: InputDecoration(
                  labelText: 'Loại ví',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Ví tiền mặt')),
                  DropdownMenuItem(value: 'bank', child: Text('Ví ngân hàng')),
                ],
                onChanged: (value) {
                  walletType = value!;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    onEdit({
                      'name': nameController.text,
                      'balance': '${balanceController.text} đ',
                      'type': walletType,
                    });
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cập nhật', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('Wallet'));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
