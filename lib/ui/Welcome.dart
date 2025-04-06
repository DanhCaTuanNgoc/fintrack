import 'package:flutter/material.dart';
import 'dart:math';
import 'Books.dart';
import 'Wallet.dart';
import 'Charts.dart';
import 'More.dart';

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
              GetStartedPage(
                onGetStarted: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                              const MyHomePage(),
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
                onBack: () => _changePage(1),
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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimations = List.generate(
      widget.children.length,
      (index) => Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2, // begin time
            min(1.0, 0.6 + index * 0.2), // end time, không vượt quá 1.0
            curve: Curves.easeOutCubic,
          ),
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
          child: widget.children[index],
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
            'Tất cả đã sẵn sàng.\nHãy bắt đầu trải nghiệm!',
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const Books(),
    const Wallet(),
    const Charts(),
    const More(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Books'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Wallet'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_rounded),
            label: 'Chart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'More'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.deepPurple,
      ),
    );
  }
}
