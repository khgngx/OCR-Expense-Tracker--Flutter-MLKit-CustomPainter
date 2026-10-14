enum Category {
  food('Food'),
  study('Study'),
  travel('Travel'),
  gear('Gear'),
  entertainment('Entertainment');

  const Category(this.label);

  final String label;

  static Category fromName(String? name) => Category.values.firstWhere(
    (c) => c.name == name,
    orElse: () => Category.food,
  );
}
