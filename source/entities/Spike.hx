package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;

class Spike extends TowerEntity
{
    public static inline var FLOOR = 0;
    public static inline var CEILING = 1;
    public static inline var LEFT_WALL = 2;
    public static inline var RIGHT_WALL = 3;

    public var orientation(default, null):Int;
    private var sprite:Image;

    public function new(x:Float, y:Float, orientation:Int, length:Int)
    {
        super(x, y);
        this.orientation = orientation;
        type = "hazard";
        if(orientation == FLOOR) {
            sprite = new TiledImage("graphics/spikefloor.png", length, 8);
            setHitbox(length, 8);
        }
        else if(orientation == CEILING) {
            sprite = new TiledImage("graphics/spikeceiling.png", length, 8);
            setHitbox(length, 8);
        }
        else if(orientation == LEFT_WALL) {
            sprite = new TiledImage("graphics/spikeleftwall.png", 8, length);
            setHitbox(8, length);
        }
        else {
            sprite = new TiledImage("graphics/spikerightwall.png", 8, length);
            setHitbox(8, length);
        }
        graphic = sprite;
    }
}

