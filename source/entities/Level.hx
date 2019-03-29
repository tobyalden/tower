package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import openfl.Assets;
import scenes.*;

class Level extends Entity {
    public static inline var TILE_SIZE = 16;
    public static inline var MIN_LEVEL_WIDTH = 640;
    public static inline var MIN_LEVEL_HEIGHT = 352;

    public var walls(default, null):Grid;
    public var entities(default, null):Array<Entity>;
    private var tiles:Tilemap;

    public function new(x:Int, y:Int) {
        super(x, y);
        type = "walls";
        loadLevel("0");
        updateGraphic();
        mask = walls;
        graphic = tiles;
    }

    private function loadLevel(levelName:String) {
        // Load geometry
        var xml = Xml.parse(Assets.getText('levels/${levelName}.oel'));
        var fastXml = new haxe.xml.Fast(xml.firstElement());
        var segmentWidth = Std.parseInt(fastXml.node.width.innerData);
        var segmentHeight = Std.parseInt(fastXml.node.height.innerData);
        walls = new Grid(segmentWidth, segmentHeight, TILE_SIZE, TILE_SIZE);
        for (r in fastXml.node.walls.nodes.rect) {
            walls.setRect(
                Std.int(Std.parseInt(r.att.x) / TILE_SIZE),
                Std.int(Std.parseInt(r.att.y) / TILE_SIZE),
                Std.int(Std.parseInt(r.att.w) / TILE_SIZE),
                Std.int(Std.parseInt(r.att.h) / TILE_SIZE)
            );
        }

        // Load optional geometry
        if(fastXml.hasNode.optionalWalls) {
            for (r in fastXml.node.optionalWalls.nodes.rect) {
                if(Random.random < 0.5) {
                    continue;
                }
                walls.setRect(
                    Std.int(Std.parseInt(r.att.x) / TILE_SIZE),
                    Std.int(Std.parseInt(r.att.y) / TILE_SIZE),
                    Std.int(Std.parseInt(r.att.w) / TILE_SIZE),
                    Std.int(Std.parseInt(r.att.h) / TILE_SIZE)
                );
            }
        }

        // Load spikes
        entities = new Array<Entity>();
        if(fastXml.hasNode.objects) {
            for (e in fastXml.node.objects.nodes.floorspikes) {
                var spike = new Spike(
                    Std.parseInt(e.att.x), Std.parseInt(e.att.y),
                    Spike.FLOOR, Std.parseInt(e.att.width)
                );
                entities.push(spike);
            }
            for (e in fastXml.node.objects.nodes.ceilingspikes) {
                var spike = new Spike(
                    Std.parseInt(e.att.x), Std.parseInt(e.att.y),
                    Spike.CEILING, Std.parseInt(e.att.width)
                );
                entities.push(spike);
            }
            for (e in fastXml.node.objects.nodes.leftwallspikes) {
                var spike = new Spike(
                    Std.parseInt(e.att.x), Std.parseInt(e.att.y),
                    Spike.LEFT_WALL, Std.parseInt(e.att.height)
                );
                entities.push(spike);
            }
            for (e in fastXml.node.objects.nodes.rightwallspikes) {
                var spike = new Spike(
                    Std.parseInt(e.att.x), Std.parseInt(e.att.y),
                    Spike.RIGHT_WALL, Std.parseInt(e.att.height)
                );
                entities.push(spike);
            }
        }
    }

    public function updateGraphic() {
        tiles = new Tilemap(
            'graphics/tiles.png',
            walls.width, walls.height, walls.tileWidth, walls.tileHeight
        );
        tiles.loadFromString(walls.saveToString(',', '\n', '1', '0'));
    }
}
