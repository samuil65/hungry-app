import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:huungry/features/auth/views/profile_view.dart';
import 'package:huungry/features/cart/views/cart_view.dart';
import 'package:huungry/features/home/views/home_view.dart';
import 'package:huungry/features/orderHistory/views/order_history_view.dart';
import 'package:huungry/shared/custom_text.dart';
import 'package:huungry/shared/glass_nav.dart';

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> with TickerProviderStateMixin {
  // late PageController controller;
  late List<Widget> screens;
  int currentScreen = 0;
  late List<AnimationController> iconControllers;

  @override
  void initState() {
    super.initState();

    screens = [HomeView(), CartView(), OrderHistoryView(), ProfileView()];
    iconControllers = List.generate(
      4,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300),
      ),
    );
    iconControllers[currentScreen].forward();
  }

  @override
  void dispose() {
    // controller.dispose();
    for (var c in iconControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == currentScreen) return;
    if (index == 1) {
      screens[1] = CartView(key: UniqueKey());
    }
    if (index == 3) {
      screens[3] = ProfileView(key: UniqueKey());
    }
    setState(() => currentScreen = index);
    iconControllers[index].forward();
    for (var i = 0; i < iconControllers.length; i++) {
      if (i != index) iconControllers[i].reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBody: true,

        body: IndexedStack(index: currentScreen, children: screens),

        bottomNavigationBar: GlassBottomNavBar(
          currentIndex: currentScreen,
          onTap: _onTabTapped,
          items: [
            BottomNavItemData(
              label: 'Home',
              icon: Icon(CupertinoIcons.home),
              filledIcon: Icon(CupertinoIcons.house_fill),
            ),
            BottomNavItemData(
              label: 'Cart',
              icon: Icon(CupertinoIcons.cart),
              filledIcon: Badge(
                label: CustomText(text: '1', size: 10),
                child: Icon(CupertinoIcons.cart_fill_badge_plus),
              ),
            ),
            BottomNavItemData(
              label: 'History',
              icon: Icon(Icons.table_bar_outlined),
              filledIcon: Icon(Icons.table_bar_rounded),
            ),
            BottomNavItemData(
              label: 'Profile',
              icon: Icon(CupertinoIcons.person_alt_circle),
              filledIcon: Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }
}
