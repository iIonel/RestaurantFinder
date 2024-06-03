import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_finder/controllers/user_controller.dart';
import 'package:restaurant_finder/data/services/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../routes/routes.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late Future<List<Map<String, String>>> _matchedUsers;
  final UserController _userController = UserController();
  late String usercom;

  @override
  void initState() {
    super.initState();
    _match();
    _matchedUsers = _fetchMatchedUsers();
  }

  Future<void> _match() async {
    try {
      final response = await ApiService.getRequest(dotenv.env['MATCH_URL']!);
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Matches created successfully');
        }
      } else {
        throw Exception('Failed to create matches');
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error creating matches: $error');
      }
    }
  }

  Future<List<Map<String, String>>> _fetchMatchedUsers() async {
    final response = await ApiService.getRequest(
      dotenv.env['MATCH_EMAIL_URL']!,
      queryParams: {'email': _userController.getEmail()},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Map<String, String>> matches = [];

      for (var match in data) {
        final userA = match['userA'] as String;
        final userB = match['userB'] as String;
        final keyword = match['keyword'] as String;

        final otherUser = (userA == _userController.getEmail()) ? userB : userA;
        usercom = otherUser;
        matches.add({'user': otherUser.toString().split('@').first, 'keyword': keyword});
      }

      return matches;
    } else {
      throw Exception('Failed to load matched users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Matches'),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _matchedUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No matches found'));
          } else {
            final matches = snapshot.data!;
            return ListView.builder(
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                return ListTile(
                  title: Text(match['user']!),
                  subtitle: Text(match['keyword']!),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.chat,
                      arguments: usercom,
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
