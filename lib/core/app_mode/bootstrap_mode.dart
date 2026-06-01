import 'package:core/core.dart';

enum BootstrapMode {
  client('io.supabase.trimflow://login-callback'),
  business('io.supabase.trimflowbusiness://login-callback');

  const BootstrapMode(this.oauthRedirectUrl);

  final String oauthRedirectUrl;

  AppMode get asAppMode => switch (this) {
        BootstrapMode.client => AppMode.client,
        BootstrapMode.business => AppMode.barber,
      };

  bool get isBusiness => this == BootstrapMode.business;
}

BootstrapMode _currentBootstrapMode = BootstrapMode.client;

BootstrapMode get currentBootstrapMode => _currentBootstrapMode;

void setCurrentBootstrapMode(BootstrapMode mode) {
  _currentBootstrapMode = mode;
}
