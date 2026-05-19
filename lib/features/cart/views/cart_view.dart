import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:huungry/core/constants/app_colors.dart';
import 'package:huungry/features/cart/data/cart_model.dart';
import 'package:huungry/features/cart/data/cart_repo.dart';
import 'package:huungry/features/cart/widgets/cart_item.dart';
import 'package:huungry/features/checkout/views/checkout_view.dart';
import 'package:huungry/shared/custom_text.dart';
import '../../../shared/custom_button.dart';
import '../../auth/data/auth_repo.dart';
import '../../auth/data/user_model.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  late List<int> quantities = [];
  bool isLoading = false;
  bool isLoadingRemove = false;
  bool isGuest = false;
  AuthRepo authRepo = AuthRepo();
  UserModel? userModel;

  Future<void> autoLogin() async {
    final user = await authRepo.autoLogin();
    if (!mounted) return;
    setState(() => isGuest = authRepo.isGuest);
    if (user != null) setState(() => userModel = user);
  }

  GetCartResponse? cartResponse;
  CartRepo cartRepo = CartRepo();

  Future<void> getCartData() async {
    try {
      if (!mounted) return;
      setState(() => isLoading = true);

      final res = await cartRepo.getCartData();
      if (!mounted) return;
      final itemCount = res?.cartData.items.length ?? 0;
      setState(() {
        cartResponse = res;
        quantities = List.generate(itemCount, (_) => 1);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      print(e.toString());
    }
  }

  Future<void> removeCartItem(int id) async {
    try {
      if (!mounted) return;
      setState(() {
        isLoadingRemove = true;
      });
      await cartRepo.removeCartItem(id);
      if (!mounted) return;
      getCartData();
      setState(() {
        isLoadingRemove = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingRemove = false;
      });
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    autoLogin();
    getCartData();
  }

  void onAdd(int index) {
    setState(() {
      quantities[index]++;
    });
  }

  void onMin(int index) {
    setState(() {
      if (quantities[index] > 1) {
        quantities[index]--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isCartEmpty =
        cartResponse == null || cartResponse!.cartData.items.isEmpty;
    final bool shouldShowEmptyState = isGuest || isCartEmpty;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 30,
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const SizedBox.shrink(),
        centerTitle: true,
        title: const CustomText(
          text: 'My Cart',
          color: Colors.black87,
          weight: FontWeight.w600,
          size: 20,
        ),
      ),
      body:
          isLoading
              ? const Center(child: CupertinoActivityIndicator())
              : shouldShowEmptyState
              ? const _EmptyOrdersState()
              : Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView.builder(
                      clipBehavior: Clip.none,
                      padding: const EdgeInsets.only(bottom: 140, top: 10),
                      itemCount: cartResponse!.cartData.items.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = cartResponse!.cartData.items[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 10,
                                  offset: const Offset(3, 3),
                                  color: Colors.black.withOpacity(0.2),
                                ),
                              ],
                            ),
                            child: CartItem(
                              isLoading: isLoadingRemove,
                              text: item.name,
                              image: item.image,
                              desc: 'Spicy ${item.spicy}',
                              number:
                                  index < quantities.length
                                      ? quantities[index]
                                      : item.quantity,
                              onRemove: () {
                                removeCartItem(item.itemId);
                              },
                              onAdd: () => onAdd(index),
                              onMin: () => onMin(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Floating total bar
                  Positioned(
                    right: -10,
                    left: -10,
                    bottom: -20,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.8),
                            AppColors.primary.withOpacity(0.8),
                            AppColors.primary,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      child: Column(
                        children: [
                          Gap(8),
                          GestureDetector(
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => CheckoutView(
                                          totalPrice:
                                              cartResponse
                                                  ?.cartData
                                                  .totalPrice ??
                                              "0.0",
                                        ),
                                  ),
                                ),
                            child: CustomButton(
                              gap: 80,
                              height: 45,
                              text: 'Checkout',
                              widget: CustomText(
                                text:
                                    '${cartResponse?.cartData.totalPrice}\$' ??
                                    "0.0",
                                size: 14,
                              ),
                              color: Colors.white,
                              width: double.infinity,
                              textColor: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}

class _EmptyOrdersState extends StatelessWidget {
  const _EmptyOrdersState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shopping_cart_outlined, size: 54, color: Colors.green),
          Gap(16),
          CustomText(
            text: 'NO ITEMS ADEED YET',
            weight: FontWeight.w600,
            size: 18,
          ),
          Gap(3),
          CustomText(
            text: 'Login to pick your favorite food 🍔.',
            size: 12,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
