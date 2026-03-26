import 'package:flutter/material.dart';

class Validators {
  static FormFieldValidator<String> required({errorMessage}) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return errorMessage;
      }
      return null;
    };
  }

  static FormFieldValidator<String> numberValidator({errorMessage}) {
    return (String? value) {
      final numValue = double.tryParse(value!);
      if (numValue == null || numValue.isNaN) {
        return errorMessage;
      }
      return null;
    };
  }

  static FormFieldValidator<String> minValue({minValue, errorMessage}) {
    return (String? value) {
      final numValue = double.tryParse(value!);
      if (numValue == null || numValue <= minValue) {
        return errorMessage;
      }
      return null;
    };
  }

  static FormFieldValidator<String> multiValidator(
  List<FormFieldValidator<String>> validators,
  ) {
    return (String? value) {
      for (var validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }

  static FormFieldValidator<String> maxValue({maxValue ,errorMessage}) {
   return (String? value) {
    final numValue = double.tryParse(value!);
    if (numValue == null || numValue > maxValue ) {
      return errorMessage;
    }
    return null;
   };
  }

}
  
