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
    public static inline var MIN_LEVEL_WIDTH = 320;
    public static inline var MIN_LEVEL_HEIGHT = 176;
    public static inline var MIN_LEVEL_WIDTH_IN_TILES = 20;
    public static inline var MIN_LEVEL_HEIGHT_IN_TILES = 11;
    public static inline var NUMBER_OF_ROOMS = 2;
    public static inline var NUMBER_OF_HALLWAYS = 2;
    public static inline var NUMBER_OF_SHAFTS = 2;

    public var walls(default, null):Grid;
    public var entities(default, null):Array<Entity>;
    private var tiles:Tilemap;
    private var levelType:String;

    public function new(x:Int, y:Int, levelType:String) {
        super(x, y);
        this.levelType = levelType;
        type = "walls";
        if(levelType == "room") {
            loadLevel('${
                Std.int(Math.floor(Random.random * NUMBER_OF_ROOMS))
            }');
        }
        else if(levelType == "hallway") {
            loadLevel('${
                Std.int(Math.floor(Random.random * NUMBER_OF_HALLWAYS))
            }');
        }
        else {
            // levelType == "shaft"
            loadLevel('${
                Std.int(Math.floor(Random.random * NUMBER_OF_SHAFTS))
            }');
        }
        if(Random.random < 0.5) {
            flipHorizontally();
        }
        updateGraphic();
        mask = walls;
        graphic = tiles;
    }

    public function flipHorizontally() {
        for(tileX in 0...Std.int(walls.columns / 2)) {
            for(tileY in 0...walls.rows) {
                var tempLeft:Null<Bool> = walls.getTile(tileX, tileY);
                // For some reason getTile() returns null instead of false!
                if(tempLeft == null) {
                    tempLeft = false;
                }
                var tempRight:Null<Bool> = walls.getTile(
                    walls.columns - tileX - 1, tileY
                );
                if(tempRight == null) {
                    tempRight = false;
                }
                walls.setTile(tileX, tileY, tempRight);
                walls.setTile(walls.columns - tileX - 1, tileY, tempLeft);
            }
        }
    }

    private function loadLevel(levelName:String) {
        // Load geometry
        var xml = Xml.parse(Assets.getText(
            'levels/${levelType}/${levelName}.oel'
        ));
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

    public function fillLeft(offsetY:Int) {
        for(tileY in 0...MIN_LEVEL_HEIGHT_IN_TILES) {
            walls.setTile(0, tileY + offsetY * MIN_LEVEL_HEIGHT_IN_TILES);
        }
    }

    public function fillRight(offsetY:Int) {
        for(tileY in 0...MIN_LEVEL_HEIGHT_IN_TILES) {
            walls.setTile(
                walls.columns - 1,
                tileY + offsetY * MIN_LEVEL_HEIGHT_IN_TILES);
        }
    }

    public function fillTop(offsetX:Int) {
        for(tileX in 0...MIN_LEVEL_WIDTH_IN_TILES) {
            walls.setTile(tileX + offsetX * MIN_LEVEL_WIDTH_IN_TILES, 0);
        }
    }

    public function fillBottom(offsetX:Int) {
        for(tileX in 0...MIN_LEVEL_WIDTH_IN_TILES) {
            walls.setTile(
                tileX + offsetX * MIN_LEVEL_WIDTH_IN_TILES,
                walls.rows - 1
            );
        }
    }

    public function updateGraphic() {
        tiles = new Tilemap(
            'graphics/tiles.png',
            walls.width, walls.height, walls.tileWidth, walls.tileHeight
        );
        tiles.loadFromString(walls.saveToString(',', '\n', '1', '0'));
        graphic = tiles;
    }
}
