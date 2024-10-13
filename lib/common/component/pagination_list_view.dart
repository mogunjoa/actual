import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/common/model/model_with_id.dart';
import 'package:actual/common/provider/pagination_provider.dart';
import 'package:actual/common/utils/pagination_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef PaginationWidgetBuilder<T extends InterfaceModelWithId> = Widget
    Function(BuildContext context, int index, T model);

class PaginationListView<T extends InterfaceModelWithId>
    extends ConsumerStatefulWidget {
  final StateNotifierProvider<PaginationProvider, CursorPaginationBase>
      provider;

  final PaginationWidgetBuilder<T> itemBuilder;

  const PaginationListView(
      {required this.provider, required this.itemBuilder, super.key});

  @override
  ConsumerState<PaginationListView> createState() =>
      _PaginationListViewState<T>();
}

class _PaginationListViewState<T extends InterfaceModelWithId>
    extends ConsumerState<PaginationListView> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();

    controller.addListener(listener);
  }

  void listener() {
    PaginationUtils.paginate(
        controller: controller, provider: ref.read(widget.provider.notifier));
  }

  @override
  void dispose() {
    controller.removeListener(listener);
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.provider);

    // 첫 로딩일 시
    if (state is CursorPaginationLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 오류 발생 시
    if (state is CursorPaginationError) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            state.message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(widget.provider.notifier).paginate(forceRefetch: true);
            },
            child: const Text(
              '다시시도',
            ),
          )
        ],
      );
    }

    // CursorPagination
    // CursorPaginationFetchingMore
    // CursorPaginationReFetching
    final cp = state as CursorPagination;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RefreshIndicator(
        onRefresh: () async {
          ref.read(widget.provider.notifier).paginate(
                forceRefetch: true,
              );
        },
        child: ListView.separated(
          // 항상 스크롤 가능하도록
          physics: const AlwaysScrollableScrollPhysics(),
          controller: controller,
          itemCount: cp.data.length + 1,
          itemBuilder: (context, index) {
            if (index == cp.data.length) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Center(
                  child: cp is CursorPaginationFetchingMore
                      ? const CircularProgressIndicator()
                      : const Text('마지막 데이터입니다 ㅠㅠ'),
                ),
              );
            }

            final pItem = cp.data[index];

            return widget.itemBuilder(
              context,
              index,
              pItem,
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(height: 16);
          },
        ),
      ),
    );
  }
}
