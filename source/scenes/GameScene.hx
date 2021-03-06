package scenes;

import entities.*;
import haxepunk.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import openfl.Assets;

class GameScene extends Scene {
    private var roomMapBlueprint:Grid;
    private var hallwayMapBlueprint:Grid;
    private var shaftMapBlueprint:Grid;
    private var allBlueprint:Grid;
    private var map:Grid;
    private var allLevels:Array<Level>;
    private var player:Player;

    override public function begin() {
        loadMaps(0);
        placeLevels();
        player = new Player(50, 50);
        add(player);
        add(player.hurtBox);
        add(player.shield);
        for(i in 0...24) {
            var level = allLevels[Random.randInt(allLevels.length)];
            var openFloorCoordinates = level.getOpenFloorCoordinates();
            var follower = new Follower(
                openFloorCoordinates.x, openFloorCoordinates.y - 6
            );
            var hopper = new Hopper(
                openFloorCoordinates.x, openFloorCoordinates.y - 6
            );
            //var enemy = HXP.choose(hopper, follower);
            var enemy:Entity;
            if(Math.random() > 0.5) {
                enemy = hopper;
            }
            else {
                enemy = follower;
            }
            enemy.x -= (enemy.width - Level.TILE_SIZE) / 2;
            enemy.y -= enemy.height - enemy.originY;
            add(enemy);
        }
        camera.pixelSnapping = true;
        Key.define("togglezoom", [Key.T]);
        Key.define("reset", [Key.R]);
	}

    override public function update() {
        super.update();
        if(Input.pressed("togglezoom")) {
            camera.scale = camera.scale == 1 ? 0.1 : 1;
        }
        if(Input.pressed("reset")) {
            HXP.scene = new GameScene();
        }
        camera.x = Math.floor(player.centerX - HXP.width / 2);
        camera.y = Math.floor(player.centerY - HXP.height / 2);
    }

    private function loadMaps(mapNumber:Int) {
        var mapPath = 'maps/${'test'}.oel';
        var xml = Xml.parse(Assets.getText(mapPath));
        var fastXml = new haxe.xml.Fast(xml.firstElement());
        var mapWidth = Std.parseInt(fastXml.node.width.innerData);
        var mapHeight = Std.parseInt(fastXml.node.height.innerData);
        map = new Grid(mapWidth, mapHeight, Level.TILE_SIZE, Level.TILE_SIZE);
        roomMapBlueprint = new Grid(
            mapWidth, mapHeight, Level.TILE_SIZE, Level.TILE_SIZE
        );
        hallwayMapBlueprint = new Grid(
            mapWidth, mapHeight, Level.TILE_SIZE, Level.TILE_SIZE
        );
        shaftMapBlueprint = new Grid(
            mapWidth, mapHeight, Level.TILE_SIZE, Level.TILE_SIZE
        );
        allBlueprint = new Grid(
            mapWidth, mapHeight, Level.TILE_SIZE, Level.TILE_SIZE
        );
        for (r in fastXml.node.rooms.nodes.rect) {
            roomMapBlueprint.setRect(
                Std.int(Std.parseInt(r.att.x) / Level.TILE_SIZE),
                Std.int(Std.parseInt(r.att.y) / Level.TILE_SIZE),
                Std.int(Std.parseInt(r.att.w) / Level.TILE_SIZE),
                Std.int(Std.parseInt(r.att.h) / Level.TILE_SIZE)
            );
            allBlueprint.setRect(
                Std.int(Std.parseInt(r.att.x) / Level.TILE_SIZE),
                Std.int(Std.parseInt(r.att.y) / Level.TILE_SIZE),
                Std.int(Std.parseInt(r.att.w) / Level.TILE_SIZE),
                Std.int(Std.parseInt(r.att.h) / Level.TILE_SIZE)
            );
        }
        for (r in fastXml.node.hallways.nodes.rect) {
            hallwayMapBlueprint.setRect(
                Std.int(Std.parseInt(r.att.x) / Level.TILE_SIZE),
                Std.int(Std.parseInt(r.att.y) / Level.TILE_SIZE),
                Std.int(Std.parseInt(r.att.w) / Level.TILE_SIZE),
                Std.int(Std.parseInt(r.att.h) / Level.TILE_SIZE)
            );
            allBlueprint.setRect(
                Std.int(Std.parseInt(r.att.x) / Level.TILE_SIZE),
                Std.int(Std.parseInt(r.att.y) / Level.TILE_SIZE),
                Std.int(Std.parseInt(r.att.w) / Level.TILE_SIZE),
                Std.int(Std.parseInt(r.att.h) / Level.TILE_SIZE)
            );
        }
        for (r in fastXml.node.shafts.nodes.rect) {
            shaftMapBlueprint.setRect(
                Std.int(Std.parseInt(r.att.x) / Level.TILE_SIZE),
                Std.int(Std.parseInt(r.att.y) / Level.TILE_SIZE),
                Std.int(Std.parseInt(r.att.w) / Level.TILE_SIZE),
                Std.int(Std.parseInt(r.att.h) / Level.TILE_SIZE)
            );
            allBlueprint.setRect(
                Std.int(Std.parseInt(r.att.x) / Level.TILE_SIZE),
                Std.int(Std.parseInt(r.att.y) / Level.TILE_SIZE),
                Std.int(Std.parseInt(r.att.w) / Level.TILE_SIZE),
                Std.int(Std.parseInt(r.att.h) / Level.TILE_SIZE)
            );
        }
    }

    private function sealLevel(
        level:Level, tileX:Int, tileY:Int, checkX:Int, checkY:Int
    ) {
        if(
            !roomMapBlueprint.getTile(tileX + checkX - 1, tileY + checkY)
            && !hallwayMapBlueprint.getTile(tileX + checkX - 1, tileY + checkY)
        ) {
            level.fillLeft(checkY);
        }
        if(
            !roomMapBlueprint.getTile(tileX + checkX + 1, tileY + checkY)
            && !hallwayMapBlueprint.getTile(tileX + checkX + 1, tileY + checkY)
        ) {
            level.fillRight(checkY);
        }
        if(
            !roomMapBlueprint.getTile(tileX + checkX, tileY + checkY - 1)
            && !shaftMapBlueprint.getTile(tileX + checkX, tileY + checkY - 1)
        ) {
            level.fillTop(checkX);
        }
        if(
            !roomMapBlueprint.getTile(tileX + checkX, tileY + checkY + 1)
            && !shaftMapBlueprint.getTile(tileX + checkX, tileY + checkY + 1)
        ) {
            level.fillBottom(checkX);
        }
    }

    private function placeLevels() {
        allLevels = new Array<Level>();
        var levelTypes = ["room", "hallway", "shaft"];
        var count = 0;
        for(mapBlueprint in [
            roomMapBlueprint, hallwayMapBlueprint, shaftMapBlueprint
        ]) {
            for(tileX in 0...mapBlueprint.columns) {
                for(tileY in 0...mapBlueprint.rows) {
                    if(
                        mapBlueprint.getTile(tileX, tileY)
                        && !map.getTile(tileX, tileY)
                    ) {
                        var canPlace = false;
                        while(!canPlace) {
                            var level = new Level(
                                tileX * Level.MIN_LEVEL_WIDTH,
                                tileY * Level.MIN_LEVEL_HEIGHT,
                                levelTypes[count]
                            );
                            var levelWidth = Std.int(
                                level.width / Level.MIN_LEVEL_WIDTH
                            );
                            var levelHeight = Std.int(
                                level.height / Level.MIN_LEVEL_HEIGHT
                            );
                            canPlace = true;
                            for(checkX in 0...levelWidth) {
                                for(checkY in 0...levelHeight) {
                                    if(
                                        map.getTile(
                                            tileX + checkX, tileY + checkY
                                        )
                                        || !mapBlueprint.getTile(
                                            tileX + checkX, tileY + checkY
                                        )
                                    ) {
                                        canPlace = false;
                                    }
                                }
                            }
                            if(canPlace) {
                                for(checkX in 0...levelWidth) {
                                    for(checkY in 0...levelHeight) {
                                        map.setTile(
                                            tileX + checkX, tileY + checkY
                                        );
                                        sealLevel(
                                            level,
                                            tileX, tileY,
                                            checkX, checkY
                                        );
                                    }
                                }
                                level.addPathsUp();
                                level.findOpenSpotsOnFloor();
                                level.updateGraphic();
                                add(level);
                                for(entity in level.entities) {
                                    entity.moveBy(level.x, level.y);
                                    add(entity);
                                }
                                allLevels.push(level);
                            }
                        }
                    }
                }
            }
            count++;
        }
    }
}
