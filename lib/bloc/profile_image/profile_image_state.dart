// profile_image_state.dart
import 'package:equatable/equatable.dart';
import 'package:swap_app/model/profile_image_models.dart';

abstract class ProfileImageState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Initial state
class ProfileImageInitial extends ProfileImageState {}

/// Loading state
class ProfileImageLoading extends ProfileImageState {}

/// Upload success state
class ProfileImageUploadSuccess extends ProfileImageState {
  final String imageUrl;
  final String message;

  ProfileImageUploadSuccess({
    required this.imageUrl,
    required this.message,
  });

  @override
  List<Object?> get props => [imageUrl, message];
}

/// Fetch success state
class ProfileImageFetchSuccess extends ProfileImageState {
  final CustomerProfile customer;

  ProfileImageFetchSuccess({required this.customer});

  @override
  List<Object?> get props => [customer];
}

/// Delete success state
class ProfileImageDeleteSuccess extends ProfileImageState {
  final String message;

  ProfileImageDeleteSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Error state
class ProfileImageError extends ProfileImageState {
  final String message;

  ProfileImageError({required this.message});

  @override
  List<Object?> get props => [message];
}
