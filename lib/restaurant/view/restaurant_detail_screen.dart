import 'package:actual/common/const/colors.dart';
import 'package:actual/common/layout/default_layout.dart';
import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/common/utils/pagination_utils.dart';
import 'package:actual/product/component/product_card.dart';
import 'package:actual/product/model/product_model.dart';
import 'package:actual/rating/component/rating_card.dart';
import 'package:actual/rating/model/rating_model.dart';
import 'package:actual/restaurant/component/restaurant_card.dart';
import 'package:actual/restaurant/model/restaurant_detail_model.dart';
import 'package:actual/restaurant/model/restaurant_model.dart';
import 'package:actual/restaurant/provider/restaurant_provider.dart';
import 'package:actual/restaurant/provider/restaurant_rating_provider.dart';
import 'package:actual/restaurant/view/basket_screen.dart';
import 'package:actual/user/provider/basket_provider.dart';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:badges/badges.dart' as badges;

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  static String get routeName => 'restaurantDetail';

  final String id;

  const RestaurantDetailScreen({super.key, required this.id});

  @override
  ConsumerState<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState
    extends ConsumerState<RestaurantDetailScreen> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();

    ref.read(restaurantProvider.notifier).getDetail(id: widget.id);
    controller.addListener(listener);
  }

  void listener() {
    PaginationUtils.paginate(
      controller: controller,
      provider: ref.read(
        restaurantRatingProvider(widget.id).notifier,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(restaurantDetailProvider(widget.id));
    final ratingsState = ref.watch(restaurantRatingProvider(widget.id));
    final basket = ref.watch(basketProvider);

    if (state == null) {
      return const DefaultLayout(
          child: Center(
        child: CircularProgressIndicator(),
      ));
    }

    return DefaultLayout(
      title: '불타는 떡볶이',
      floatingActionButton: FloatingActionButton(
        backgroundColor: PRIMARY_COLOR,
        onPressed: () {
          context.pushNamed(BasketScreen.routeName);
        },
        child: badges.Badge(
          showBadge: basket.isNotEmpty,
          badgeContent: Text(
            basket
                .fold<int>(
                  0,
                  (previousValue, element) => previousValue + element.count,
                )
                .toString(),
            style: const TextStyle(
              color: PRIMARY_COLOR,
              fontSize: 10,
            ),
          ),
          badgeStyle: const BadgeStyle(badgeColor: Colors.white),
          child: const Icon(
            Icons.shopping_basket_outlined,
            color: Colors.white,
          ),
        ),
      ),
      child: CustomScrollView(
        controller: controller,
        slivers: [
          renderTop(model: state),
          if (state is! RestaurantDetailModel) renderLoading(),
          if (state is RestaurantDetailModel) renderLabel(),
          if (state is RestaurantDetailModel)
            renderProducts(
              products: state.products,
              restaurant: state,
            ),
          if (ratingsState is CursorPagination<RatingModel>)
            renderRatings(
              models: ratingsState.data,
            )
        ],
      ),
    );
  }

  SliverPadding renderRatings({required List<RatingModel> models}) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
            (_, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: RatingCard.fromModel(
                    model: models[index],
                  ),
                ),
            childCount: models.length),
      ),
    );
  }

  SliverPadding renderLoading() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 16.0,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Skeletonizer(
                enabled: true,
                child: Column(
                  // ListView 대신 Column 사용
                  children: List.generate(7, (index) {
                    return Card(
                      child: ListTile(
                        title: Text('Item number $index as title'),
                        subtitle: const Text('Subtitle here'),
                        trailing: const Icon(Icons.ac_unit),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter renderTop({
    required RestaurantModel model,
  }) {
    return SliverToBoxAdapter(
      child: RestaurantCard.fromModel(
        model: model,
        isDetail: true,
      ),
    );
  }

  SliverPadding renderLabel() {
    return const SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Text(
          '메뉴',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  SliverPadding renderProducts(
      {required RestaurantModel restaurant,
      required List<RestaurantProductModel> products}) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
        final model = products[index];
        return InkWell(
          onTap: () {
            ref.read(basketProvider.notifier).addToBasket(
                  product: ProductModel(
                    id: model.id,
                    name: model.name,
                    detail: model.detail,
                    imgUrl: model.imgUrl,
                    price: model.price,
                    restaurant: restaurant,
                  ),
                );
          },
          child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ProductCard.fromRestaurantProductModel(model: model)),
        );
      }, childCount: products.length)),
    );
  }
}
