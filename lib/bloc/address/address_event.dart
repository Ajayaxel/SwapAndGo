// address_event.dart
import 'package:swap_app/model/address_models.dart';

abstract class AddressEvent {}

class FetchAddressesEvent extends AddressEvent {}

class RefreshAddressesEvent extends AddressEvent {}

class SetDefaultAddressEvent extends AddressEvent {
  final int addressId;

  SetDefaultAddressEvent({required this.addressId});
}

class DeleteAddressEvent extends AddressEvent {
  final int addressId;

  DeleteAddressEvent({required this.addressId});
}

class CreateAddressEvent extends AddressEvent {
  final CreateAddressRequest request;

  CreateAddressEvent({required this.request});
}

class UpdateAddressEvent extends AddressEvent {
  final int addressId;
  final UpdateAddressRequest request;

  UpdateAddressEvent({required this.addressId, required this.request});
}
