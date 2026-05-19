import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:huungry/core/constants/app_colors.dart';
import 'package:huungry/core/network/api_error.dart';
import 'package:huungry/features/cart/data/cart_model.dart';
import 'package:huungry/features/cart/data/cart_repo.dart';
import 'package:huungry/features/home/data/models/topping_model.dart';
import 'package:huungry/features/home/data/repo/product_repo.dart';
import 'package:huungry/shared/custom_button.dart';
import 'package:huungry/shared/custom_text.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../widgets/spicy_slider.dart';
import '../widgets/topping_card.dart';

class ProductDetailsView extends StatefulWidget {
  const ProductDetailsView({
    super.key,
    required this.productImage,
    required this.productId,
    required this.productPrice,
  });
  final String productImage;
  final int productId;
  final String productPrice;

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  double value = 0.5;
  List<int> selectedOptions = [];
  List<int> selectedToppings = [];

  List<ToppingModel>? options;
  List<ToppingModel>? toppings;

  bool isLoading = false;
  bool isAddedToCart = false;

  /// product function
  ProductRepo productRepo = ProductRepo();
  Future<void> getToppings() async {
    final res = await productRepo.getToppings();
    if (!mounted) return;
    setState(() {
      toppings = res;
    });
  }

  Future<void> getOptions() async {
    final res = await productRepo.getOptions();
    if (!mounted) return;
    setState(() {
      options = res;
    });
  }

  /// cart Function
  CartRepo cartRepo = CartRepo();

  @override
  void initState() {
    super.initState();
    getToppings();
    getOptions();
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: widget.productImage.isEmpty,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0.0,
          toolbarHeight: 18,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_circle_left_outlined,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SpicySlider(
                  value: value,
                  img: widget.productImage,
                  onChanged: (v) => setState(() => value = v),
                ),
                Gap(40),
                CustomText(text: 'Toppings', size: 18),
                Gap(10),

                /// Toppings
                SingleChildScrollView(
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(toppings?.length ?? 4, (index) {
                      final topping = toppings?[index];
                      final id = topping?.id;
                      if (topping == null) {
                        return CupertinoActivityIndicator();
                      }
                      final isSelected = selectedToppings.contains(id);
                      return Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: ToppingCard(
                          color:
                              isSelected
                                  ? Colors.green.withOpacity(0.2)
                                  : AppColors.primary.withOpacity(0.1),
                          title: topping.name,
                          imageUrl: topping.image,
                          onAdd: () {
                            setState(() {
                              if (isSelected) {
                                selectedToppings.remove(id);
                              } else {
                                selectedToppings.add(id!);
                              }
                            });
                          },
                        ),
                      );
                    }),
                  ),
                ),
                Gap(25),
                CustomText(text: 'Side Options', size: 18),
                Gap(10),

                ///  Options
                SingleChildScrollView(
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(options?.length ?? 4, (index) {
                      final option = options?[index];
                      final id = option?.id ?? 1;
                      if (option == null) {
                        return CupertinoActivityIndicator();
                      }
                      final isSelected = selectedOptions.contains(id);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ToppingCard(
                          color:
                              isSelected
                                  ? Colors.green.withOpacity(0.2)
                                  : AppColors.primary.withOpacity(0.1),
                          imageUrl: option.image,
                          title: option.name,
                          onAdd: () {
                            setState(() {
                              if (isSelected) {
                                selectedOptions.remove(id);
                              } else {
                                selectedOptions.add(id);
                              }
                            });
                          },
                        ),
                      );
                    }),
                  ),
                ),
                Gap(200),
              ],
            ),
          ),
        ),

        bottomSheet: Container(
          height: 150,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.7),
                AppColors.primary,
                AppColors.primary,
                AppColors.primary,
                AppColors.primary,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(30),
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'Burger Price :',
                      size: 15,
                      color: Colors.white,
                    ),
                    CustomText(
                      text: '\$ ${widget.productPrice}' ?? "0.0",
                      size: 20,
                      color: Colors.white,
                      weight: FontWeight.w700,
                    ),
                  ],
                ),
                CustomButton(
                  widget:
                      isLoading
                          ? CupertinoActivityIndicator(color: AppColors.primary)
                          : Icon(
                            isAddedToCart
                                ? CupertinoIcons.check_mark_circled_solid
                                : CupertinoIcons.cart_badge_plus,
                          ),
                  gap: 10,
                  height: 48,
                  color: isAddedToCart ? Colors.grey.shade400 : Colors.white,
                  textColor: AppColors.primary,
                  text: isAddedToCart ? 'Added to Cart' : 'Add To Cart',
                  onTap:
                      isAddedToCart
                          ? null
                          : () async {
                            try {
                              if (!mounted) return;
                              setState(() => isLoading = true);
                              final cartItem = CartModel(
                                productId: widget.productId,
                                qty: 1,
                                spicy: value,
                                toppings: selectedToppings,
                                options: selectedOptions,
                              );
                              await cartRepo.addToCart(
                                CartRequestModel(items: [cartItem]),
                              );
                              if (!mounted) return;
                              setState(() {
                                isLoading = false;
                                isAddedToCart = true;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '✅ Added to cart successfully!',
                                  ),
                                ),
                              );
                            } on ApiError catch (error) {
                              if (!mounted) return;
                              setState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error.message),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              setState(() => isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Something went wrong. Please try again.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
