import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'add_screen.dart';
import '../models/user.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = "/home";

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Users"), actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(AddScreen.routeName);
          },
          icon: const Icon(Icons.add),
        ),
      ]),
      body: FutureBuilder(
        future: Provider.of<Users>(context, listen: false).getUsers(),
        builder: (ctx, data) {
          if (data.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Consumer<Users>(
            builder: (ctx, users, data) {
              return ListView.builder(
                itemCount: users.list.length,
                itemBuilder: (ctx, index) {
                  return Dismissible(
                    key: ValueKey(users.list[index].id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 10),
                      color: Colors.red,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction) {
                      users.deleteUser(users.list[index].id);
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(users.list[index].imageUrl),
                      ),
                      title: Text(users.list[index].name),
                      subtitle: Text(DateFormat('dd MMMM, yyyy')
                          .format(users.list[index].dateOfBirth)),
                      trailing: IconButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            AddScreen.routeName,
                            arguments: users.list[index],
                          );
                        },
                        icon: const Icon(Icons.edit),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
