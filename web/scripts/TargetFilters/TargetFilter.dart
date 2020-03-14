import '../Entity.dart';
import '../Scene.dart';

abstract class TargetFilter {
    //should I invert my value?
    bool not = false;
    //should I apply my condition to myself, rather than my targets? (i.e. if I meet the condition I allow all targets to pass through to the next condition).
    bool vriska = false;
    bool conditionForRemove(Entity actor, Entity possibleTarget);
    String importantWord;
    num importantNum;

    TargetFilter(this.importantWord, this.importantNum);


    List<Entity> filter(Scene scene, List<Entity> readOnlyEntities) {
        List<Entity> entities = new List.from(readOnlyEntities);
        print("Checking what entities remain before I filter ${entities.length}");
        if(not) {
            if(vriska) {
                //reject all if my condition isn't met
                if(!conditionForRemove(scene.owner,scene.owner)) entities.clear();
            }else {
                entities.removeWhere((Entity item) => !conditionForRemove(scene.owner,item));
            }

        }else {
            if(vriska) {
                //reject all if my condition is met
                if(conditionForRemove(scene.owner,scene.owner)) entities.clear();
            }else {
                entities.removeWhere((Entity item) => conditionForRemove(scene.owner,item));
            }
        }
        print("entities remain after I filter ${entities.length}");
        return entities;
    }

}