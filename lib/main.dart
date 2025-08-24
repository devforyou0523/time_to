// main.dart (optimized)
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'pages/sleep_timer/sleep_timer_main.dart';
import 'pages/focus_timer.dart';
import 'pages/relax_timer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const PrecacheAndHome(),
    );
  }
}

class PrecacheAndHome extends StatefulWidget {
  const PrecacheAndHome({super.key});

  @override
  State<PrecacheAndHome> createState() => _PrecacheAndHomeState();
}

class _PrecacheAndHomeState extends State<PrecacheAndHome> {
  bool _ready = false;

  // svg 파일 캐싱
  final List<String> _svgAssets = [
    // icon 파일 경로
    'assets/images/icons/focus_enabled.svg',
    'assets/images/icons/focus_disabled.svg',
    'assets/images/icons/relax_enabled.svg',
    'assets/images/icons/relax_disabled.svg',
    'assets/images/icons/sleep_enabled.svg',
    'assets/images/icons/sleep_disabled.svg',
    'assets/images/icons/arrow_1.svg',
    'assets/images/icons/hold.svg',
    'assets/images/icons/end.svg',
    'assets/images/icons/info.svg',
    'assets/images/icons/frown.svg',
    'assets/images/icons/meh.svg',
    'assets/images/icons/smile.svg',
    'assets/images/icons/pause_button.svg',
    'assets/images/icons/skip_button.svg',
    'assets/images/icons/stop_button.svg',
    // image 파일 경로
    'assets/images/focus.svg',
    'assets/images/heart.svg',
    'assets/images/moon.svg',
    'assets/images/rest.svg',
  ];

  @override
  void initState() {
    super.initState();
    // 한 프레임 렌더 후, 잠깐 대기하면 SvgPicture가 내부적으로 파싱/캐시됨
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 복잡한 SVG가 많으면 delay를 좀 늘리세요
      await Future.delayed(const Duration(milliseconds: 120));
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return const MyHomePage(title: 'time to');
    return Scaffold(
      backgroundColor: const Color(0xff121212),
      body: Stack(
        children: [
          const Center(child: CircularProgressIndicator()),
          Offstage(
            offstage: false,
            child: Column(
              children: _svgAssets.map((p) {
                return SizedBox(
                  width: 1,
                  height: 1,
                  child: SvgPicture.asset(p),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class KeepAlivePage extends StatefulWidget {
  final Widget child;
  const KeepAlivePage({required this.child, super.key});

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// 메인 홈 화면: IndexedStack + 분리된 BottomNav 사용
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    KeepAlivePage(child: SleepTimerPage()),
    KeepAlivePage(child: FocusTimerPage()),
    KeepAlivePage(child: RelaxTimerPage()),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final double navBarHeight = 68.0;
    final double navBarHorizontalPadding = 0.0;
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
        // IndexedStack는 자식들을 메모리에 유지하므로 상태 보존에 유리
        child: IndexedStack(index: _selectedIndex, children: _pages),
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
            child: RepaintBoundary(
              // RepaintBoundary로 페인트 범위 격리
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
                      _NavItem(
                        svgPath: 'assets/images/icons/sleep',
                        index: 0,
                        selected: _selectedIndex == 0,
                        size: iconContainerSize,
                        onTap: () => _onItemTapped(0),
                        label: '수면',
                      ),
                      _NavItem(
                        svgPath: 'assets/images/icons/focus',
                        index: 1,
                        selected: _selectedIndex == 1,
                        size: iconContainerSize,
                        onTap: () => _onItemTapped(1),
                        label: '집중',
                      ),
                      _NavItem(
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
      ),
    );
  }
}

/// 네비 아이템: 두 아이콘을 유지하면서 AnimatedOpacity로 전환
class _NavItem extends StatelessWidget {
  final String svgPath;
  final int index;
  final bool selected;
  final double size;
  final VoidCallback onTap;
  final String? label;

  const _NavItem({
    required this.svgPath,
    required this.index,
    required this.selected,
    required this.size,
    required this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    // 미리 SvgPicture 위젯을 만들어 재사용(불필요한 파싱/빌드 방지)
    final disabled = SvgPicture.asset(
      '${svgPath}_disabled.svg',
      width: size * 0.8,
      height: size * 0.8,
    );
    final enabled = SvgPicture.asset(
      '${svgPath}_enabled.svg',
      width: size * 0.8,
      height: size * 0.8,
    );

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
                // disabled icon (숨김/보임만 조절)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: selected ? 0.0 : 1.0,
                  child: disabled,
                ),
                // enabled icon
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: selected ? 1.0 : 0.0,
                  child: enabled,
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
