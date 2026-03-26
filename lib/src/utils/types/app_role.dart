enum AppRole {
  customer('customer'),
  technician('technician');

  const AppRole(this.value);

  final String value;

  static AppRole fromString(String rawValue) {
    final normalized = rawValue.toLowerCase().trim();

    if (normalized == 'technician' || normalized == 'tech') {
      return AppRole.technician;
    }

    return AppRole.customer;
  }
}
