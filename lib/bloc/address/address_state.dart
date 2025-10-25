// address_state.dart
import 'package:swap_app/model/address_models.dart';

abstract class AddressState {}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressSuccess extends AddressState {
  final List<Address> addresses;

  AddressSuccess({required this.addresses});
}

class AddressError extends AddressState {
  final String message;
  final int? statusCode;

  AddressError({required this.message, this.statusCode});
}

class AddressUnauthenticated extends AddressState {
  final String message;

  AddressUnauthenticated({required this.message});
}

class AddressEmpty extends AddressState {
  final String message;

  AddressEmpty({required this.message});
}

class AddressDeleteSuccess extends AddressState {
  final String message;
  final List<Address> addresses;

  AddressDeleteSuccess({required this.message, required this.addresses});
}

class AddressCreateSuccess extends AddressState {
  final String message;
  final Address address;

  AddressCreateSuccess({required this.message, required this.address});
}

class AddressCreateLoading extends AddressState {}

class AddressUpdateSuccess extends AddressState {
  final String message;
  final Address address;

  AddressUpdateSuccess({required this.message, required this.address});
}

class AddressUpdateLoading extends AddressState {}
