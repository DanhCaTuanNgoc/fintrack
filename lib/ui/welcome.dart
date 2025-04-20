import 'package:flutter/material.dart';
import 'dart:math';
import 'home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/book.dart';
import '../data/database/database_helper.dart';
import '../data/repositories/book_repository.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const ClampingScrollPhysics(),
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              WelcomePage(onNext: () => _changePage(1)),
              TermsPage(
                onNext: () => _changePage(2),
                onBack: () => _changePage(0),
              ),
              CreateBookPage(
                onNext: () => _changePage(3),
                onBack: () => _changePage(1),
              ),
              CreateWalletPage(
                onNext: () => _changePage(4),
                onBack: () => _changePage(2),
              ),
              GetStartedPage(
                onGetStarted: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                              const HomePage(),
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 500),
                    ),
                  );
                },
                onBack: () => _changePage(3),
              ),
            ],
          ),
          // Thêm indicators để hiển thị vị trí trang
          // Positioned(
          //   bottom: 20.0,
          //   left: 0,
          //   right: 0,
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: List.generate(
          //       3,
          //       (index) => Container(
          //         margin: const EdgeInsets.symmetric(horizontal: 4.0),
          //         width: 8.0,
          //         height: 8.0,
          //         decoration: BoxDecoration(
          //           shape: BoxShape.circle,
          //           color:
          //               _currentPage == index
          //                   ? Theme.of(context).primaryColor
          //                   : Colors.grey.withOpacity(0.5),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  void _changePage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

class SlidePageContent extends StatefulWidget {
  final List<Widget> children;
  final bool animate;

  const SlidePageContent({
    super.key,
    required this.children,
    this.animate = true,
  });

  @override
  State<SlidePageContent> createState() => _SlidePageContentState();
}

class _SlidePageContentState extends State<SlidePageContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimations = List.generate(
      widget.children.length,
      (index) => Tween<Offset>(
        begin: const Offset(0.0, 0.2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(0.0, 1.0, curve: Curves.easeOut),
        ),
      ),
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.children.length,
        (index) => SlideTransition(
          position: _slideAnimations[index],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: widget.children[index],
          ),
        ),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  final VoidCallback onNext;

  const WelcomePage({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 350, left: 20, right: 20, bottom: 50),
      child: Column(
        children: [
          // SlidePageContent chỉ chứa các widget cần hiệu ứng
          SlidePageContent(
            children: [
              const Text(
                'Chào mừng đến với Fintrack',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Khám phá ứng dụng của chúng tôi',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
            ],
          ),

          const Spacer(), // đẩy nút xuống dưới
          // Nút ở dưới cùng
          SizedBox(
            width: double.infinity, // Chiều rộng tối đa
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ), // Tăng chiều cao nếu cần// tuỳ chỉnh màu
              ),
              child: const Text('Tiếp tục'),
            ),
          ),
        ],
      ),
    );
  }
}

class TermsPage extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const TermsPage({super.key, required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SlidePageContent(
        children: [
          const Text(
            'Điều khoản sử dụng',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Expanded(
            child: SingleChildScrollView(
              child: Text(
                'Điều khoản và điều kiện sử dụng...\n'
                '1. Quyền và trách nhiệm\n'
                '2. Bảo mật thông tin\n'
                '3. Quy định sử dụng\n',
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: onBack, child: const Text('Quay lại')),
              ElevatedButton(
                onPressed: onNext,
                child: const Text('Tôi đồng ý'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GetStartedPage extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onBack;

  const GetStartedPage({
    super.key,
    required this.onGetStarted,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SlidePageContent(
        children: [
          const Text(
            'Bắt đầu!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            'Chào mừng đến với Fintrack.\nHãy bắt đầu trải nghiệm!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: onBack, child: const Text('Quay lại')),
              ElevatedButton(
                onPressed: onGetStarted,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                child: const Text('Hãy bắt đầu'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CreateBookPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const CreateBookPage({super.key, required this.onNext, required this.onBack});

  @override
  State<CreateBookPage> createState() => _CreateBookPageState();
}

class _CreateBookPageState extends State<CreateBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _bookNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late final BookRepository _bookRepository;

  @override
  void initState() {
    super.initState();
    _bookRepository = BookRepository(_dbHelper);
  }

  @override
  void dispose() {
    _bookNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: SlidePageContent(
          children: [
            const Text(
              'Tạo sổ chi tiêu',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _bookNameController,
              decoration: InputDecoration(
                labelText: 'Tên sổ chi tiêu',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.book),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên sổ chi tiêu';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: widget.onBack,
                  child: const Text('Quay lại'),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        // Skip creating book
                        widget.onNext();
                      },
                      child: const Text('Bỏ qua'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            final book = Book(
                              name: _bookNameController.text,
                              balance: 0.0,
                              userId: 1, // TODO: Get current user ID
                            );

                            await _bookRepository.createBook(book);
                            widget.onNext();
                          } catch (e) {
                            // TODO: Show error message
                            print('Error creating book: $e');
                          }
                        }
                      },
                      child: const Text('Tiếp tục'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CreateWalletPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const CreateWalletPage({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<CreateWalletPage> createState() => _CreateWalletPageState();
}

class _CreateWalletPageState extends State<CreateWalletPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _selectedCurrency = 'VND';

  @override
  void dispose() {
    _accountNameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: SlidePageContent(
            children: [
              const Text(
                'Tạo ví',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _accountNameController,
                decoration: InputDecoration(
                  labelText: 'Tên tài khoản',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên tài khoản';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _balanceController,
                decoration: InputDecoration(
                  labelText: 'Số dư ban đầu',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số dư';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Vui lòng nhập số hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: InputDecoration(
                  labelText: 'Loại tiền tệ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.currency_exchange),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'VND',
                    child: Text('VND - Việt Nam Đồng'),
                  ),
                  DropdownMenuItem(value: 'USD', child: Text('USD - Đô la Mỹ')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: widget.onBack,
                    child: const Text('Quay lại'),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          // Skip creating wallet
                          widget.onNext();
                        },
                        child: const Text('Bỏ qua'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // TODO: Save wallet information
                            widget.onNext();
                          }
                        },
                        child: const Text('Tiếp tục'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
