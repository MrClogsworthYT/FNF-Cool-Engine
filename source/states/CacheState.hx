package states;

import lime.utils.Assets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flash.display.BitmapData;
import states.TitleState;

using StringTools;
class CacheState extends MusicBeatState
{
    var toBeFinished = 0;
	var finished = 0;
    var loadingbar:FlxSprite;

	var loading:FlxText;

	var charactersloading:Bool = false;
	var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('cache-characters'));
    var objectsloading:Bool = false;
    var objects:Array<String> = CoolUtil.coolTextFile(Paths.txt('cache-objects'));
    var soundsloading:Bool = false;
    var sounds:Array<String> = CoolUtil.coolTextFile(Paths.txt('cache-sounds'));

	var loadingStart:Bool = false;

    var math:Float;

	override function create()
	{
        FlxG.mouse.visible = false;
        FlxG.sound.muteKeys = null;

        Highscore.load();
		KeyBinds.keyCheck();
		PlayerSettings.init();

        PlayerSettings.player1.controls.loadKeyBinds();

        toBeFinished = (Lambda.count(characters) + Lambda.count(objects) + Lambda.count(sounds));

        var bg:FlxSprite = new FlxSprite().loadGraphic(BitmapData.fromFile(Paths.image('menu/menuBG')));
        add(bg);

        loading = new FlxText(0, 680);
        loading.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, RIGHT, OUTLINE,FlxColor.BLACK);
        loading.size = 20;
        add(loading);

		preload();
		

		super.create();
	}

	override function update(elapsed:Float)
    {
        super.update(elapsed);

        math = Mathf.getPercentage2(finished,toBeFinished);

        if(!(charactersloading && objectsloading && soundsloading)){
            loading.text = "Loaded Objects: " + math;
        }

        if (charactersloading && objectsloading && soundsloading)
        {
            loading.text = "Done!";
            LoadingState.loadAndSwitchState(new TitleState(),true);
            FlxG.camera.fade(FlxColor.BLACK, 0.8, false);
        }
	}

    function preload(){

        if(!charactersloading){
            #if sys sys.thread.Thread.create(() -> { #end
                preloadAssets();
            #if sys }); #end
        }

        if(!objectsloading){
            #if sys sys.thread.Thread.create(() -> { #end
                objectsAssets();
            #if sys }); #end
        }
        if(!soundsloading){
            #if sys sys.thread.Thread.create(() -> { #end
                soundsAssets();
            #if sys }); #end
        }
    }

    function preloadAssets(){
        for(x in characters){
            if(#if sys sys.FileSystem.exists(Paths.image(x))
                #else Assets.exists(Paths.image(x))#end){
                ImageCache.add(Paths.image(x));
                trace("Chached " + x);
            }
            else
                trace("Error while loading\nImage in path " + Paths.image(x));
            finished++;
            charactersloading = true;
        }
    }

    function objectsAssets(){
        for(x in objects){
            if(#if sys sys.FileSystem.exists(Paths.image(x))
                #else Assets.exists(Paths.image(x))#end){
                ImageCache.add(Paths.image(x));
                trace("Chached " + x);
            }
            else{
                trace("Error while loading\nImage in path " + Paths.image(x));
            }
            finished++;
        }
        objectsloading = true;
    }
    function soundsAssets(){
        for(x in sounds){
            if(#if sys sys.FileSystem.exists(Paths.sound(x))
                #else Assets.exists(Paths.sound(x)) #end){
                FlxG.sound.cache(Paths.sound(x));
                trace("Chached " + x);
            }
            else
                trace("Error while loading\nSound in path " + Paths.sound(x));
            finished++;
        }
        soundsloading = true;
    }
}

//End of Loading and Start of Image Caching

class ImageCache{

    public static var cache:Map<String,FlxGraphic> = new Map<String,FlxGraphic>();

    public static function add(path:String):Void{
        
        var data:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(path));
        data.persist = true;

        cache.set(path, data);
    }

    public static function get(path:String):FlxGraphic{
        return cache.get(path);
    }

    public static function exists(path:String){
        return cache.exists(path);
    }

}