import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import 'categories.dart';

class FoodPage extends StatefulWidget {
  final String category;

  const FoodPage({Key? key, required this.category}) : super(key: key);

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  List<dynamic> meals = [];
  List<dynamic> selectedMeals = [];
  Map<String, bool> addIconsVisibility = {};

  @override
  void initState() {
    super.initState();
    fetchMeals();
  }

  Future<void> fetchMeals() async {
    final String category = widget.category;
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=$category'));
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
        title: Text('Meals'),
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
              duration: Duration(milliseconds: 300),
              child: IconButton(
                icon: Icon(Icons.verified, color: Colors.green),
                onPressed: () {

                },
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
          selectedMeals.forEach((meal) {
            saveMeals.add(meal['strMeal']);
          });
          saveMeals.forEach((meal){
            user.addMeal(meal);
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoriesPage(),
            ),
          );

          },
        child: Icon(Icons.check),
        backgroundColor: Colors.green,

      ),
    );
  }
}