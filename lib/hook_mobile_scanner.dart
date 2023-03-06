import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

MobileScannerController useMobileScannerController({
  required CameraFacing facing,
  required bool torchEnabled,
  required bool autoStart,
}) {
  return use(_MobileScannerControllerHook(
    facing: facing,
    torchEnabled: torchEnabled,
    autoStart: autoStart,
  ));
}

class _MobileScannerControllerHook extends Hook<MobileScannerController> {
  const _MobileScannerControllerHook({
    this.facing = CameraFacing.back,
    this.torchEnabled = true,
    this.autoStart = true,
  });

  final CameraFacing facing;
  final bool torchEnabled;
  final bool autoStart;

  @override
  _MobileScannerControllerState createState() =>
      _MobileScannerControllerState();
}

class _MobileScannerControllerState
    extends HookState<MobileScannerController, _MobileScannerControllerHook> {
  late final MobileScannerController _controller = MobileScannerController(
    facing: hook.facing,
    torchEnabled: hook.torchEnabled,
    autoStart: hook.autoStart,
  );

  @override
  void initHook() {
    super.initHook();
  }

  @override
  void dispose() {
    _controller.dispose();
  }

  @override
  MobileScannerController build(BuildContext context) {
    return _controller;
  }
}
