  class Designer {
    final String name;

    Designer({required this.name});

    factory Designer.fromJson(String jsonName) {
      return Designer(name: jsonName);
    }
  }
