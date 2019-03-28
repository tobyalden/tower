package scenes;

import entities.*;
import haxepunk.*;
import haxepunk.masks.*;
import openfl.Assets;

class GameScene extends Scene {
    private var mapBlueprint:Grid;
    private var map:Grid;
    private var allLevels:Array<Level>;
    private var player:Player;

    override public function begin() {
        loadMap(0);
        placeLevels();
        player = new Player(100, 100);
        add(player);
	}

    override public function update() {
        camera.x = player.centerX - HXP.width / 2;
        camera.y = player.centerY - HXP.height / 2;
        super.update();
    }

    private function loadMap(mapNumber:Int) {
        var mapPath = 'maps/${mapNumber}.oel';
        var xml = Xml.parse(Assets.getText(mapPath));
        var fastXml = new haxe.xml.Fast(xml.firstElement());
        var mapWidth = Std.parseInt(fastXml.node.width.innerData);
        var mapHeight = Std.parseInt(fastXml.node.height.innerData);

        mapBlueprint = new Grid(
            mapWidth, mapHeight, Level.TILE_SIZE, Level.TILE_SIZE
        );
        map = new Grid(
            mapWidth, mapHeight, Level.TILE_SIZE, Level.TILE_SIZE
        );
        for (r in fastXml.node.walls.nodes.rect) {
            mapBlueprint.setRect(
                Std.int(Std.parseInt(r.att.x) / Level.TILE_SIZE),
                Std.int(Std.parseInt(r.att.y) / Level.TILE_SIZE),
                Std.int(Std.parseInt(r.att.w) / Level.TILE_SIZE),
                Std.int(Std.parseInt(r.att.h) / Level.TILE_SIZE)
            );
        }
    }

    private function placeLevels() {
        allLevels = new Array<Level>();
        for(tileX in 0...mapBlueprint.columns) {
            for(tileY in 0...mapBlueprint.rows) {
                if(
                    mapBlueprint.getTile(tileX, tileY)
                    && !map.getTile(tileX, tileY)
                ) {
                    trace('free spot found');
                    var canPlace = false;
                    while(!canPlace) {
                        var level = new Level(
                            tileX * Level.MIN_LEVEL_WIDTH,
                            tileY * Level.MIN_LEVEL_HEIGHT
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
                                    //sealLevel(
                                        //level, tileX, tileY, checkX, checkY
                                    //);
                                }
                            }
                            level.updateGraphic();
                            add(level);
                            trace('adding level');
                            allLevels.push(level);
                        }
                    }
                }
            }
        }
    }
}
