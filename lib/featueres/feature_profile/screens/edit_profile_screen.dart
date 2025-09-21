import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poortak/common/utils/prefs_operator.dart';
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

  String? selectedAvatar;
  String? selectedAgeGroup;
  bool isLoading = false;

  // Age group options
  final List<String> ageGroups = [
    'کودک',
    'نوجوان',
    'جوان',
    'میانسال',
    'سالمند',
  ];

  // Avatar options - using default profile image for now
  // You can replace these with actual avatar URLs or add more avatar assets
  final List<String> avatarOptions = [
    'assets/images/profile/finalProfile.png',
    'assets/images/profile/finalProfile.png',
    'assets/images/profile/finalProfile.png',
    'assets/images/profile/finalProfile.png',
    'assets/images/profile/finalProfile.png',
    'assets/images/profile/finalProfile.png',
    'assets/images/profile/finalProfile.png',
    'assets/images/profile/finalProfile.png',
    'assets/images/profile/finalProfile.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      if (selectedAgeGroup == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لطفاً رده سنی خود را انتخاب کنید'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      final updateParams = UpdateProfileParams.only(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        ageGroup: selectedAgeGroup!,
        avatar: selectedAvatar ?? '',
      );

      context
          .read<ProfileBloc>()
          .add(UpdateProfileEvent(updateProfileParams: updateParams));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: BlocListener<ProfileBloc, ProfileState>(
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
                ),
              );
            }
          },
          child: Stack(
            children: [
              // Status bar area
              Container(
                height: 22,
                color: const Color(0xFFFFF8E4),
              ),

              // Main content
              Column(
                children: [
                  const SizedBox(height: 22),

                  // White background with curved bottom
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(81),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 27),

                              // Avatar selection title
                              const Center(
                                child: Text(
                                  'عکس آواتار خود را انتخاب کنید!',
                                  style: TextStyle(
                                    fontFamily: 'IRANSans',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    color: Color(0xFF29303D),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Avatar selection grid
                              _buildAvatarGrid(),

                              const SizedBox(height: 20),

                              // Form title
                              const Text(
                                'مشخصات خود را وارد کنید:',
                                style: TextStyle(
                                  fontFamily: 'IRANSans',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  color: Color(0xFF29303D),
                                ),
                                textAlign: TextAlign.right,
                              ),

                              const SizedBox(height: 20),

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

                              const SizedBox(height: 7),

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

                              const SizedBox(height: 7),

                              // Age group field
                              _buildAgeGroupField(),

                              const SizedBox(height: 40),

                              // Confirm button
                              Center(
                                child: SizedBox(
                                  width: 154,
                                  height: 64,
                                  child: ElevatedButton(
                                    onPressed:
                                        isLoading ? null : _updateProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFC2C9D6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'تأیید',
                                            style: TextStyle(
                                              fontFamily: 'IRANSans',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),
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

  Widget _buildAvatarGrid() {
    // Different colors for avatar options
    final List<Color> avatarColors = [
      const Color(0xFFE3F2FD), // Light blue
      const Color(0xFFF3E5F5), // Light purple
      const Color(0xFFE8F5E8), // Light green
      const Color(0xFFFFF3E0), // Light orange
      const Color(0xFFFCE4EC), // Light pink
      const Color(0xFFE0F2F1), // Light teal
      const Color(0xFFFFF8E1), // Light yellow
      const Color(0xFFF1F8E9), // Light lime
      const Color(0xFFE8EAF6), // Light indigo
    ];

    return Container(
      height: 270, // 3 rows * 90px each
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final isSelected = selectedAvatar == avatarOptions[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedAvatar = avatarOptions[index];
              });
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFFC2C9D6) : Colors.transparent,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: Container(
                  color: avatarColors[index],
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Color(0xFFA3AFC2),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 59,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontFamily: 'IRANSans',
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Color(0xFF3D495C),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'IRANSans',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Color(0xFF3D495C),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(19),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildAgeGroupField() {
    return Container(
      height: 59,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedAgeGroup,
        onChanged: (String? newValue) {
          setState(() {
            selectedAgeGroup = newValue;
          });
        },
        decoration: InputDecoration(
          labelText: 'رده سنی',
          labelStyle: const TextStyle(
            fontFamily: 'IRANSans',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Color(0xFF3D495C),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(19),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
        style: const TextStyle(
          fontFamily: 'IRANSans',
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Color(0xFF3D495C),
        ),
        items: ageGroups.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'لطفاً رده سنی خود را انتخاب کنید';
          }
          return null;
        },
      ),
    );
  }
}
