import 'package:inject_x/inject_x.dart';

void main(List<String> arguments) {
  // Create class
  InjectX.add(Class1());
  InjectX.add(Class2());

  final Class1 class1 = InjectX.get();
  class1.name = "Pippo";
  class1.hello();

  final class2 = InjectX.get<Class2>();
  class2.name = "Paperino";
  InjectX.get<Class2>().name = "Pluto";
  class2.hello();
  InjectX.add(Class2());

  InjectX.get<Class2>().name = "Paperone";

  InjectX.get<Class2>().hello();

  final class2b = inject<Class2>();

  print(InjectX.length);

  class2b.hello();
}

class Class1 {
  String _name = "";
  hello() {
    print("Hello $_name from class 1 $hashCode");
  }

  set name(value) {
    _name = value;
  }
}

class Class2 {
  String _name = "";
  hello() {
    print("Hello $_name from class 2 $hashCode");
  }

  set name(value) {
    _name = value;
  }
}
