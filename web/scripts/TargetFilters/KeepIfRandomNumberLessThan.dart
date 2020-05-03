import 'package:CommonLib/Random.dart';

import '../Entity.dart';
import 'TargetFilter.dart';

//random number is between 0 and 1, so if you pick more than 1 you're being redundant
class KeepIfRandomNumberLessThan extends TargetFilter {
  static String INPUTVALUE = "inputvalue";

  @override
  String type ="KeepIfRandomNumberLessThan";
  @override
  String explanation = "Generate a random number between 0 and 1 for each targetable entity. If the number for an entity is less than the supplied number target them";
  KeepIfRandomNumberLessThan(num inputValue) : super(<String,String>{}, <String,num>{INPUTVALUE: inputValue});

  @override
  bool conditionForKeep(Entity actor, Entity possibleTarget) {
    Random rand = possibleTarget.scenario.rand;
    return rand.nextDouble() <= importantNumbers[INPUTVALUE];
  }

}