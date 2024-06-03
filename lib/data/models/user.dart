class User {
  String email;
  List<String> mealsAll = [];
  User({required this.email});

  List<String> getMeals() {
    return mealsAll;
  }

  void setMeals(List<String> meals) {
    mealsAll = meals;
  }

  void setEmail(String email) {
    this.email = email;
  }

  String getEmail() {
    return email;
  }

  void removeDuplicates() {
    mealsAll = mealsAll.toSet().toList();
  }

  void addMeal(String meal) {
    mealsAll.add(meal);
  }
}

User user = User(email: '');
