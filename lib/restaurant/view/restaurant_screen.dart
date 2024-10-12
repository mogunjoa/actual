import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/common/utils/pagination_utils.dart';
import 'package:actual/restaurant/component/restaurant_card.dart';
import 'package:actual/restaurant/provider/restaurant_provider.dart';
import 'package:actual/restaurant/view/restaurant_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RestaurantScreen extends ConsumerStatefulWidget {
  const RestaurantScreen({super.key});

  @override
  ConsumerState<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends ConsumerState<RestaurantScreen> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();

    controller.addListener(scrollListener);
  }

  void scrollListener() {
    PaginationUtils.paginate(
      controller: controller,
      provider: ref.read(restaurantProvider.notifier),
    );

    // 현재 위치가 최대 길이보다 조금 덜되는 위치까지 왔다면 새로운 데이터를 추가 요청
    //최대 스크롤 길이에서 300픽셀 위 포지션을 넘게 스크롤 시 동작
    // if (controller.offset > controller.position.maxScrollExtent - 300) {
    //   ref.read(restaurantProvider.notifier).paginate(
    //         fetchMore: true,
    //         fetchCount: 10,
    //       );
    // }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(restaurantProvider);

    // 첫 로딩일 시
    if (data is CursorPaginationLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 오류 발생 시
    if (data is CursorPaginationError) {
      return Center(
        child: Text(data.message),
      );
    }

    // CursorPagination
    // CursorPaginationFetchingMore
    // CursorPaginationReFetching
    final cp = data as CursorPagination;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        controller: controller,
        itemCount: cp.data.length + 1,
        itemBuilder: (context, index) {
          if (index == cp.data.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                child: data is CursorPaginationFetchingMore
                    ? CircularProgressIndicator()
                    : Text('마지막 데이터입니다 ㅠㅠ'),
              ),
            );
          }

          final pItem = cp.data[index];

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => RestaurantDetailScreen(id: pItem.id)));
            },
            child: RestaurantCard.fromModel(model: pItem),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 16);
        },
      ),
    );
  }
}
