class Modifiers {
  final bool shift;
  final bool alt;

  const Modifiers({required this.shift, required this.alt});

  factory Modifiers.allOff() => Modifiers(shift: false, alt: false);

  Modifiers copyWith({bool? shift, bool? alt}) => Modifiers(shift: shift ?? this.shift, alt: alt ?? this.alt);
}
