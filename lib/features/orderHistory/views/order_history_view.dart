import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:huungry/core/utils/pref_helper.dart';
import 'package:huungry/shared/custom_button.dart';
import '../../../shared/custom_text.dart';

class OrderHistoryView extends StatefulWidget {
  const OrderHistoryView({super.key});

  @override
  State<OrderHistoryView> createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  final List<_OrderHistoryItem> _orders =
      []; // Populate from API when available.
  late Future<bool> _isGuestFuture;

  @override
  void initState() {
    super.initState();
    _isGuestFuture = _determineIfGuest();
  }

  Future<bool> _determineIfGuest() async {
    final token = await PrefHelper.getToken();
    return token == null || token == 'guest';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: FutureBuilder<bool>(
          future: _isGuestFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final shouldShowEmptyState = snapshot.data! || _orders.isEmpty;

            if (shouldShowEmptyState) {
              return const _EmptyOrdersState();
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 120, top: 10),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                return Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  bottom: -5,
                                  right: 0,
                                  left: 0,
                                  child: Image.asset('assets/icon/shadow.png'),
                                ),
                                Center(
                                  child: Image.asset(
                                    order.imagePath,
                                    width: 90,
                                    height: 90,
                                  ),
                                ),
                              ],
                            ),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: order.title,
                                    weight: FontWeight.bold,
                                    size: 14,
                                  ),
                                  CustomText(
                                    text: 'Qty : ${order.quantityLabel}',
                                    size: 14,
                                  ),
                                  CustomText(
                                    text: 'Price : ${order.priceLabel}',
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Gap(20),
                        CustomButton(
                          height: 45,
                          text: 'Order Again',
                          color: Colors.grey.shade400,
                          width: double.infinity,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
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
          Icon(Icons.receipt_long_outlined, size: 54, color: Colors.grey),
          Gap(16),
          CustomText(
            text: 'NO ORDERS RIGHT NOW',
            weight: FontWeight.w600,
            size: 16,
          ),
          Gap(8),
          CustomText(
            text: 'Place your first order to see it listed here.',
            size: 12,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}

class _OrderHistoryItem {
  const _OrderHistoryItem({
    required this.title,
    required this.quantityLabel,
    required this.priceLabel,
    required this.imagePath,
  });

  final String title;
  final String quantityLabel;
  final String priceLabel;
  final String imagePath;
}
