import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:restaurant_finder/pages/restaurant.dart';
import 'package:restaurant_finder/pages/users.dart';
import '../models/user.dart';
import 'food.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<dynamic> categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'));
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
    String email = user.getEmail();

    String loginUrl = 'https://us-central1-foodfoodapp-423813.cloudfunctions.net/select/select';
    Uri uri = Uri.parse(loginUrl).replace(queryParameters: {
      'email': email,
      'food': food,
    });

    try {
      var response = await http.post(uri);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        print('Selectare reușită: ${responseData}');
        user.setEmail(email);
      } else {
        var responseData = json.decode(response.body);
        print('Eroare la selectare: ${responseData['error']}');
        _showErrorDialog(responseData['error']);
      }
    } catch (e) {
      print('Eroare la selectare: $e');
      _showErrorDialog('Internal server error');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.restaurant),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RestaurantPage()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FoodPage(category: categories[index]['strCategory']),
                ),
              );
            },
            child: Card(
              elevation: 4,
              margin: EdgeInsets.all(8),
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
         user.removeDuplicates();
         //print(user.getMeals());
         String foodreq = '';
         List<String> foods = user.getMeals();
         for(var i = 0; i < foods.length - 1; i++){
           foodreq += foods[i];
           foodreq += ", ";
         }
         foodreq += foods[foods.length - 1];
         _select(foodreq);
         },
        child: Icon(Icons.check),
        backgroundColor: Colors.green,
      ),
    );
  }
}