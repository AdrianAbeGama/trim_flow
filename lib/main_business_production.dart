import 'package:trim_flow/app/view/app.dart';
import 'package:trim_flow/bootstrap.dart';
import 'package:trim_flow/core/app_mode/bootstrap_mode.dart';

void main() {
  setCurrentBootstrapMode(BootstrapMode.business);
  bootstrap(() => const App(bootstrapMode: BootstrapMode.business));
}
