import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  static const String routeName = "/settings";
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _fullScreenMode = false;
  bool _achievementNotifications = true;
  bool _generalNotifications = true;
  bool _autoPlayPronunciation = true;
  bool _autoPlayExerciseSounds = true;
  bool _playSoundEffects = true;
  double _textSize = 0.67; // 2/3 of the way to the right

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Settings Sections
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Display Settings
                    _buildSettingsSection(
                      title: "تنظیمات نمایش",
                      icon: Icons.monitor,
                      children: [
                        _buildToggleOption(
                          title: "نمایش اپلیکیشن به صورت تمام صفحه",
                          value: _fullScreenMode,
                          onChanged: (value) {
                            setState(() {
                              _fullScreenMode = value;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // App Notifications
                    _buildSettingsSection(
                      title: "اعلانات برنامه",
                      icon: Icons.notifications,
                      children: [
                        _buildToggleOption(
                          title: "دریافت اعلان هنگام دستاورد جدید",
                          value: _achievementNotifications,
                          onChanged: (value) {
                            setState(() {
                              _achievementNotifications = value;
                            });
                          },
                          activeColor: Colors.orange,
                        ),
                        _buildToggleOption(
                          title: "دریافت اعلان های عمومی",
                          value: _generalNotifications,
                          onChanged: (value) {
                            setState(() {
                              _generalNotifications = value;
                            });
                          },
                          activeColor: Colors.orange,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Sound Settings
                    _buildSettingsSection(
                      title: "تنظیمات صوتی",
                      icon: Icons.volume_up,
                      children: [
                        _buildToggleOption(
                          title: "پخش خودکار تلفظ در صفحه واژگان جدید",
                          value: _autoPlayPronunciation,
                          onChanged: (value) {
                            setState(() {
                              _autoPlayPronunciation = value;
                            });
                          },
                          activeColor: Colors.orange,
                        ),
                        _buildToggleOption(
                          title: "پخش خودکار صوت تمرین ها",
                          value: _autoPlayExerciseSounds,
                          onChanged: (value) {
                            setState(() {
                              _autoPlayExerciseSounds = value;
                            });
                          },
                          activeColor: Colors.orange,
                        ),
                        _buildToggleOption(
                          title: "پخش افکت های صوتی",
                          value: _playSoundEffects,
                          onChanged: (value) {
                            setState(() {
                              _playSoundEffects = value;
                            });
                          },
                          activeColor: Colors.orange,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Content Text Size
                    _buildSettingsSection(
                      title: "اندازه متون محتوای درسی",
                      icon: Icons.text_fields,
                      children: [
                        _buildTextSizeSlider(),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Test Text Box
                    _buildTestTextBox(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Expanded(
            child: Text(
              "تنظیمات",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildToggleOption({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? activeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor ?? Colors.grey,
            activeTrackColor:
                activeColor?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSizeSlider() {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.orange,
            inactiveTrackColor: Colors.blueGrey.withOpacity(0.3),
            thumbColor: Colors.orange,
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: _textSize,
            min: 0.0,
            max: 1.0,
            onChanged: (value) {
              setState(() {
                _textSize = value;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "اندازه کوچک",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              "اندازه بزرگ",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTestTextBox() {
    // محاسبه اندازه فونت بر اساس مقدار اسلایدر
    // حداقل 12 و حداکثر 24 پیکسل
    double fontSize = 12 + (_textSize * 12);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "این یک متن آزمایشی است",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.black87,
        ),
      ),
    );
  }
}
