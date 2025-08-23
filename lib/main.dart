import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'pages/sleep_timer/sleep_timer_main.dart';
import 'pages/focus_timer.dart';
import 'pages/relax_timer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'time to',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,

      home: const MyHomePage(title: 'time to'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 0: Sleep, 1: Focus, 2: Relax
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // 페이지 리스트
  final List<Widget> _pages = const [
    SleepTimerPage(),
    FocusTimerPage(),
    RelaxTimerPage(),
  ];

  //스크린 전환 함수
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double navBarHeight = 68.0;
    final double navBarHorizontalPadding = 00.0;
    const double navBarInternalHorizontalPadding = 20.0;
    final double iconContainerSize = 44.0;
    final double navBarBottomExtra = 20.0;
    const double extraTop = 20.0;
    final double topPadding = MediaQuery.of(context).padding.top + extraTop;

    return Scaffold(
      backgroundColor: const Color(0xff121212),
      extendBody: true,
      body: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _selectedIndex = index);
          },
          children: _pages,
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: EdgeInsets.only(
            left: navBarHorizontalPadding,
            right: navBarHorizontalPadding,
            bottom: navBarBottomExtra,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: navBarHeight,
              width: MediaQuery.of(context).size.width * 0.86,
              decoration: BoxDecoration(
                color: AppColors.navBar,
                borderRadius: BorderRadius.circular(40.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(80),
                    blurRadius: 20.0,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: navBarInternalHorizontalPadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      svgPath: 'assets/images/icons/sleep',
                      index: 0,
                      selected: _selectedIndex == 0,
                      size: iconContainerSize,
                      onTap: () => _onItemTapped(0),
                      label: '수면',
                    ),
                    _buildNavItem(
                      svgPath: 'assets/images/icons/focus',
                      index: 1,
                      selected: _selectedIndex == 1,
                      size: iconContainerSize,
                      onTap: () => _onItemTapped(1),
                      label: '집중',
                    ),
                    _buildNavItem(
                      svgPath: 'assets/images/icons/relax',
                      index: 2,
                      selected: _selectedIndex == 2,
                      size: iconContainerSize,
                      onTap: () => _onItemTapped(2),
                      label: '명상',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 네비게이션 바 아이템 위젯
  Widget _buildNavItem({
    required String svgPath,
    required int index,
    required bool selected,
    required double size,
    required VoidCallback onTap,
    String? label,
  }) {
    return Expanded(
      child: Semantics(
        label: label ?? 'nav item $index',
        button: true,
        selected: selected,
        child: InkWell(
          borderRadius: BorderRadius.circular(40.0),
          onTap: onTap,
          child: SizedBox(
            height: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: selected
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: SvgPicture.asset(
                    '${svgPath}_disabled.svg',
                    width: size * 0.8,
                    height: size * 0.8,
                  ),
                  secondChild: SvgPicture.asset(
                    '${svgPath}_enabled.svg',
                    width: size * 0.8,
                    height: size * 0.8,
                  ),
                ),
                Positioned(
                  bottom: 6.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 4.0,
                    width: selected ? 30.0 : 0.0,
                    decoration: BoxDecoration(
                      color: const Color(0xff9A9A9A),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
