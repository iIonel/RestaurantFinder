import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user.dart';
import 'chat.dart';
import 'package:http/http.dart' as http;

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late Future<List<Map<String, String>>> _matchedUsers;
  late String usercom;

  @override
  void initState() {
    super.initState();
    _match();
    _matchedUsers = _fetchMatchedUsers();
  }

  Future<void> _match() async {
    try {
      final response = await http.get(
        Uri.parse('https://us-central1-foodfoodapp-423813.cloudfunctions.net/match'),
      );
      if (response.statusCode == 200) {
        print('Matches created successfully');
      } else {
        throw Exception('Failed to create matches');
      }
    } catch (error) {
      print('Error creating matches: $error');
    }
  }

  Future<List<Map<String, String>>> _fetchMatchedUsers() async {
    final response = await http.get(
      Uri.parse('https://us-central1-foodfoodapp-423813.cloudfunctions.net/matchEmail')
          .replace(queryParameters: {'email': user.getEmail()}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Map<String, String>> matches = [];

      for (var match in data) {
        final userA = match['userA'] as String;
        final userB = match['userB'] as String;
        final keyword = match['keyword'] as String;

        final otherUser = (userA == user.getEmail()) ? userB : userA;
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          otherUserName: usercom,
                        ),
                      ),
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
