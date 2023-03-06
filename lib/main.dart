import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hook_mobile_scanner/hook_mobile_scanner.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.deepPurple),
      home: const HomePage(),
    );
  }
}

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const QRScannerPage(),
                  ));
                },
                child: const Text('Pressed'))
          ],
        ),
      ),
    );
  }
}

gradientBox() => BoxDecoration(
      gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade400],
          begin: const Alignment(0, -1),
          end: const Alignment(0, 1)),
      borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
      // boxShadow: const [
      //   BoxShadow(
      //       color: Colors.grey, offset: Offset(0, 5), blurRadius: 5.0),
      // ],
    );

class GreyContainer extends StatelessWidget {
  const GreyContainer({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      // decoration: BoxDecoration(
      //   color: Colors.grey.shade200.withOpacity(0.3),
      // ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 8.0),
          const Icon(
            Icons.qr_code_2_outlined,
            size: 40.0,
          ),
          const SizedBox(width: 8.0),
          Text(content,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}

class QRScannerPage extends HookWidget {
  const QRScannerPage({super.key});

  static double kMarginGap = 24.0;

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final cameraRect = Size(deviceSize.width * 0.9, deviceSize.height * 0.65);

    final scanWindow = Rect.fromCenter(
      center: cameraRect.center(Offset.zero),
      width: 200,
      height: 200,
    );

    final scannerController = useMobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
      autoStart: true,
    );
    final arguments = useState<MobileScannerArguments?>(null);
    final barcode = useRef<Barcode?>(null);
    final capture = useState<BarcodeCapture?>(null);
    final showScanner = useState(false);

    return Scaffold(
      body: Center(
        child: Container(
          decoration: gradientBox(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                  flex: 1,
                  child: GreyContainer(
                    content: 'good morning',
                  )),
              Container(
                width: cameraRect.width,
                height: cameraRect.height,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(
                        color: Colors.white.withAlpha(200), width: 5)),
                child: showScanner.value
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        clipBehavior: Clip.antiAlias,
                        child: QRScanner(
                          rect: scanWindow,
                          controller: scannerController,
                          arguments: arguments,
                          barcode: barcode,
                          capture: capture,
                        ),
                      )
                    : const Text('Click to activate QR scanner'),
              ),
              Expanded(
                flex: 1,
                child: GreyContainer(
                  content: barcode.value != null
                      ? barcode.value!.displayValue!
                      : 'none',
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showScanner.value = !showScanner.value;
        },
        child: showScanner.value == false
            ? const Icon(Icons.camera_outlined)
            : const Icon(Icons.close_outlined),
      ),
    );
  }
}

class QRScanner extends HookWidget {
  const QRScanner({
    super.key,
    required this.rect,
    required this.controller,
    required this.arguments,
    required this.barcode,
    required this.capture,
  });

  final Rect rect;
  final MobileScannerController controller;
  final ValueNotifier<MobileScannerArguments?> arguments;
  final ValueNotifier<BarcodeCapture?> capture;
  final ObjectRef<Barcode?> barcode;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          fit: BoxFit.cover,
          scanWindow: rect,
          controller: controller,
          onScannerStarted: (args) {
            if (args != null) arguments.value = args;
          },
          onDetect: (captured) {
            capture.value = captured;
            barcode.value = captured.barcodes.first;
          },
        ),
        CustomPaint(
          painter: ScannerOverlay(rect),
        )
      ],
    );
  }
}

class ScannerOverlay extends CustomPainter {
  ScannerOverlay(this.scanWindow);

  final Rect scanWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.largest);
    final cutoutPath = Path()..addRect(scanWindow);

    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
