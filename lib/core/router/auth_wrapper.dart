import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthWrapper extends StatelessWidget {
  final Widget authenticatedRoute;
  final Widget unauthenticatedRoute;

  const AuthWrapper({
    super.key,
    required this.authenticatedRoute,
    required this.unauthenticatedRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading indicator while initial auth check is happening
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Use isAuthenticated getter which checks both Firebase and MongoDB auth
        if (authProvider.isAuthenticated) {
          return authenticatedRoute;
        }

        // If not authenticated or any auth error, show login screen
        return unauthenticatedRoute;
      },
    );
  }
}
