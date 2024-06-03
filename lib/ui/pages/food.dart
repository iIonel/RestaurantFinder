import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:restaurant_finder/controllers/user_controller.dart';
import 'package:restaurant_finder/data/services/api_service.dart';
import 'categories.dart';

class FoodPage extends StatefulWidget {
  final String category;

  const FoodPage({super.key, required this.category});

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  List<dynamic> meals = [];
  List<dynamic> selectedMeals = [];
  Map<String, bool> addIconsVisibility = {};
  final UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    fetchMeals();
  }

  Future<void> fetchMeals() async {
    final response = await ApiService.getRequest(dotenv.env['FOOD']!, queryParams: {'c': widget.category});
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData != null && responseData['meals'] != null) {
        setState(() {
          meals = responseData['meals'];
        });
      } else {
        throw Exception('Invalid response data');
      }
    } else {
      throw Exception('Failed to load meals');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meals - ${widget.category}'),
      ),
      body: ListView.builder(
        itemCount: meals.length,
        itemBuilder: (BuildContext context, int index) {
          String mealName = meals[index]['strMeal'];
          bool isVisible = addIconsVisibility.containsKey(mealName) ? addIconsVisibility[mealName]! : false;

          return ListTile(
            leading: Image.network(meals[index]['strMealThumb']),
            title: Text(mealName),
            trailing: AnimatedOpacity(
              opacity: isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: IconButton(
                icon: const Icon(Icons.verified, color: Colors.green),
                onPressed: () {},
              ),
            ),
            onTap: () {
              setState(() {
                if (selectedMeals.contains(meals[index])) {
                  selectedMeals.remove(meals[index]);
                  addIconsVisibility[mealName] = false;
                } else {
                  selectedMeals.add(meals[index]);
                  addIconsVisibility[mealName] = true;
                }
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          List<String> saveMeals = [];
          for (var meal in selectedMeals) {
            saveMeals.add(meal['strMeal']);
          }
          for (var meal in saveMeals) {
            _userController.addMeal(meal);
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CategoriesPage()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.check),
      ),
    );
  }
}
