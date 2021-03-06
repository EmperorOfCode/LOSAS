import 'package:CommonLib/Random.dart';

import '../Entity.dart';
import '../Scene.dart';
import '../SentientObject.dart';
import 'AEAddGenerator.dart';
import 'AEAddNum.dart';
import 'AEAddNumFromMyMemory.dart';
import 'AEAddNumFromYourMemory.dart';
import 'AEAddPrepack.dart';
import 'AEAddScene.dart';
import 'AEAddSceneFromOwner.dart';
import 'AEAddSceneFromTarget.dart';
import 'AEAppendString.dart';
import 'AEAppendStringFront.dart';
import 'AECopyNumFromTarget.dart';
import 'AECopyNumToTarget.dart';
import 'AECopyStringFromTarget.dart';
import 'AECopyStringToTarget.dart';
import 'AERemoveGeneratorsForKey.dart';
import 'AERemovePrepack.dart';
import 'AERemoveScene.dart';
import 'AERestoreDoll.dart';
import 'AESetDollStringFromMyMemory.dart';
import 'AESetDollStringFromYourMemory.dart';
import 'AESetNum.dart';
import 'AESetNumGenerator.dart';
import 'AESetString.dart';
import 'AESetStringGenerator.dart';
import 'AETransformDoll.dart';
import 'AEUnAppendString.dart';
import 'AEUnSetString.dart';

/*
    TODO Pile:
     add serialied scene
     forget memory key at random
 */
abstract class ActionEffect {
    //are we applying this to my targets, or to myself?
    bool vriska = false;
    bool scenario = false;

    //each subclass MUST implement this
    String type;
    String explanation;
    Map<String,String> importantWords = new Map<String,String>();
    Map<String, num> importantNumbers = new Map<String,num>();
    //useful for generating forms and serialization
    static List<ActionEffect> exampleOfAllEffects;

    List<String> get knownKeys => [];


    ActionEffect(this.importantWords, this.importantNumbers);
    ActionEffect makeNewOfSameType();

    static ActionEffect makeNewFromString(String type) {
        setExamples();
        for(ActionEffect effect in exampleOfAllEffects) {
            if(effect.type == type) {
                ActionEffect newEffect =  effect.makeNewOfSameType();
                return newEffect;
            }
        }
        throw "What kind of effect is ${type}";
    }

    static ActionEffect fromSerialization(Map<String,dynamic> serialization){
        //first, figure out what sub type it is
        //then call that ones
        setExamples();
        String type = serialization["type"];
        for(ActionEffect effect in exampleOfAllEffects) {
            if(effect.type == type) {
                ActionEffect newEffect =  effect.makeNewOfSameType();
                newEffect.importantWords = new Map<String,String>.from(serialization["importantWords"]);
                newEffect.importantNumbers = new Map<String,num>.from(serialization["importantNumbers"]);
                newEffect.vriska = serialization["vriska"];
                newEffect.scenario = serialization.containsKey("scenario")? serialization["scenario"] : false;
                return newEffect;
            }
        }
        throw "What kind of effect is ${type}";

    }

    static void setExamples() {
      exampleOfAllEffects ??= <ActionEffect>[new AERemoveScene(null), new AERemovePrepack(null), new AEAddPrepack(null), new AETransformDoll(null),new AERestoreDoll(null), new AEAddGenerator(null), new AERemoveAllGeneratorsForKey(null),new AEUnSetString(null),new AEAddScene(null),new AEAddSceneFromOwner(null),new AEAddSceneFromTarget(null),new AEUnAppendString(null,null),new AESetStringGenerator(null,null),new AESetString(null,null),new AESetNumGenerator(null,null),new AESetNum(null,null),new AESetDollStringFromYourMemory(null),new AESetDollStringFromMyMemory(null),new AECopyStringToTarget(null,null),new AECopyStringFromTarget(null,null),new AECopyNumToTarget(null,null),new AECopyNumFromTarget(null,null),new AEAppendStringFront(null,null),new AEAppendString(null,null),new AEAddNum(null,null), new AEAddNumFromYourMemory(null,null),new AEAddNumFromMyMemory(null,null)];
    }

    void effectEntities(SentientObject effector, List<SentientObject> entities);

    Map<String,dynamic> getSerialization() {
        Map<String,dynamic> ret = new Map<String,dynamic>();
        ret["type"] = type;
        ret["importantWords"] = importantWords;
        ret["importantNumbers"] = importantNumbers;
        ret["vriska"] = vriska;
        ret["scenario"] = scenario;

        return ret;
    }


    String debugString() {
        return "Effect: ${runtimeType} $importantWords, $importantNumbers , Vriska: $vriska";
    }


    void applyEffect(Scene scene) {
        List<SentientObject> targets;
        if(vriska) {
            targets = new List<SentientObject>();
            targets.add(scene.owner);
        }else if(scenario) {
            targets = new List<SentientObject>();
            targets.add(scene.scenario);
        }else {
            targets = new List.from(scene.finalTargets);
        }
        effectEntities(scene.owner,targets);
    }

}