import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/profile_setup_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../features/friends/presentation/screens/friends_screen.dart';
import '../../features/chat/presentation/screens/chats_list_screen.dart';
import '../../features/checkins/presentation/screens/checkins_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/presentation/screens/chat_expired_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/couple/presentation/screens/couple_screen.dart';
import '../../features/couple/presentation/screens/couple_stamp_screen.dart';
import '../../shared/widgets/main_shell.dart';
import 'route_names.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    routes: [
      // Сплэш
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Онбординг
      GoRoute(
        path: RouteNames.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Авторизация
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.profileSetup,
        name: RouteNames.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // Основная оболочка с навигацией
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.map,
            name: RouteNames.map,
            builder: (context, state) => const MapScreen(),
          ),
          GoRoute(
            path: RouteNames.friends,
            name: RouteNames.friends,
            builder: (context, state) => const FriendsScreen(),
          ),
          GoRoute(
            path: RouteNames.chatsList,
            name: RouteNames.chatsList,
            builder: (context, state) => const ChatsListScreen(),
          ),
          GoRoute(
            path: RouteNames.checkins,
            name: RouteNames.checkins,
            builder: (context, state) => const CheckinsScreen(),
          ),
          GoRoute(
            path: RouteNames.profile,
            name: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                name: RouteNames.editProfile,
                builder: (context, state) => const EditProfileScreen(),
              ),
            ],
          ),
          GoRoute(
            path: RouteNames.couple,
            name: RouteNames.couple,
            builder: (context, state) => const CoupleScreen(),
            routes: [
              GoRoute(
                path: 'stamp',
                name: RouteNames.coupleStamp,
                builder: (context, state) => const CoupleStampScreen(),
              ),
            ],
          ),
        ],
      ),

      // Чат (вне оболочки — полноэкранный)
      GoRoute(
        path: '${RouteNames.chat}/:chatId',
        name: RouteNames.chat,
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          return ChatScreen(chatId: chatId);
        },
      ),

      // Экран завершения чата
      GoRoute(
        path: RouteNames.chatExpired,
        name: RouteNames.chatExpired,
        builder: (context, state) => const ChatExpiredScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Страница не найдена: ${state.error}'),
      ),
    ),
  );
});
