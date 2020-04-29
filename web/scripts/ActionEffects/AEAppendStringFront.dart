import '../Entity.dart';
import 'ActionEffect.dart';

class AEAppendStringFront extends ActionEffect {
  static const String STORAGEKEY = "storageKey";
  static const String STRINGKEY = "stringToAppend";
  @override
  String type ="AppendStringToFront";
  @override
  String explanation = "Provide a word or phrase to add on to the front of whatever is currently in the target(s) memory at the given key.";

  AEAppendStringFront(String memoryKey, String stringToAppend) : super(<String,String>{STORAGEKEY:memoryKey, STRINGKEY:stringToAppend}, {});

  @override
  void effectEntities(Entity effector, List<Entity> entities) {
    for(final Entity e in entities) {
      String oldValue = e.getStringMemory(importantWords[STORAGEKEY]);
      oldValue ??="";
      e.setStringMemory(importantWords[STORAGEKEY],"${importantWords[STRINGKEY]}$oldValue");
    }
  }

}