class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? pdbId(String? value) {
    if (value == null || value.isEmpty) return 'PDB ID is required';
    if (!RegExp(r'^[0-9][A-Za-z0-9]{3}$').hasMatch(value.trim())) {
      return 'Enter a valid 4-character PDB ID (e.g. 1TUP)';
    }
    return null;
  }
}
