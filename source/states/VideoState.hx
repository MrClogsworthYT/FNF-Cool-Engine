package states;

import lime.utils.Assets;
import states.MusicBeatState;
import flixel.FlxState;
import flixel.FlxG;
#if windows
import mp4.MP4Handler;
#end

class VideoState extends MusicBeatState
{
    var videoPath:String;
    var nextState:FlxState;

    public function new(path:String,state:FlxState){
        super();

        this.videoPath = path;
        this.nextState = state;
    }

    #if windows
    var video:MP4Handler = new MP4Handler();
    #end

    public override function create(){
        FlxG.autoPause = true;

        #if windows
        if(Assets.exists(Paths.video(videoPath))){
            video.playMP4(Paths.video(videoPath));
    		video.finishCallback = function(){
                FlxG.sound.music.stop();
                LoadingState.loadAndSwitchState(nextState);
            }
        }
        else{
            trace('Not existing path: ' + Paths.video(videoPath));
            video.kill();
            FlxG.sound.music.stop();
            LoadingState.loadAndSwitchState(nextState);
        }
        #else
        trace('DUM ASS, THIS ONLY WORKS ON WINDOWS XDDDD');
        FlxG.sound.music.stop();
        LoadingState.loadAndSwitchState(nextState);
        #end

        super.create();
    }

    public override function update(elapsed:Float){
        super.update(elapsed);
        #if windows
        if(controls.ACCEPT){
            video.kill();
            FlxG.sound.music.stop();
            LoadingState.loadAndSwitchState(nextState);
        }
        #end
    }
}