import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'pantrylogin_viewmodel.dart';

class PantryloginView extends StackedView<PantryloginViewModel> {
  const PantryloginView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    PantryloginViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title or Logo
            const Text(
              "欢迎来到云宇之洲",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 30),

            // Username TextField
            TextField(
              controller:
                  viewModel.usernameController, // Connect the controller
              decoration: InputDecoration(
                labelText: "用户名",
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Password TextField
            TextField(
              controller:
                  viewModel.passwordController, // Connect the controller
              obscureText: true,
              decoration: InputDecoration(
                labelText: "密码",
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Login Button
            ElevatedButton(
              onPressed: () async {
                await viewModel.handleLogin(context);
              }, // Trigger login logic
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "登入",
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),

            // Or register link
            TextButton(
              onPressed: () {
                viewModel.runPantryregisterLogic();
              },
              child: const Text(
                "还没有账号？快来注册吧~",
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  PantryloginViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      PantryloginViewModel();
}
