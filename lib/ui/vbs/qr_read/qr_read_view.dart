import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:podd_app/components/progress_indicator.dart';
import 'package:podd_app/ui/vbs/qr_read/qr_read_view_model.dart';
import 'package:stacked/stacked.dart';

class QrReadView extends StatelessWidget {
  const QrReadView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<QrReadViewModel>.reactive(
      viewModelBuilder: () => QrReadViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(title: const Text('QR Code Login')),
        body: Stack(
          children: [
            MobileScanner(
              controller: MobileScannerController(
                  facing: CameraFacing.back, torchEnabled: false),
              onDetect: (barcodeCapture) async {
                // check barcodeCapture.barcodes length
                if (barcodeCapture.barcodes.isEmpty) {
                  Navigator.pop(context, 'Failed to scan QRCode');
                } else {
                  final String? code = barcodeCapture.barcodes.first.rawValue;
                  if (code == null) {
                    Navigator.pop(context, 'Failed to scan QRCode');
                  } else {
                    // final error = await viewModel.authenticate(code);
                    print(code);
                    
                    Navigator.pop(context, 'Enrollment complete');
                  }
                }
              },
            ),
            _framer(context),
            if (viewModel.isBusy) _waitingProgress(context),
          ],
        ),
      ),
    );
  }

  Center _waitingProgress(BuildContext context) {
    return Center(
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.black45,
        ),
        padding: EdgeInsets.all(MediaQuery.of(context).size.width / 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            OhtkProgressIndicator(size: 80),
            SizedBox(height: 16),
            Text(
              "Please wait...",
              textScaleFactor: 1.3,
              style: TextStyle(
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  Center _framer(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.5,
        height: 250,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.blue.shade300,
              width: 3,
            ),
          ),
        ),
      ),
    );
  }
}
