import 'package:flutter/material.dart';
import '../ui/pages/login.dart';
import '../ui/pages/register.dart';
import '../ui/pages/categories.dart';
import '../ui/pages/food.dart';
import '../ui/pages/chat.dart';
import '../ui/pages/restaurant.dart';
import '../ui/pages/users.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String categories = '/categories';
  static const String food = '/food';
  static const String chat = '/chat';
  static const String restaurant = '/restaurant';
  static const String users = '/users';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case categories:
        return MaterialPageRoute(builder: (_) => const CategoriesPage());
      case food:
        return MaterialPageRoute(builder: (_) => FoodPage(category: settings.arguments as String));
      case chat:
        return MaterialPageRoute(builder: (_) => ChatPage(otherUserName: settings.arguments as String));
      case restaurant:
        return MaterialPageRoute(builder: (_) => const RestaurantPage());
      case users:
        return MaterialPageRoute(builder: (_) => const UserPage());
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}
