part of 'qrcode_bloc.dart';

sealed class QrcodeState extends Equatable {
  const QrcodeState();
  
  @override
  List<Object> get props => [];
}

final class QrcodeInitial extends QrcodeState {}

final class QrcodeLoading extends QrcodeState {
  final String qrCode;

  const QrcodeLoading({required this.qrCode});

  @override
  List<Object> get props => [qrCode];
}

final class QrcodeSuccess extends QrcodeState {
  final String qrCode;
  final Map<String, dynamic>? data;
  final String? message;

  const QrcodeSuccess({
    required this.qrCode,
    this.data,
    this.message,
  });

  @override
  List<Object> get props => [qrCode, data ?? {}, message ?? ''];
}

final class QrcodeError extends QrcodeState {
  final String qrCode;
  final String error;

  const QrcodeError({
    required this.qrCode,
    required this.error,
  });

  @override
  List<Object> get props => [qrCode, error];
}
