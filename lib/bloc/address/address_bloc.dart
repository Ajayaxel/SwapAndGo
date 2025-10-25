// address_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/bloc/address/address_event.dart';
import 'package:swap_app/bloc/address/address_state.dart';
import 'package:swap_app/repo/address_repository.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressRepository _addressRepository;

  AddressBloc({required AddressRepository addressRepository})
      : _addressRepository = addressRepository,
        super(AddressInitial()) {
    on<FetchAddressesEvent>(_onFetchAddresses);
    on<RefreshAddressesEvent>(_onRefreshAddresses);
    on<SetDefaultAddressEvent>(_onSetDefaultAddress);
    on<DeleteAddressEvent>(_onDeleteAddress);
    on<CreateAddressEvent>(_onCreateAddress);
    on<UpdateAddressEvent>(_onUpdateAddress);
  }

  Future<void> _onFetchAddresses(
      FetchAddressesEvent event, Emitter<AddressState> emit) async {
    emit(AddressLoading());

    try {
      final addresses = await _addressRepository.fetchAddresses();
      
      if (addresses.isEmpty) {
        emit(AddressEmpty(message: "No addresses found"));
      } else {
        emit(AddressSuccess(addresses: addresses));
      }
    } on AddressApiException catch (e) {
      if (e.statusCode == 401) {
        emit(AddressUnauthenticated(message: e.message));
      } else {
        emit(AddressError(message: e.message, statusCode: e.statusCode));
      }
    } catch (e) {
      emit(AddressError(message: "An unexpected error occurred: ${e.toString()}"));
    }
  }

  Future<void> _onRefreshAddresses(
      RefreshAddressesEvent event, Emitter<AddressState> emit) async {
    emit(AddressLoading());

    try {
      final addresses = await _addressRepository.fetchAddresses();
      
      if (addresses.isEmpty) {
        emit(AddressEmpty(message: "No addresses found"));
      } else {
        emit(AddressSuccess(addresses: addresses));
      }
    } on AddressApiException catch (e) {
      if (e.statusCode == 401) {
        emit(AddressUnauthenticated(message: e.message));
      } else {
        emit(AddressError(message: e.message, statusCode: e.statusCode));
      }
    } catch (e) {
      emit(AddressError(message: "An unexpected error occurred: ${e.toString()}"));
    }
  }

  Future<void> _onSetDefaultAddress(
      SetDefaultAddressEvent event, Emitter<AddressState> emit) async {
    try {
      // This would typically call an API to set default address
      // For now, we'll just refresh the addresses
      add(RefreshAddressesEvent());
    } catch (e) {
      emit(AddressError(message: "Failed to set default address: ${e.toString()}"));
    }
  }

  Future<void> _onDeleteAddress(
      DeleteAddressEvent event, Emitter<AddressState> emit) async {
    emit(AddressLoading());

    try {
      await _addressRepository.deleteAddress(event.addressId);
      emit(AddressDeleteSuccess(
        message: "Address deleted successfully",
        addresses: [], // Will be refreshed
      ));
      // Refresh addresses after successful deletion
      add(RefreshAddressesEvent());
    } on AddressApiException catch (e) {
      if (e.statusCode == 401) {
        emit(AddressUnauthenticated(message: e.message));
      } else {
        emit(AddressError(message: e.message, statusCode: e.statusCode));
      }
    } catch (e) {
      emit(AddressError(message: "An unexpected error occurred: ${e.toString()}"));
    }
  }

  Future<void> _onCreateAddress(
      CreateAddressEvent event, Emitter<AddressState> emit) async {
    emit(AddressCreateLoading());

    try {
      final address = await _addressRepository.createAddress(event.request);
      emit(AddressCreateSuccess(
        message: "Address created successfully",
        address: address,
      ));
      // Refresh addresses after successful creation
      add(RefreshAddressesEvent());
    } on AddressApiException catch (e) {
      if (e.statusCode == 401) {
        emit(AddressUnauthenticated(message: e.message));
      } else {
        emit(AddressError(message: e.message, statusCode: e.statusCode));
      }
    } catch (e) {
      emit(AddressError(message: "An unexpected error occurred: ${e.toString()}"));
    }
  }

  Future<void> _onUpdateAddress(
      UpdateAddressEvent event, Emitter<AddressState> emit) async {
    emit(AddressUpdateLoading());

    try {
      final address = await _addressRepository.updateAddress(event.addressId, event.request);
      emit(AddressUpdateSuccess(
        message: "Address updated successfully",
        address: address,
      ));
      // Refresh addresses after successful update
      add(RefreshAddressesEvent());
    } on AddressApiException catch (e) {
      if (e.statusCode == 401) {
        emit(AddressUnauthenticated(message: e.message));
      } else {
        emit(AddressError(message: e.message, statusCode: e.statusCode));
      }
    } catch (e) {
      emit(AddressError(message: "An unexpected error occurred: ${e.toString()}"));
    }
  }
}
