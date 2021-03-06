package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.tile.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import openfl.Assets;
import scenes.*;

typedef IntPair = {
    var x:Int;
    var y:Int;
}

class Level extends TowerEntity {
    public static inline var TILE_SIZE = 16;
    public static inline var MIN_LEVEL_WIDTH = 320;
    public static inline var MIN_LEVEL_HEIGHT = 176;
    public static inline var MIN_LEVEL_WIDTH_IN_TILES = 20;
    public static inline var MIN_LEVEL_HEIGHT_IN_TILES = 11;
    public static inline var NUMBER_OF_ROOMS = 2;
    public static inline var NUMBER_OF_HALLWAYS = 2;
    public static inline var NUMBER_OF_SHAFTS = 2;

    public var walls(default, null):Grid;
    public var pathUpWalls(default, null):Grid;
    public var entities(default, null):Array<Entity>;
    private var tiles:Tilemap;
    private var levelType:String;
    private var openFloorSpots:Array<IntPair>;
    private var openCeilingSpots:Array<IntPair>;

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
            flipHorizontally(walls);
            flipHorizontally(pathUpWalls);
        }
        updateGraphic();
        mask = walls;
        graphic = tiles;
    }

    public function getOpenFloorCoordinates() {
        var openFloorSpot = openFloorSpots.pop();
        for(otherSpot in openFloorSpots) {
            if(
                otherSpot.y == openFloorSpot.y
                && otherSpot.x == openFloorSpot.x + 1
                || otherSpot.x == openFloorSpot.x - 1
            ) {
                // Remove adjacent spots
                openFloorSpots.remove(otherSpot);
            }
        }
        return new Vector2(
            x + openFloorSpot.x * TILE_SIZE,
            y + openFloorSpot.y * TILE_SIZE
        );
    }

    public function getOpenCeilingCoordinates() {
        var openCeilingSpot = openCeilingSpots.pop();
        for(otherSpot in openCeilingSpots) {
            if(
                otherSpot.y == openCeilingSpot.y
                && otherSpot.x == openCeilingSpot.x + 1
                || otherSpot.x == openCeilingSpot.x - 1
            ) {
                // Remove adjacent spots
                openCeilingSpots.remove(otherSpot);
            }
        }
        return new Vector2(
            x + openCeilingSpot.x * TILE_SIZE,
            y + openCeilingSpot.y * TILE_SIZE
        );
    }

    public function addPathsUp() {
        for(tileX in 0...walls.columns) {
            for(tileY in 0...walls.rows) {
                if(pathUpWalls.getTile(tileX, tileY)) {
                    walls.setTile(tileX, tileY);
                }
            }
        }
    }

    public function findOpenSpotsOnFloor() {
        openFloorSpots = new Array<IntPair>();
        for(tileX in 0...walls.columns) {
            for(tileY in 0...walls.rows) {
                if(
                    !walls.getTile(tileX, tileY) // Is open
                    && !walls.getTile(tileX - 1, tileY) // Open to left
                    && !walls.getTile(tileX + 1, tileY) // Open to right
                    && walls.getTile(tileX, tileY + 1) // Floor underneath
                    && walls.getTile(tileX - 1, tileY + 1) // Floor to left
                    && walls.getTile(tileX + 1, tileY + 1) // Floor to right
                ) {
                    openFloorSpots.push({x: tileX, y: tileY});
                    //tiles.setTile(tileX, tileY, 3);
                }
            }
        }
        HXP.shuffle(openFloorSpots);
    }

    public function findOpenSpotsOnCeiling() {
        openCeilingSpots = new Array<IntPair>();
        for(tileX in 0...walls.columns) {
            for(tileY in 0...walls.rows) {
                if(
                    !walls.getTile(tileX, tileY) // Is open
                    && !walls.getTile(tileX - 1, tileY) // Open to left
                    && !walls.getTile(tileX + 1, tileY) // Open to right
                    && walls.getTile(tileX, tileY - 1) // Ceiling above
                ) {
                    openCeilingSpots.push({x: tileX, y: tileY});
                    tiles.setTile(tileX, tileY, 3);
                }
            }
        }
        HXP.shuffle(openCeilingSpots);
    }

    public function flipHorizontally(wallsToFlip:Grid) {
        for(tileX in 0...Std.int(wallsToFlip.columns / 2)) {
            for(tileY in 0...wallsToFlip.rows) {
                var tempLeft:Null<Bool> = wallsToFlip.getTile(tileX, tileY);
                // For some reason getTile() returns null instead of false!
                if(tempLeft == null) {
                    tempLeft = false;
                }
                var tempRight:Null<Bool> = wallsToFlip.getTile(
                    wallsToFlip.columns - tileX - 1, tileY
                );
                if(tempRight == null) {
                    tempRight = false;
                }
                wallsToFlip.setTile(tileX, tileY, tempRight);
                wallsToFlip.setTile(
                    wallsToFlip.columns - tileX - 1, tileY, tempLeft
                );
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
        pathUpWalls = new Grid(
            segmentWidth, segmentHeight, TILE_SIZE, TILE_SIZE
        );
        for (r in fastXml.node.walls.nodes.rect) {
            walls.setRect(
                Std.int(Std.parseInt(r.att.x) / TILE_SIZE),
                Std.int(Std.parseInt(r.att.y) / TILE_SIZE),
                Std.int(Std.parseInt(r.att.w) / TILE_SIZE),
                Std.int(Std.parseInt(r.att.h) / TILE_SIZE)
            );
        }
        if(levelType == "room") {
            for (r in fastXml.node.pathUpWalls.nodes.rect) {
                pathUpWalls.setRect(
                    Std.int(Std.parseInt(r.att.x) / TILE_SIZE),
                    Std.int(Std.parseInt(r.att.y) / TILE_SIZE),
                    Std.int(Std.parseInt(r.att.w) / TILE_SIZE),
                    Std.int(Std.parseInt(r.att.h) / TILE_SIZE)
                );
            }
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
                tileY + offsetY * MIN_LEVEL_HEIGHT_IN_TILES
            );
        }
    }

    public function fillTop(offsetX:Int) {
        for(tileX in 0...MIN_LEVEL_WIDTH_IN_TILES) {
            walls.setTile(tileX + offsetX * MIN_LEVEL_WIDTH_IN_TILES, 0);
            // Clear paths up if not needed
            for(tileY in 0...walls.rows) {
                pathUpWalls.clearTile(
                    tileX + offsetX * MIN_LEVEL_WIDTH_IN_TILES, tileY
                );
            }
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
        for(tileX in 0...walls.columns) {
            for(tileY in 0...walls.rows) {
                if(pathUpWalls.getTile(tileX, tileY)) {
                    tiles.setTile(tileX, tileY, 2);
                }
            }
        }
        graphic = tiles;
    }
}
