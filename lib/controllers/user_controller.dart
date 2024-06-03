import '../data/models/user.dart';

class UserController {
  User user = User(email: '');

  void setEmail(String email) {
    user.setEmail(email);
  }

  String getEmail() {
    return user.getEmail();
  }

  void addMeal(String meal) {
    user.addMeal(meal);
  }

  List<String> getMeals() {
    return user.getMeals();
  }

  void removeDuplicates() {
    user.removeDuplicates();
  }

  void setMeals(List<String> meals){
    user.setMeals(meals);
  }
}
