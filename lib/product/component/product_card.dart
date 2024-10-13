import 'dart:ui';

import 'package:actual/common/const/colors.dart';
import 'package:actual/product/model/product_model.dart';
import 'package:actual/restaurant/model/restaurant_detail_model.dart';
import 'package:actual/user/provider/basket_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductCard extends ConsumerWidget {
  final Image image;
  final String name;
  final String detail;
  final int price;
  final String id;
  final VoidCallback? onSubstract;
  final VoidCallback? onAdd;

  const ProductCard({
    super.key,
    required this.id,
    required this.image,
    required this.name,
    required this.detail,
    required this.price,
    this.onSubstract,
    this.onAdd,
  });

  factory ProductCard.fromProductModel({
    required ProductModel model,
    VoidCallback? onSubstract,
    VoidCallback? onAdd,
  }) {
    return ProductCard(
      id: model.id,
      image: Image.network(
        model.imgUrl,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
      ),
      name: model.name,
      detail: model.detail,
      price: model.price,
      onSubstract: onSubstract,
      onAdd: onAdd,
    );
  }

  factory ProductCard.fromRestaurantProductModel({
    required RestaurantProductModel model,
    VoidCallback? onSubstract,
    VoidCallback? onAdd,
  }) {
    return ProductCard(
      id: model.id,
      image: Image.network(
        model.imgUrl,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
      ),
      name: model.name,
      detail: model.detail,
      price: model.price,
      onSubstract: onSubstract,
      onAdd: onAdd,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final basket = ref.watch(basketProvider);

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: image,
              ),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: BODY_TEXT_COLOR,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '₩$price',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: PRIMARY_COLOR,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ))
            ],
          ),
        ),
        if (onSubstract != null && onAdd != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _Footer(
              total: (basket.firstWhere((e) => e.product.id == id).count *
                      basket.firstWhere((e) => e.product.id == id).product.price)
                  .toString(),
              count: basket.firstWhere((e) => e.product.id == id).count,
              onSubstract: onSubstract!,
              onAdd: onAdd!,
            ),
          )
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  final String total;
  final int count;
  final VoidCallback onSubstract;
  final VoidCallback onAdd;

  const _Footer(
      {super.key,
      required this.total,
      required this.count,
      required this.onSubstract,
      required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '총액 ₩$total',
            style: const TextStyle(
              color: PRIMARY_COLOR,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: [
            renderButton(
              icon: Icons.remove,
              onTap: onSubstract,
            ),
            const SizedBox(width: 8),
            Text(
              count.toString(),
              style: const TextStyle(
                color: PRIMARY_COLOR,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            renderButton(
              icon: Icons.add,
              onTap: onAdd,
            ),
          ],
        )
      ],
    );
  }

  Widget renderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: PRIMARY_COLOR,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Icon(
          icon,
          color: PRIMARY_COLOR,
        ),
      ),
    );
  }
}
