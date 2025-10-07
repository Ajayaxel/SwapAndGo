// profile_image_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swap_app/repo/profile_image_repository.dart';
import 'profile_image_event.dart';
import 'profile_image_state.dart';

class ProfileImageBloc extends Bloc<ProfileImageEvent, ProfileImageState> {
  final ProfileImageRepository repository;

  ProfileImageBloc({required this.repository}) : super(ProfileImageInitial()) {
    on<UploadProfileImageEvent>(_onUploadProfileImage);
    on<FetchProfileEvent>(_onFetchProfile);
    on<DeleteProfileImageEvent>(_onDeleteProfileImage);
    on<ResetProfileImageEvent>(_onResetProfileImage);
  }

  /// Handle profile image upload
  Future<void> _onUploadProfileImage(
    UploadProfileImageEvent event,
    Emitter<ProfileImageState> emit,
  ) async {
    emit(ProfileImageLoading());
    
    try {
      final response = await repository.uploadProfileImage(event.imageFile);
      
      if (response.success && response.data != null) {
        emit(ProfileImageUploadSuccess(
          imageUrl: response.data!.profileImageUrl,
          message: response.message,
        ));
      } else {
        emit(ProfileImageError(message: response.message));
      }
    } on ProfileImageException catch (e) {
      emit(ProfileImageError(message: e.message));
    } catch (e) {
      emit(ProfileImageError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Handle profile fetch
  Future<void> _onFetchProfile(
    FetchProfileEvent event,
    Emitter<ProfileImageState> emit,
  ) async {
    emit(ProfileImageLoading());
    
    try {
      final response = await repository.fetchCustomerProfile();
      
      if (response.success && response.data != null) {
        emit(ProfileImageFetchSuccess(customer: response.data!.customer));
      } else {
        emit(ProfileImageError(message: response.message));
      }
    } on ProfileImageException catch (e) {
      emit(ProfileImageError(message: e.message));
    } catch (e) {
      emit(ProfileImageError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Handle profile image deletion
  Future<void> _onDeleteProfileImage(
    DeleteProfileImageEvent event,
    Emitter<ProfileImageState> emit,
  ) async {
    emit(ProfileImageLoading());
    
    try {
      final response = await repository.deleteProfileImage();
      
      if (response.success) {
        emit(ProfileImageDeleteSuccess(message: response.message));
      } else {
        emit(ProfileImageError(message: response.message));
      }
    } on ProfileImageException catch (e) {
      emit(ProfileImageError(message: e.message));
    } catch (e) {
      emit(ProfileImageError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  /// Handle reset profile image state
  void _onResetProfileImage(
    ResetProfileImageEvent event,
    Emitter<ProfileImageState> emit,
  ) {
    emit(ProfileImageInitial());
  }
}
