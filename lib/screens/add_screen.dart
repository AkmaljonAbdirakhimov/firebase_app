import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';

class AddScreen extends StatefulWidget {
  static const routeName = "/add-user";

  const AddScreen({Key? key}) : super(key: key);

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  DateTime? _selectedDate;
  bool isLoading = false;
  String? currentUserId;
  final _formKey = GlobalKey<FormState>();
  final _imageUrlController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

    final currentUserData = ModalRoute.of(context)!.settings.arguments;
    if (currentUserData != null) {
      currentUserId = (currentUserData as User).id;
      _nameController.text = (currentUserData).name;
      _imageUrlController.text = (currentUserData).imageUrl;
      _selectedDate = (currentUserData).dateOfBirth;
    }
  }

  void showDateOfBirthPicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ??
          DateTime(
            DateTime.now().year - 18,
            DateTime.now().month,
            DateTime.now().day,
          ),
      firstDate: DateTime(1950),
      lastDate: DateTime(
        DateTime.now().year - 18,
        DateTime.now().month,
        DateTime.now().day,
      ),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _submitForm() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          backgroundColor: Theme.of(context).errorColor,
          content: const Text(
            "Tug'ilgan kunni kiriting",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_formKey.currentState!.validate()) {
      final user = User(
        id: currentUserId ?? '',
        name: _nameController.text,
        dateOfBirth: _selectedDate!,
        imageUrl: _imageUrlController.text,
      );
      setState(() {
        isLoading = true;
      });
      if (currentUserId != null) {
        // edit
        await Provider.of<Users>(context, listen: false)
            .editUser(currentUserId!, user);
      } else {
        // add
        await Provider.of<Users>(context, listen: false).addUser(user);
      }
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentUserId != null ? "Edit User" : "Add User"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        hintText: "Ism",
                      ),
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ismingizni kiriting!';
                        }

                        return null;
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? "Tug'ilgan kun tanlanmagan!"
                                : "Tug'ilgan kun: ${DateFormat("dd MMMM, yyyy").format(_selectedDate!)}",
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            showDateOfBirthPicker(context);
                          },
                          child: const Text('KUNNI TANLASH'),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1),
                          ),
                          child: _imageUrlController.text.isNotEmpty
                              ? Image.network(_imageUrlController.text,
                                  fit: BoxFit.cover)
                              : const Text(
                                  'Rasm URL kiriting!',
                                ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                              decoration:
                                  const InputDecoration(hintText: "Rasm URL"),
                              keyboardType: TextInputType.url,
                              controller: _imageUrlController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Rasm URL kiriting';
                                } else if (!value.startsWith('http')) {
                                  return 'To\'g\'ri Rasm URL kiriting!';
                                }

                                return null;
                              },
                              onEditingComplete: () {
                                setState(() {});
                              }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _submitForm();
                      },
                      child: Text(
                          currentUserId != null ? "YANGILASH" : "KIRITISH"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
