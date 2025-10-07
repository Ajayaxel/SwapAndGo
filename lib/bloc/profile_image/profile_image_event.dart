// profile_image_event.dart
import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class ProfileImageEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event to upload a profile image
class UploadProfileImageEvent extends ProfileImageEvent {
  final File imageFile;

  UploadProfileImageEvent({required this.imageFile});

  @override
  List<Object?> get props => [imageFile];
}

/// Event to fetch customer profile (including profile image)
class FetchProfileEvent extends ProfileImageEvent {}

/// Event to delete profile image
class DeleteProfileImageEvent extends ProfileImageEvent {}

/// Event to reset profile image state
class ResetProfileImageEvent extends ProfileImageEvent {}
