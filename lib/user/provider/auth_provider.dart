
import 'package:actual/common/view/root_tab.dart';
import 'package:actual/common/view/splash_screen.dart';
import 'package:actual/restaurant/view/restaurant_detail_screen.dart';
import 'package:actual/user/model/user_model.dart';
import 'package:actual/user/provider/user_me_provider.dart';
import 'package:actual/user/view/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider(ref: ref);
});

class AuthProvider extends ChangeNotifier {
  final Ref ref;

  AuthProvider({
    required this.ref,
  }) {
    ref.listen<UserModelBase?>(userMeProvider, (previous, next) {
      if (previous != next) {
        notifyListeners();
      }
    });
  }

  String? redirectLogic(BuildContext context, GoRouterState state) {
    final UserModelBase? user = ref.read(userMeProvider);

    final loginIn = state.matchedLocation == '/login';

    if (user == null) {
      return loginIn ? null : '/login';
    }

    // 사용자 정보가 있는 상태 : 로그인 중 이거나 현재 위치가 SplashScreen 이면 홈으로 이동
    if (user is UserModel) {
      return loginIn || state.matchedLocation == '/splash' ? '/' : null;
    }

    if (user is UserModelError) {
      return !loginIn ? '/login' : null;
    }

    return null;
  }

  List<GoRoute> get routes => [
        GoRoute(
          path: '/',
          name: RootTab.routeName,
          builder: (context, state) => RootTab(),
          routes: [
            GoRoute(
              path: 'restaurant/:rid',
              name: RestaurantDetailScreen.routeName,
              builder: (context, state) => RestaurantDetailScreen(
                id: state.pathParameters['rid']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/splash',
          name: SplashScreen.routeName,
          builder: (context, state) => SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          name: LoginScreen.routeName,
          builder: (context, state) => LoginScreen(),
        ),
      ];

  void logout() {
    ref.read(userMeProvider.notifier).logout();
  }
}
