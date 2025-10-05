import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../services/qr_code_service.dart';

part 'qrcode_event.dart';
part 'qrcode_state.dart';

class QrcodeBloc extends Bloc<QrcodeEvent, QrcodeState> {
  final QrCodeService _qrCodeService;

  QrcodeBloc({QrCodeService? qrCodeService}) 
      : _qrCodeService = qrCodeService ?? QrCodeService(),
        super(QrcodeInitial()) {
    on<QrCodeScanned>(_onQrCodeScanned);
    on<QrCodeCheckoutRequested>(_onQrCodeCheckoutRequested);
    on<QrCodeReset>(_onQrCodeReset);
  }

  void _onQrCodeScanned(QrCodeScanned event, Emitter<QrcodeState> emit) {
    // Validate QR code format
    if (!_qrCodeService.isValidQrCode(event.qrCode)) {
      emit(QrcodeError(
        qrCode: event.qrCode,
        error: 'Invalid QR code format',
      ));
      return;
    }

    // Emit loading state
    emit(QrcodeLoading(qrCode: event.qrCode));
  }

  Future<void> _onQrCodeCheckoutRequested(
    QrCodeCheckoutRequested event, 
    Emitter<QrcodeState> emit,
  ) async {
    try {
      // Emit loading state
      emit(QrcodeLoading(qrCode: event.qrCode));

      // Call API to process QR code checkout
      final response = await _qrCodeService.processQrCheckout(event.qrCode);

      if (response.success) {
        emit(QrcodeSuccess(
          qrCode: event.qrCode,
          data: response.data,
          message: response.message,
        ));
      } else {
        emit(QrcodeError(
          qrCode: event.qrCode,
          error: response.error ?? 'Checkout failed',
        ));
      }
    } catch (e) {
      emit(QrcodeError(
        qrCode: event.qrCode,
        error: 'Unexpected error: $e',
      ));
    }
  }

  void _onQrCodeReset(QrCodeReset event, Emitter<QrcodeState> emit) {
    emit(QrcodeInitial());
  }
}
