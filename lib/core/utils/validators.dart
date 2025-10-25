// lib/core/utils/validators.dart

class Validators {
  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi boş bırakılamaz';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    
    return null;
  }

  // Phone validation
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefon numarası boş bırakılamaz';
    }
    
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Geçerli bir telefon numarası girin';
    }
    
    return null;
  }

  // Required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Bu alan'} boş bırakılamaz';
    }
    return null;
  }

  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre boş bırakılamaz';
    }
    
    if (value.length < 8) {
      return 'Şifre en az 8 karakter olmalıdır';
    }
    
    return null;
  }

  // Confirm password
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı boş bırakılamaz';
    }
    
    if (value != password) {
      return 'Şifreler eşleşmiyor';
    }
    
    return null;
  }

  // Numeric validation
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Bu alan'} boş bırakılamaz';
    }
    
    if (double.tryParse(value) == null) {
      return 'Geçerli bir sayı girin';
    }
    
    return null;
  }

  // Min length
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Bu alan'} boş bırakılamaz';
    }
    
    if (value.length < min) {
      return '${fieldName ?? 'Bu alan'} en az $min karakter olmalıdır';
    }
    
    return null;
  }

  // Max length
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value != null && value.length > max) {
      return '${fieldName ?? 'Bu alan'} en fazla $max karakter olabilir';
    }
    
    return null;
  }
}