import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:poortak/config/myColors.dart';
import 'package:poortak/config/myTextStyle.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
import 'package:poortak/common/services/storage_service.dart';
import 'package:poortak/featueres/feature_profile/data/models/avatar_model.dart';
import 'package:poortak/featueres/feature_profile/data/data_sorce/profile_api_provider.dart';
import 'package:poortak/featueres/feature_profile/data/models/update_profile_params.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/profile_bloc.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/profile_event.dart';
import 'package:poortak/featueres/feature_profile/presentation/bloc/profile_state.dart';
import 'package:poortak/locator.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = "/edit_profile_screen";
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final PrefsOperator prefsOperator = locator<PrefsOperator>();
  final ProfileApiProvider profileApiProvider = locator<ProfileApiProvider>();
  final StorageService storageService = locator<StorageService>();

  String? selectedAvatar;
  // String? selectedAgeGroup;
  bool isLoading = false;
  bool isLoadingAvatars = true;
  List<AvatarWithUrl> avatars = [];

  // Age group options
  // final List<String> ageGroups = [
  //   'کودک',
  //   'نوجوان',
  //   'جوان',
  //   'میانسال',
  //   'سالمند',
  // ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAvatars();
  }

  Future<void> _loadUserData() async {
    final firstName = await prefsOperator.getUserFirstName();
    final lastName = await prefsOperator.getUserLastName();
    final avatar = await prefsOperator.getUserAvatar();

    setState(() {
      _firstNameController.text = firstName ?? '';
      _lastNameController.text = lastName ?? '';
      selectedAvatar = avatar;
    });
  }

  Future<void> _loadAvatars() async {
    try {
      setState(() {
        isLoadingAvatars = true;
      });

      final response = await profileApiProvider.callGetAvatars();

      if (response.data['ok'] == true && response.data['data'] != null) {
        final List<AvatarModel> avatarsList = (response.data['data'] as List)
            .map((json) => AvatarModel.fromJson(json))
            .toList();

        // Get download URLs for each avatar using StorageService
        final List<AvatarWithUrl> avatarsWithUrls = [];
        for (var avatar in avatarsList) {
          final url =
              await storageService.callGetDownloadPublicUrl(avatar.fileKey);
          avatarsWithUrls.add(AvatarWithUrl(
            id: avatar.id,
            fileKey: avatar.fileKey,
            url: url,
          ));
        }

        setState(() {
          avatars = avatarsWithUrls;
          isLoadingAvatars = false;
        });
      } else {
        setState(() {
          isLoadingAvatars = false;
        });
      }
    } catch (e) {
      print('Error loading avatars: $e');
      setState(() {
        isLoadingAvatars = false;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      // if (selectedAgeGroup == null) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('لطفاً رده سنی خود را انتخاب کنید'),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      //   return;
      // }

      setState(() {
        isLoading = true;
      });

      final updateParams = UpdateProfileParams.only(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        // ageGroup: selectedAgeGroup!,
        avatar: selectedAvatar ?? '',
      );

      final profileBloc = locator<ProfileBloc>();
      profileBloc.add(UpdateProfileEvent(updateProfileParams: updateParams));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileBloc = locator<ProfileBloc>();

    return Scaffold(
      backgroundColor: MyColors.background3,
      body: SafeArea(
        child: BlocListener<ProfileBloc, ProfileState>(
          bloc: profileBloc,
          listener: (context, state) {
            if (state is ProfileSuccessUpdate) {
              setState(() {
                isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('پروفایل با موفقیت بروزرسانی شد'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              // Small delay to show success message before navigating back
              Future.delayed(const Duration(milliseconds: 500), () {
                Navigator.pop(context);
              });
            } else if (state is ProfileErrorUpdate) {
              setState(() {
                isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: Stack(
            children: [
              // Status bar area
              Container(
                height: 22.h,
                color: const Color(0xFFFFF8E4),
              ),

              // Main content
              Column(
                children: [
                  SizedBox(height: 22.h),

                  // White background with curved bottom
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(81.r),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 22.w),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 27.h),

                              // Avatar selection title
                              Center(
                                child: Text(
                                  'عکس آواتار خود را انتخاب کنید!',
                                  style: MyTextStyle.textMatn13.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: MyColors.textMatn1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              SizedBox(height: 20.h),

                              // Selected avatar display
                              _buildSelectedAvatar(),

                              SizedBox(height: 20.h),

                              // Form title
                              Text(
                                'مشخصات خود را وارد کنید:',
                                style: MyTextStyle.textMatn13.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: MyColors.textMatn1,
                                ),
                                textAlign: TextAlign.right,
                              ),

                              SizedBox(height: 20.h),

                              // First name field
                              _buildTextField(
                                controller: _firstNameController,
                                label: 'نام:',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'لطفاً نام خود را وارد کنید';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 7.h),

                              // Last name field
                              _buildTextField(
                                controller: _lastNameController,
                                label: 'نام خانوادگی:',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'لطفاً نام خانوادگی خود را وارد کنید';
                                  }
                                  return null;
                                },
                              ),

                              SizedBox(height: 7.h),

                              // Age group field
                              // _buildAgeGroupField(),

                              SizedBox(height: 40.h),

                              // Confirm button
                              Center(
                                child: SizedBox(
                                  width: 154.w,
                                  height: 64.h,
                                  child: ElevatedButton(
                                    onPressed:
                                        isLoading ? null : _updateProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFC2C9D6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: isLoading
                                        ? SizedBox(
                                            width: 20.r,
                                            height: 20.r,
                                            child:
                                                const CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            'تأیید',
                                            style: MyTextStyle.textMatn18Bold
                                                .copyWith(
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 40.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedAvatar() {
    final selectedAvatarUrl = _getSelectedAvatarUrl();

    return Center(
      child: GestureDetector(
        onTap: _showAvatarSelectionModal,
        child: Container(
          width: 100.r,
          height: 100.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFC2C9D6),
              width: 3.r,
            ),
          ),
          child: ClipOval(
            child: selectedAvatarUrl != null
                ? Image.network(
                    selectedAvatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFE3F2FD),
                        child: Icon(
                          Icons.person,
                          size: 50.r,
                          color: const Color(0xFFA3AFC2),
                        ),
                      );
                    },
                  )
                : Container(
                    color: const Color(0xFFE3F2FD),
                    child: Icon(
                      Icons.person,
                      size: 50.r,
                      color: const Color(0xFFA3AFC2),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  String? _getSelectedAvatarUrl() {
    if (selectedAvatar == null) return null;
    final avatar = avatars.firstWhere(
      (a) => a.fileKey == selectedAvatar,
      orElse: () => AvatarWithUrl(id: '', fileKey: '', url: ''),
    );
    return avatar.url.isNotEmpty ? avatar.url : null;
  }

  void _showAvatarSelectionModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'انتخاب آواتار',
            textAlign: TextAlign.center,
            style: MyTextStyle.textHeader16Bold.copyWith(
              color: MyColors.textMatn1,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300.h,
            child: _buildAvatarGrid(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'بستن',
                style: MyTextStyle.textMatn14Bold.copyWith(
                  fontWeight: FontWeight.normal,
                  color: MyColors.textMatn1,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatarGrid() {
    if (isLoadingAvatars) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (avatars.isEmpty) {
      return Center(
        child: Text(
          'آواتار موجود نیست',
          style: MyTextStyle.textMatn14Bold.copyWith(
            fontWeight: FontWeight.normal,
            color: MyColors.textMatn1,
          ),
        ),
      );
    }

    return GridView.builder(
      physics: const ScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
      ),
      itemCount: avatars.length,
      itemBuilder: (context, index) {
        final avatar = avatars[index];
        final isSelected = selectedAvatar == avatar.fileKey;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedAvatar = avatar.fileKey;
            });
            Navigator.of(context).pop(); // Close modal after selection
          },
          child: Container(
            margin: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isSelected ? const Color(0xFFC2C9D6) : Colors.transparent,
                width: 3.r,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                avatar.url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE3F2FD),
                    child: Icon(
                      Icons.person,
                      size: 40.r,
                      color: const Color(0xFFA3AFC2),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 59.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4.r,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        textAlign: TextAlign.right,
        style: MyTextStyle.textMatn16.copyWith(
          color: MyColors.textMatn1,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: MyTextStyle.textMatn16.copyWith(
            color: MyColors.textMatn1,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(19.r),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        ),
      ),
    );
  }

  // Widget _buildAgeGroupField() {
  //   return Container(
  //     height: 59,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(19),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.04),
  //           blurRadius: 4,
  //           offset: const Offset(0, 0),
  //         ),
  //       ],
  //     ),
  //     child: DropdownButtonFormField<String>(
  //       value: selectedAgeGroup,
  //       onChanged: (String? newValue) {
  //         setState(() {
  //           selectedAgeGroup = newValue;
  //         });
  //       },
  //       decoration: InputDecoration(
  //         labelText: 'رده سنی',
  //         labelStyle: const TextStyle(
  //           fontFamily: 'IRANSans',
  //           fontWeight: FontWeight.w500,
  //           fontSize: 16,
  //           color: Color(0xFF3D495C),
  //         ),
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(19),
  //           borderSide: BorderSide.none,
  //         ),
  //         contentPadding:
  //             const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  //       ),
  //       style: const TextStyle(
  //         fontFamily: 'IRANSans',
  //         fontWeight: FontWeight.w500,
  //         fontSize: 16,
  //         color: Color(0xFF3D495C),
  //       ),
  //       items: ageGroups.map<DropdownMenuItem<String>>((String value) {
  //         return DropdownMenuItem<String>(
  //           value: value,
  //           child: Text(value),
  //         );
  //       }).toList(),
  //       validator: (value) {
  //         if (value == null || value.isEmpty) {
  //           return 'لطفاً رده سنی خود را انتخاب کنید';
  //         }
  //         return null;
  //       },
  //     ),
  //   );
  // }
}

// Helper class to store avatar with its URL
class AvatarWithUrl {
  final String id;
  final String fileKey;
  final String url;

  AvatarWithUrl({
    required this.id,
    required this.fileKey,
    required this.url,
  });
}
