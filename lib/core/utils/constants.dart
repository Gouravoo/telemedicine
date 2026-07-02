/// App-wide constants
class AppConstants {
  AppConstants._();

  static const String appName = 'AarogyaPlus';
  static const String appTagline = 'Your Health, Our Priority';
  static const String emergencyNumber = '108';

  // Blood groups for dropdown
  static const List<String> bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-',
  ];

  // Gender options
  static const List<String> genderOptions = [
    'Male', 'Female', 'Other', 'Prefer not to say',
  ];

  // Days of the week
  static const List<String> weekDays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];
}
