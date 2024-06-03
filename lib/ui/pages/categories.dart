import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:restaurant_finder/controllers/user_controller.dart';
import 'package:restaurant_finder/data/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../routes/routes.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<dynamic> categories = [];
  final UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await ApiService.getRequest(dotenv.env['FOOD_CATEGORIES']!);
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body)['categories'];
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Selection Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _select(String food) async {
    String email = _userController.getEmail();

    try {
      var response = await ApiService.postRequest(
        dotenv.env['SELECT_URL']!,
        queryParams: {'email': email, 'food': food},
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (kDebugMode) {
          print(responseData);
        }
        _userController.setEmail(email);
      } else {
        var responseData = json.decode(response.body);
        if (kDebugMode) {
          print('Error: ${responseData['error']}');
        }
        _showErrorDialog(responseData['error']);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      _showErrorDialog('Internal server error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.users);
            },
          ),
          IconButton(
            icon: const Icon(Icons.restaurant),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.restaurant);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.food,
                arguments: categories[index]['strCategory'],
              );
            },
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Image.network(
                    categories[index]['strCategoryThumb'],
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      categories[index]['strCategory'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _userController.removeDuplicates();
          String foodreq = '';
          List<String> foods = _userController.getMeals();
          for (var i = 0; i < foods.length - 1; i++) {
            foodreq += foods[i];
            foodreq += ", ";
          }
          foodreq += foods[foods.length - 1];
          _select(foodreq);
        },
        child: const Icon(Icons.check),
        backgroundColor: Colors.green,
      ),
    );
  }
}
