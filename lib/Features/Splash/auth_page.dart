import 'package:delivery/Core/Enum/user_type.dart';
import 'package:delivery/Features/Splash/Cubit/auth_cubit.dart';
import 'package:delivery/Features/Splash/Cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Profile/users_page.dart';

Future<bool> showAuthDialog(BuildContext context) async {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  UserType? selectedUserType;

  bool isSignup = false;
  bool passed = false;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return BlocProvider(
        create: (_) => AuthCubit(),
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              passed = true;
              Navigator.pop(context);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<AuthCubit>();

            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isSignup ? 'Signup' : 'Login'),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isSignup = !isSignup;
                          });
                        },
                        child: Text(
                          isSignup ? 'Switch to Login' : 'Switch to Signup',
                        ),
                      ),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSignup)
                            TextFormField(
                              controller: nameController,
                              decoration:
                                  const InputDecoration(labelText: 'Name'),
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Enter your name'
                                  : null,
                            ),
                          if (isSignup) const SizedBox(height: 10),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(labelText: 'Email'),
                            validator: (value) =>
                                value == null || value.isEmpty ? 'Enter email' : null,
                          ),
                          if (!isSignup) const SizedBox(height: 10),
                          if (isSignup)
                            TextFormField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Phone Number',
                              ),
                              validator: (value) => value == null || value.isEmpty
                                  ? 'Enter phone number'
                                  : null,
                            ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(labelText: 'Password'),
                            validator: (value) => value == null || value.length < 6
                                ? 'Password must be at least 6 characters'
                                : null,
                          ),
                          if (isSignup) const SizedBox(height: 10),
                          if (isSignup)
                            DropdownButtonFormField<UserType>(
                              decoration: const InputDecoration(
                                labelText: 'User Type',
                              ),
                              value: selectedUserType,
                              items: UserType.values.map((userType) {
                                return DropdownMenuItem(
                                  value: userType,
                                  child: Row(
                                    children: [
                                      Icon(userType.icon, color: userType.color),
                                      const SizedBox(width: 10),
                                      Text(userType.displayName),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                selectedUserType = value;
                              },
                              validator: (value) =>
                                  value == null ? 'Select user type' : null,
                            ),
                          if (state is AuthLoading)
                            const Padding(
                              padding: EdgeInsets.only(top: 16.0),
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        passed = false;
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() == true) {
                                if (isSignup) {
                                  cubit.signup(
                                    name: nameController.text,
                                    email: emailController.text,
                                    phone: phoneController.text,
                                    password: passwordController.text,
                                    userType: selectedUserType!,
                                  );
                                } else {
                                  cubit.login(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );
                                }
                              }
                            },
                      child: Text(isSignup ? 'Signup' : 'Login'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      );
    },
  );

  return passed;
}
