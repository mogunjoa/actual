import 'package:actual/user/provider/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final provider = ref.read(authProvider);

  return GoRouter(
    routes: provider.routes,
    initialLocation: '/splash',
    refreshListenable: provider,
    redirect: provider.redirectLogic,
  );
});
