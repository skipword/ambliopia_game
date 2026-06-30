enum Eye { left, right }

extension EyeLabel on Eye {
  String get label {
    return switch (this) {
      Eye.left => 'Ojo izquierdo',
      Eye.right => 'Ojo derecho',
    };
  }

  String get shortLabel {
    return switch (this) {
      Eye.left => 'izquierdo',
      Eye.right => 'derecho',
    };
  }

  Eye get opposite {
    return switch (this) {
      Eye.left => Eye.right,
      Eye.right => Eye.left,
    };
  }
}
