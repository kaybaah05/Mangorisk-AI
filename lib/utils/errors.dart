String userFriendlyError(Object error) {
  final message = error.toString();
  final lower = message.toLowerCase();

  final isAuthInvalid =
      lower.contains('invalid login credentials') ||
      lower.contains('invalid credentials') ||
      lower.contains('invalid login') ||
      lower.contains('invalid_password') ||
      lower.contains('invalid_email') ||
      lower.contains('invalid email') ||
      lower.contains('email not confirmed');

  final isNetworkIssue =
      lower.contains('socketexception') ||
      lower.contains('failed host lookup') ||
      lower.contains('no address associated with hostname') ||
      lower.contains('connection refused') ||
      lower.contains('network error') ||
      lower.contains('connection error');

  final isNoInternet =
      lower.contains('failed host lookup') ||
      lower.contains('no address associated with hostname');

  if (isNoInternet) {
    return 'No internet connection. Check your network and try again.';
  }

  if (isAuthInvalid) {
    return 'Invalid credentials';
  }

  if (isNetworkIssue) {
    return 'error';
  }

  return message;
}
