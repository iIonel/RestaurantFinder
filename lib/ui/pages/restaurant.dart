import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restaurant_finder/controllers/user_controller.dart';
import 'package:restaurant_finder/data/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../data/models/user.dart';

class RestaurantPage extends StatefulWidget {
  const RestaurantPage({Key? key}) : super(key: key);

  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  late GoogleMapController mapController;
  List<String> meals = [];
  Set<Marker> _markers = {};
  final UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    _getMealsFrom();
    _userController.setMeals([]);
  }

  Future<void> _getMealsFrom() async {
    try {

      final response = await ApiService.getRequest(dotenv.env['GET_FOOD_BY_EMAIL_URL']!);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> foodList = data['food'];

        setState(() {
          meals = foodList
              .expand((item) => (item as String).split(','))
              .map((item) => item.trim())
              .toList();
        });
        _getAllRestaurantsForMeals();
      } else {
        throw Exception('Failed to load meals');
      }
    } catch (error) {
      print('Error fetching meals: $error');
    }
  }

  Future<void> _getAllRestaurantsForMeals() async {
    for (var meal in meals) {
      await _getRestaurantsForMeal(meal);
    }
  }

  Future<void> _getRestaurantsForMeal(String meal) async {
    final response = await ApiService.getRequest(
        '/maps/api/place/textsearch/json?query=$meal&location=47.159809,27.587200&radius=1000&key=${dotenv.env['API_KEY']}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;

      for (var result in results) {
        final name = result['name'];
        final lat = result['geometry']['location']['lat'];
        final lng = result['geometry']['location']['lng'];
        final address = result['formatted_address'];

        final markerId = MarkerId(name);
        final marker = Marker(
          markerId: markerId,
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: name,
            snippet: address,
            onTap: () {
              _showMealDialog(context, meal);
            },
          ),
        );

        setState(() {
          _markers.add(marker);
        });
      }
    } else {
      throw Exception('Failed to load restaurants for meal $meal');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _showMealDialog(BuildContext context, String meal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Meals for $meal'),
          content: Text('Meal: $meal'),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(47.159809, 27.587200),
          zoom: 13.0,
        ),
        markers: _markers,
      ),
    );
  }
}
