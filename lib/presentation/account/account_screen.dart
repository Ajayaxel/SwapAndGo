import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swap_app/bloc/auth_bloc.dart';
import 'package:swap_app/bloc/profile_image/profile_image_bloc.dart';
import 'package:swap_app/bloc/profile_image/profile_image_event.dart';
import 'package:swap_app/bloc/profile_image/profile_image_state.dart';
import 'package:swap_app/const/go_button.dart';
import 'package:swap_app/presentation/account/my_active_subscription_screen.dart';
import 'package:swap_app/presentation/account/swap_history_screen.dart';
import 'package:swap_app/presentation/account/my_profile.dart';
import 'package:swap_app/presentation/account/subscription_screen.dart';
import 'package:swap_app/presentation/account/subscription_history.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Fetch profile data when screen loads
    context.read<ProfileImageBloc>().add(FetchProfileEvent());
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileImageBloc, ProfileImageState>(
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
        } else if (state is ProfileImageError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Account",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyProfilePage(),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
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
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showImagePicker(context),
                          child:
                              BlocBuilder<ProfileImageBloc, ProfileImageState>(
                                builder: (context, state) {
                                  String? profileImageUrl;

                                  if (state is ProfileImageFetchSuccess) {
                                    profileImageUrl =
                                        state.customer.profileImageUrl;
                                  } else if (state
                                      is ProfileImageUploadSuccess) {
                                    profileImageUrl = state.imageUrl;
                                  }

                                  return Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundImage: profileImageUrl != null
                                            ? NetworkImage(profileImageUrl)
                                            : null,
                                        child: profileImageUrl == null
                                            ? Icon(
                                                Icons.person,
                                                size: 30,
                                                color: Colors.grey,
                                              )
                                            : null,
                                      ),
                                      if (state is ProfileImageLoading)
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.5,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
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
                                          padding: EdgeInsets.all(4),
                                          child: Icon(
                                            Icons.camera_alt,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                        ),
                        SizedBox(width: 16),

                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state is AuthSuccess) {
                              return Text(
                                state.customer.name,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            } else if (state is AuthError) {
                              return Text(
                                state.message,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }
                            return SizedBox();
                          },
                        ),

                        Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Container(
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTile(
                        icon: Icons.list_alt_outlined,
                        title: "Subscription plans",
                        subtitle: "Lorem ipsum",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SubscriptionScreen(),
                            ),
                          );
                        },
                      ),
                      _divider(),
                      _buildTile(
                        icon: Icons.subscriptions,
                        title: "My Active Subscription",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const MyActiveSubscriptionScreen(),
                            ),
                          );
                        },
                      ),
                      _divider(),

                      _buildTile(
                        icon: Icons.receipt_long_outlined,
                        title: "Subscription History",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SubscriptionHistoryScreen(),
                            ),
                          );
                        },
                      ),
                      _divider(),
                      _buildTile(
                        icon: Icons.history,
                        title: "Swap History",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HistoryScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                GoButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(LogoutEvent());
                    // No functionality - just UI
                    print('Logout pressed');
                  },
                  text: "Logout",
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  foregroundColor: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _divider() {
  return Divider(
    height: 1,
    thickness: 1,
    indent: 15,
    endIndent: 15,
    color: Color(0xffE6EAED),
  );
}

Widget _buildTile({
  required IconData icon,
  required String title,
  String? subtitle,
  required VoidCallback onTap,
}) {
  return ListTile(
    leading: Icon(icon, color: Colors.black),
    title: Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
    ),
    subtitle: subtitle != null
        ? Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: Color(0xff98989A)),
          )
        : null,
    trailing: const Icon(
      Icons.arrow_forward_ios,
      color: Colors.black,
      size: 20,
    ),
    onTap: onTap,
  );
}
