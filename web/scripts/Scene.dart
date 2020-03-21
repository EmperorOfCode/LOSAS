import "dart:html";
import 'ActionEffects/ActionEffect.dart';
import 'Scenario.dart';
import "TargetFilters/TargetFilter.dart";
import 'Entity.dart';
import 'Util.dart';
//TODO scenes have optional background imagery
//TODO have scene know how to handle procedural text replacement STRINGMEMORY.secretMessage would put the value of the secret message in there, or null, for example
//TODO stretch goal, can put these scripting tags in as input for filters and effects, too. "your best friend is now me" or hwatever.
class Scene {
    //TODO let people sign their work
    String author;
    int stageWidth = 800;
    int stageHeight = 600;
    static String TARGETSTRINGMEMORYTAG ="[TARGET.STRINGMEMORY.";
    static String TARGETNUMMEMORYTAG ="[TARGET.NUMMEMORY.";
    static String OWNERSTRINGMEMORYTAG ="[OWNER.STRINGMEMORY.";
    static String OWNERNUMMEMORYTAG ="[OWNER.NUMMEMORY.";
    Element container;
    Scenario get scenario => owner.scenario;
    Entity owner;
    //target everything that meets this condition, or just a single one?
    bool targetOne = false;
    String beforeFlavorText;
    String afterFlavorText;
    String name;
    List<TargetFilter> targetFilters = new List<TargetFilter>();
    List<ActionEffect> effects = new List<ActionEffect>();
    Set<Entity> targets = new Set<Entity>();

    Set<Entity> get finalTargets {
        if(targets == null || targets.isEmpty) return new Set<Entity>();
        if(targetOne) {
            return new Set<Entity>()..add(targets.first);
        }else {
            return targets;
        }
    }


    Scene(this.name, this.beforeFlavorText, this.afterFlavorText);

    String debugString() {
        return "Scene $name TargetOne: $targetOne Filters: ${targetFilters.map((TargetFilter f) => f.debugString())}, Effects ${effects.map((ActionEffect f) => f.debugString())}";
    }

    String get proccessedBeforeText => processText(beforeFlavorText);
    String get proccessedAfterText => processText(afterFlavorText);


    String processText(String text, [int round =0]) {
        String originalText = "$text";
        text = processTargetStringTags(text);
        text = processTargetNumTags(text);
        if(owner != null) {
            text = processOwnerStringTags(text);
            text = processOwnerNumTags(text);
        }
        //max of three times, but if at any point nothing has changed, just finish off, no more recursion.
        if(round < 3 && text != originalText) {
            text = processText(text, round+1);
        }else {
            //look [ and ] are reserved characters here. deal with it.
            text = text.replaceAll("]", "");
        }
        return text;
    }

    String processTargetStringTags(String text) {
        List<String> tags = Util.getTagsForKey(text, TARGETSTRINGMEMORYTAG);
        for(Entity target in finalTargets) {
            tags.forEach((String tag) =>text = text.replaceAll("$TARGETSTRINGMEMORYTAG$tag","${target.getStringMemory(tag)}"));
        }
        return text;
    }

    String processTargetNumTags(String text) {
        List<String> tags = Util.getTagsForKey(text, TARGETNUMMEMORYTAG);
        for(Entity target in finalTargets) {
            tags.forEach((String tag) =>text = text.replaceAll("$TARGETNUMMEMORYTAG$tag","${target.getNumMemory(tag)}"));
        }
        return text;
    }

    String processOwnerStringTags(String text) {
        List<String> tags = Util.getTagsForKey(text, OWNERSTRINGMEMORYTAG);
        tags.forEach((String tag) =>text = text.replaceAll("$OWNERSTRINGMEMORYTAG$tag","${owner.getStringMemory(tag)}"));
        return text;
    }

    String processOwnerNumTags(String text) {
        List<String> tags = Util.getTagsForKey(text, OWNERNUMMEMORYTAG);
        tags.forEach((String tag) =>text =text.replaceAll("$OWNERNUMMEMORYTAG$tag","${owner.getNumMemory(tag)}"));
        return text;
    }



    Element render(int debugNumber) {
        container = new DivElement()..classes.add("scene");
        final CanvasElement beforeStage = new CanvasElement(width: stageWidth, height: stageHeight);
        renderStage(beforeStage);
        SpanElement beforeSpan= new SpanElement()..setInnerHtml(proccessedBeforeText);

        applyEffects(); //that way we can talk about things before someone died and after, or whatever

        final CanvasElement afterStage = new CanvasElement(width: stageWidth, height: stageHeight);
        renderStage(afterStage);
        final SpanElement afterSpan = new SpanElement()..setInnerHtml(" $proccessedAfterText");

        //TODO have simple css animations that switch between before and after stage every second (i.e. put them as the bg of the on screen element);
        final DivElement narrationDiv = new DivElement()..classes.add("narration");
        narrationDiv.append(beforeSpan);
        narrationDiv.append(afterSpan);
        container.append(beforeStage);
        container.append(narrationDiv);

        return container;
    }

    //asyncly renders to the element, lets the canvas go on screen asap
    Future<Null> renderStage(CanvasElement canvas) async {
        canvas.classes.add("stage");
        print("I'm going to render to this canvas owner is $owner and targets are $finalTargets");
        //TODO need to render the owner on the left and the targets on the right, text is above? plus name labels underneath
        if(owner != null) {
            print("my owner is not null)");
            CanvasElement ownerCanvas = await owner.canvas;
            if(ownerCanvas != null && !owner.facingRightByDefault) {
                ownerCanvas = Util.turnwaysCanvas(ownerCanvas);
                canvas.context2D.drawImage(ownerCanvas, 0, 0);
            }else {
                canvas.context2D.drawImage(ownerCanvas, 0, 0);
            }
        }
        for(Entity target in finalTargets) {
            print("I have targets and i'm going to render them to this stage");
            CanvasElement targetCanvas = await target.canvas;
            //todo put them in a neat little pile, render them at a set size
            if(targetCanvas != null && target.facingRightByDefault) {
                targetCanvas = Util.turnwaysCanvas(targetCanvas);
                canvas.context2D.drawImage(targetCanvas, 200, 0);
            }else {
                canvas.context2D.drawImage(targetCanvas, 200, 0);
            }

        }
    }

    void applyEffects() {
        for(final ActionEffect e in effects) {
            e.applyEffect(this);
        }
        //TODO capture the state of the scenario after this, for time shit
    }

    bool checkIfActivated(List<Entity> entities) {
        targets.clear();
        targets = new Set.from(entities);
        if(targetFilters.isEmpty) {
            targets = new Set<Entity>.from(entities);
            return true;
        }

        for(TargetFilter tc in targetFilters) {
            targets = new Set<Entity>.from(tc.filter(this,targets.toList()));
        }
        return targets.isNotEmpty;
    }
}