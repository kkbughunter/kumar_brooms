// lib/screens/user_manage/user_manage_screen.dart
import 'package:flutter/material.dart';
import 'package:kumar_brooms/model/UserPermission.dart';
import 'package:kumar_brooms/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';

class UserManageScreen extends StatefulWidget {
  const UserManageScreen({super.key});

  @override
  State<UserManageScreen> createState() => _UserManageScreenState();
}

class _UserManageScreenState extends State<UserManageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedRole;

  void _showUserDialog(UserPermission user, {bool isNew = false}) {
    _nameController.text = user.name ?? '';
    _phoneController.text = user.phone ?? '';
    _selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isNew ? 'Add User Details' : 'Update User Details'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: ['employee', 'manager', 'owner', 'worker']
                        .map((role) => DropdownMenuItem<String>(
                              value: role,
                              child: Text(role),
                            ))
                        .toList(),
                    onChanged: (value) => _selectedRole = value,
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final updatedUser = UserPermission(
                    uid: user.uid,
                    isActive: true,
                    name: _nameController.text,
                    phone: _phoneController.text,
                    role: _selectedRole!,
                  );
                  if (isNew) {
                    Provider.of<UserViewModel>(context, listen: false)
                        .addUserDetails(user.uid, updatedUser)
                        .then((_) {
                      Provider.of<UserViewModel>(context, listen: false)
                          .updateUserPermission(user.uid, true);
                    });
                  } else {
                    Provider.of<UserViewModel>(context, listen: false)
                        .updateUserDetails(user.uid, updatedUser);
                  }
                  Navigator.pop(context);
                  _clearForm();
                }
              },
              child: Text(isNew ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _selectedRole = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<UserViewModel>(context, listen: false)
                  .fetchAllUsers();
            },
          ),
        ],
      ),
      body: Consumer<UserViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (viewModel.errorMessage != null) {
            return Center(child: Text(viewModel.errorMessage!));
          } else if (viewModel.users.isEmpty) {
            return const Center(child: Text('No users available.'));
          } else {
            return ListView.builder(
              itemCount: viewModel.users.length,
              itemBuilder: (context, index) {
                final user = viewModel.users[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('UserID: ${user.uid}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Status: ${user.isActive ? 'Active' : 'Inactive'}'),
                        if (user.name != null) Text('Name: ${user.name}'),
                        if (user.role != null) Text('Role: ${user.role}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (user.isActive && user.name != null)
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showUserDialog(user),
                          ),
                        if (user.isActive && user.name != null)
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete User Details'),
                                  content: const Text(
                                      'Are you sure you want to delete this user\'s details?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Provider.of<UserViewModel>(context,
                                                listen: false)
                                            .deleteUserDetails(user.uid);
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        IconButton(
                          icon: Icon(
                            user.isActive ? Icons.lock : Icons.lock_open,
                            color: user.isActive ? Colors.red : Colors.green,
                          ),
                          onPressed: () {
                            if (user.isActive) {
                              Provider.of<UserViewModel>(context, listen: false)
                                  .updateUserPermission(user.uid, false);
                            } else {
                              if (user.name == null) {
                                _showUserDialog(user, isNew: true);
                              } else {
                                Provider.of<UserViewModel>(context,
                                        listen: false)
                                    .updateUserPermission(user.uid, true);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: user.isActive && user.name != null
                        ? () => _showUserDialog(user)
                        : null,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
