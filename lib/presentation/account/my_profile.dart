import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swap_app/bloc/auth_bloc.dart';
import 'package:swap_app/bloc/profile_image/profile_image_bloc.dart';
import 'package:swap_app/bloc/profile_image/profile_image_event.dart';
import 'package:swap_app/bloc/profile_image/profile_image_state.dart';
import 'package:swap_app/bloc/address/address_bloc.dart';
import 'package:swap_app/bloc/address/address_event.dart';
import 'package:swap_app/bloc/address/address_state.dart';
import 'package:swap_app/model/address_models.dart';
import 'package:swap_app/presentation/login/login_screen.dart';
import 'package:swap_app/presentation/account/address_edit_form.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _phoneController = TextEditingController();
  bool _isEditingPhone = false;

  @override
  void initState() {
    super.initState();
    // Fetch profile data when screen loads
    context.read<ProfileImageBloc>().add(FetchProfileEvent());
    // Fetch addresses when screen loads
    context.read<AddressBloc>().add(FetchAddressesEvent());
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _startEditingPhone(String currentPhone) {
    setState(() {
      _isEditingPhone = true;
      _phoneController.text = currentPhone;
    });
  }

  void _cancelEditingPhone() {
    setState(() {
      _isEditingPhone = false;
      _phoneController.clear();
    });
  }

  void _savePhoneNumber() {
    if (_phoneController.text.isNotEmpty) {
      context.read<AuthBloc>().add(
        UpdatePhoneEvent(phone: _phoneController.text),
      );
      setState(() {
        _isEditingPhone = false;
      });
    }
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        final File imageFile = File(image.path);
        context.read<ProfileImageBloc>().add(
          UploadProfileImageEvent(imageFile: imageFile),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _deleteProfileImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Profile Image'),
          content: Text('Are you sure you want to delete your profile image?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<ProfileImageBloc>().add(DeleteProfileImageEvent());
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _createDefaultAddress() {
    // Create a default address with sample data
    // In a real app, this would open a form for the user to enter address details
    final createRequest = CreateAddressRequest(
      addressLine1: "123 Main Street",
      addressLine2: "Apt 1",
      city: "New York",
      state: "NY",
      postalCode: "10001",
      countryId: 1, // Assuming US country ID
      type: "home",
      isDefault: true,
    );

    context.read<AddressBloc>().add(CreateAddressEvent(request: createRequest));
  }

  void _showDeleteAddressDialog(int addressId, String addressText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Address'),
          content: Text('Are you sure you want to delete this address?\n\n$addressText'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AddressBloc>().add(DeleteAddressEvent(addressId: addressId));
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileImageBloc, ProfileImageState>(
          listener: (context, state) {
            if (state is ProfileImageUploadSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              // Refresh profile data after successful upload
              context.read<ProfileImageBloc>().add(FetchProfileEvent());
            } else if (state is ProfileImageDeleteSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              // Refresh profile data after successful deletion
              context.read<ProfileImageBloc>().add(FetchProfileEvent());
            } else if (state is ProfileImageError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<AddressBloc, AddressState>(
          listener: (context, state) {
            if (state is AddressUnauthenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
              // Navigate to login screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            } else if (state is AddressError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is AddressCreateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is AddressDeleteSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is AddressUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is PhoneUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              // Update AuthBloc with new customer data
              context.read<AuthBloc>().add(CheckAuthStatusEvent());
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    SizedBox(width: 16),
                    Text(
                      "My Profile",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                
                // Profile Image Section
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => _showImagePicker(context),
                        child: BlocBuilder<ProfileImageBloc, ProfileImageState>(
                          builder: (context, state) {
                            String? profileImageUrl;
                            
                            if (state is ProfileImageFetchSuccess) {
                              profileImageUrl = state.customer.profileImageUrl;
                            } else if (state is ProfileImageUploadSuccess) {
                              profileImageUrl = state.imageUrl;
                            }
                            
                            return Stack(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: profileImageUrl != null
                                      ? NetworkImage(profileImageUrl)
                                      : null,
                                  child: profileImageUrl == null
                                      ? Icon(Icons.person, size: 50, color: Colors.grey)
                                      : null,
                                ),
                                if (state is ProfileImageLoading)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: EdgeInsets.all(6),
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Tap to change profile picture",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _deleteProfileImage(context),
                        child: Text(
                          "Delete Profile Image",
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 30),
              
              // Contact Information
              const Text(
                "Contact information",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 22),
                        const SizedBox(width: 10),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state is AuthSuccess) {
                              return Text(state.customer.email);
                            }
                            return SizedBox();
                          },
                        ),
                      ],
                    ),

                    const Divider(height: 25),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _isEditingPhone
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                    color: Colors.blue.withOpacity(0.05),
                                  ),
                                  child: TextField(
                                    controller: _phoneController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      hintText: 'Enter phone number',
                                    ),
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    if (state is AuthSuccess) {
                                      return Text(
                                        state.customer.phone,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                ),
                        ),
                        const SizedBox(width: 8),
                        _isEditingPhone
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: _savePhoneNumber,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _cancelEditingPhone,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  if (state is AuthSuccess) {
                                    return GestureDetector(
                                      onTap: () => _startEditingPhone(state.customer.phone),
                                      child: const Icon(
                                        Icons.edit_outlined,
                                        size: 20,
                                        color: Colors.blue,
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Address Section
              const Text(
                "Address",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "This location is used when navigating to home",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              BlocBuilder<AddressBloc, AddressState>(
                builder: (context, state) {
                  if (state is AddressLoading) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (state is AddressSuccess) {
                    if (state.addresses.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "No addresses found",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    }
                    
                    // Display the first address (or default address)
                    final address = state.addresses.firstWhere(
                      (addr) => addr.isDefault,
                      orElse: () => state.addresses.first,
                    );
                    
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                address.type == 'home' ? Icons.home_outlined : Icons.location_on_outlined,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                address.type.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              if (address.isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "DEFAULT",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 32),
                            child: Text(
                              address.fullAddress,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 32),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddressEditForm(address: address),
                                      ),
                                    );
                                    // Refresh addresses if edit was successful
                                    if (result == true) {
                                      context.read<AddressBloc>().add(RefreshAddressesEvent());
                                    }
                                  },
                                  child: const Text(
                                    "Edit",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                GestureDetector(
                                  onTap: () {
                                    _showDeleteAddressDialog(address.id, address.fullAddress);
                                  },
                                  child: const Text(
                                    "Delete",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (state is AddressEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.location_off_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _createDefaultAddress,
                              child: const Text(
                                "Create Default Address",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is AddressCreateLoading) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text(
                              "Creating address...",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is AddressUpdateLoading) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text(
                              "Updating address...",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is AddressError) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                context.read<AddressBloc>().add(RefreshAddressesEvent());
                              },
                              child: const Text(
                                "Retry",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  // Default fallback
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Loading addresses...",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

