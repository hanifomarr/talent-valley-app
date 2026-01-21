import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:talent_valley_app/providers/app_state.dart';
import 'package:talent_valley_app/screens/quiz/quiz_screen.dart';
import 'package:talent_valley_app/theme/app_theme.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;
  bool _showManualEntry = false;
  final _manualCodeController = TextEditingController();

  @override
  void dispose() {
    controller?.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_isProcessing && scanData.code != null) {
        _handleQRCode(scanData.code!);
      }
    });
  }

  Future<void> _handleQRCode(String code) async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);
    
    controller?.pauseCamera();
    
    final appState = context.read<AppState>();
    final success = await appState.joinSession(code);
    
    if (mounted) {
      if (success) {
        // Navigate to quiz screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const QuizScreen()),
        );
      } else {
        setState(() => _isProcessing = false);
        controller?.resumeCamera();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid QR code. Please try again.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _handleManualEntry() async {
    final code = _manualCodeController.text.trim();
    if (code.isEmpty) return;
    
    await _handleQRCode(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() => _showManualEntry = !_showManualEntry);
            },
            icon: Icon(
              _showManualEntry ? Icons.qr_code_scanner : Icons.keyboard,
            ),
            label: Text(_showManualEntry ? 'Scan' : 'Manual'),
          ),
        ],
      ),
      body: _showManualEntry ? _buildManualEntry() : _buildScanner(),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        // QR Scanner
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
            borderColor: AppTheme.primaryColor,
            borderRadius: 16,
            borderLength: 30,
            borderWidth: 8,
            cutOutSize: 300,
          ),
        ),
        
        // Instructions
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Position QR code within the frame',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                  textAlign: TextAlign.center,
                ),
                if (_isProcessing) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualEntry() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          
          const Icon(
            Icons.edit,
            size: 64,
            color: AppTheme.primaryColor,
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Enter Session Code',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Type in the session code manually',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          TextField(
            controller: _manualCodeController,
            decoration: const InputDecoration(
              labelText: 'Session Code',
              hintText: 'Enter code here',
              prefixIcon: Icon(Icons.code),
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handleManualEntry,
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Join Session'),
            ),
          ),
        ],
      ),
    );
  }
}
