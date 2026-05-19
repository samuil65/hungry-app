import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:huungry/core/constants/app_colors.dart';
import 'package:huungry/features/home/data/models/product_model.dart';
import 'package:huungry/features/home/data/repo/product_repo.dart';
import 'package:huungry/features/home/widgets/card_item.dart';
import 'package:huungry/features/home/widgets/food_catrgory.dart';
import 'package:huungry/features/home/widgets/search_field.dart';
import 'package:huungry/features/home/widgets/user_header.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/network/api_error.dart';
import '../../../shared/custom_snack.dart';
import '../../auth/data/auth_repo.dart';
import '../../auth/data/user_model.dart';
import '../../productDetail/views/product_details_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int selectedIndex = 0;
  List category = ['All', 'Combo', 'Sliders', 'Classic', 'Hot'];
  final TextEditingController controller = TextEditingController();

  UserModel? userModel;
  AuthRepo authRepo = AuthRepo();

  /// get profile
  Future<void> getProfileData() async {
    try {
      final user = await authRepo.getProfileData();
      setState(() {
        userModel = user;
      });
    } catch (e) {
      String errorMsg = 'Error in Profile';
      if (e is ApiError) {
        errorMsg = e.message;
      }
      ScaffoldMessenger.of(context).showSnackBar(customSnack(errorMsg));
    }
  }

  List<ProductModel>? products;
  List<ProductModel>? allProducts;

  ProductRepo productRepo = ProductRepo();

  Future<void> getProducts() async {
    final res = await productRepo.getProducts();
    setState(() {
      allProducts = res;
      products = res;
    });
  }

  @override
  void initState() {
    getProfileData();
    getProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Skeletonizer(
        enabled: products == null,
        child: Scaffold(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          body: CustomScrollView(
            clipBehavior: Clip.none,
            slivers: [
              /// header
              SliverAppBar(
                elevation: 30,
                pinned: true,
                floating: false,
                toolbarHeight: 190,
                scrolledUnderElevation: 40,
                backgroundColor: AppColors.primary,
                automaticallyImplyLeading: false,
                flexibleSpace: ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 500),
                    child: Container(
                      color: Colors.white.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 70,
                          right: 20,
                          left: 20,
                        ),
                        child: Column(
                          children: [
                            UserHeader(
                              userName: userModel?.name ?? 'Guest',
                              userImage:
                                  userModel?.image.toString() ??
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRvts5aHBstDkR8PigS4RmZkbZy78zpZoSuOw&s",
                            ),
                            Gap(20),
                            SearchField(
                              controller: controller,
                              onChanged: (value) {
                                final query = value.toLowerCase();
                                setState(() {
                                  products =
                                      allProducts
                                          ?.where(
                                            (p) => p.name
                                                .toLowerCase()
                                                .contains(query),
                                          )
                                          .toList();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Gap(3),
              ),

              /// Category
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
                  child: FoodCategory(
                    category: category,
                    selectedIndex: selectedIndex,
                  ),
                ),
              ),

              /// GridView
              SliverPadding(
                padding: EdgeInsets.only(left: 10, right: 10 ,bottom: 120, top: 20),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    childCount: products?.length ?? 6,
                    (context, index) {
                      final reversedIndex = (products?.length ?? 0) - 1 - index;
                      final product = products?[reversedIndex];

                      /// SHIMMER
                      if (product == null) {
                        return Shimmer(
                          enabled: true,
                          direction: ShimmerDirection.rtl,
                          gradient: LinearGradient(
                            colors: [
                              Colors.black,
                              Colors.black38,
                              Colors.black87,
                            ],
                          ),
                          child: Container(
                            width: 250,
                            height: 140,
                            padding: EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 250,
                                  height: 100,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                Gap(25),
                                Column(
                                  spacing: 10,
                                  children: List.generate(4, (index) {
                                    return Container(
                                      width: 250,
                                      height: 10,
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: Colors.black12,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return GestureDetector(
                        onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (c) => ProductDetailsView(
                                      productImage: product.image,
                                      productId: product.id,
                                      productPrice: product.price,
                                    ),
                              ),
                            ),
                        child: CardItem(
                          text: product.name,
                          image: product.image,
                          desc: product.desc,
                          rate: product.rate,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
