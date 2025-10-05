part of 'qrcode_bloc.dart';

sealed class QrcodeEvent extends Equatable {
  const QrcodeEvent();

  @override
  List<Object> get props => [];
}

class QrCodeScanned extends QrcodeEvent {
  final String qrCode;

  const QrCodeScanned({required this.qrCode});

  @override
  List<Object> get props => [qrCode];
}

class QrCodeCheckoutRequested extends QrcodeEvent {
  final String qrCode;

  const QrCodeCheckoutRequested({required this.qrCode});

  @override
  List<Object> get props => [qrCode];
}

class QrCodeReset extends QrcodeEvent {
  const QrCodeReset();
}
