import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class User {
  final String id;
  final String name;
  final DateTime dateOfBirth;
  final String imageUrl;

  User({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.imageUrl,
  });
}

class Users with ChangeNotifier {
  List<User> _list = [];

  List<User> get list {
    return _list;
  }

  Future<void> getUsers() async {
    final url =
        Uri.parse("https://fir-5bdbf-default-rtdb.firebaseio.com/users.json");

    final response = await http.get(url);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    List<User> users = [];

    data.forEach((key, value) {
      users.add(
        User(
          id: key,
          name: value['name'],
          dateOfBirth: DateTime.parse(value['dateOfBirth']),
          imageUrl: value['imageUrl'],
        ),
      );
    });

    _list = users.reversed.toList();
    notifyListeners();
  }

  Future<void> addUser(User user) async {
    final url =
        Uri.parse("https://fir-5bdbf-default-rtdb.firebaseio.com/users.json");

    final response = await http.post(
      url,
      body: jsonEncode(
        {
          'name': user.name,
          'dateOfBirth': DateFormat('yyyy-MM-dd').format(user.dateOfBirth),
          'imageUrl': user.imageUrl,
        },
      ),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _list.add(User(
      id: data['name'],
      name: user.name,
      dateOfBirth: user.dateOfBirth,
      imageUrl: user.imageUrl,
    ));
    notifyListeners();
  }

  Future<void> editUser(String id, User user) async {
    final url = Uri.parse(
        "https://fir-5bdbf-default-rtdb.firebaseio.com/users/$id.json");

    final response = await http.patch(
      url,
      body: jsonEncode(
        {
          'name': user.name,
          'dateOfBirth': DateFormat('yyyy-MM-dd').format(user.dateOfBirth),
          'imageUrl': user.imageUrl,
        },
      ),
    );
    final currentUserIndex = _list.indexWhere((user) => user.id == id);
    _list[currentUserIndex] = user;
    notifyListeners();
  }

  Future<void> deleteUser(String id) async {
    final url = Uri.parse(
        "https://fir-5bdbf-default-rtdb.firebaseio.com/users/$id.json");

    final response = await http.delete(url);
    _list.removeWhere((user) => user.id == id);
    notifyListeners();
  }
}
