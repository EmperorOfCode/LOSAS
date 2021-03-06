import '../Entity.dart';
import 'ActionEffect.dart';
import '../SentientObject.dart';

class AECopyStringFromTarget extends ActionEffect {
    static const String THEIRKEY = "theirStorageKey";
    static const String MYKEY = "myStringKey";
    @override
    List<String> get knownKeys => [importantWords[THEIRKEY], importantWords[MYKEY]];

    @override
    String type ="CopyStringFromTarget";
    @override
    String explanation = "Copies a word or phrase from the target(s) to the owner.";
    AECopyStringFromTarget(String myKey, String theirKey) : super({THEIRKEY:theirKey, MYKEY:myKey}, {});
    @override
    ActionEffect makeNewOfSameType() => new AECopyStringFromTarget(null,null);

  @override
  void effectEntities(SentientObject effector, List<SentientObject> entities) {
      entities.forEach((SentientObject e) => effector.setStringMemory(importantWords[MYKEY], e.getStringMemory(importantWords[THEIRKEY])));
  }

}