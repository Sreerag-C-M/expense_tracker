import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../data/services/graphql_service.dart';
import '../../data/queries.dart';
import '../../routes/app_routes.dart';

class AuthController extends GetxController {
  final GraphQLService _gqlService = Get.find<GraphQLService>();
  final box = GetStorage();

  var isLoading = false.obs;

  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();

  final signupNameController = TextEditingController();
  final signupEmailController = TextEditingController();
  final signupPasswordController = TextEditingController();
  final signupConfirmPasswordController = TextEditingController();

  Future<void> login() async {
    if (loginEmailController.text.isEmpty ||
        loginPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final result = await _gqlService.performMutation(
        GqlQueries.login,
        variables: {
          'email': loginEmailController.text,
          'password': loginPasswordController.text,
        },
      );

      if (result.hasException) {
        String message = result.exception!.graphqlErrors.isNotEmpty
            ? result.exception!.graphqlErrors.first.message
            : 'Login failed';
        Get.snackbar(
          'Error',
          message,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      } else {
        if (result.data != null && result.data!['login'] != null) {
          final token = result.data!['login']['token'];
          await box.write('token', token);
          Get.offAllNamed(Routes.DASHBOARD);
        } else {
          Get.snackbar(
            'Error',
            'Invalid response from server',
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup() async {
    if (signupNameController.text.isEmpty ||
        signupEmailController.text.isEmpty ||
        signupPasswordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    if (signupPasswordController.text != signupConfirmPasswordController.text) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }
    isLoading.value = true;
    try {
      final result = await _gqlService.performMutation(
        GqlQueries.signup,
        variables: {
          'name': signupNameController.text,
          'email': signupEmailController.text,
          'password': signupPasswordController.text,
        },
      );

      if (result.hasException) {
        String message = result.exception!.graphqlErrors.isNotEmpty
            ? result.exception!.graphqlErrors.first.message
            : 'Signup failed';
        Get.snackbar(
          'Error',
          message,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
        );
      } else {
        if (result.data != null && result.data!['signup'] != null) {
          final token = result.data!['signup']['token'];
          await box.write('token', token);
          Get.offAllNamed(Routes.DASHBOARD);
        } else {
          Get.snackbar(
            'Error',
            'Invalid response from server',
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    box.remove('token');
    Get.offAllNamed(Routes.LOGIN);
  }
}
