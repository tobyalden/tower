package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class TowerEntity extends Entity {
    public function new(x:Float, y:Float) {
        super(x, y);
    }

    private function isOnGround() {
        return collide("walls", x, y + 1) != null;
    }

    private function isOnCeiling() {
        return collide("walls", x, y - 1) != null;
    }

    private function isOnWall() {
        return isOnRightWall() || isOnLeftWall();
    }

    private function isOnRightWall() {
        return collide("walls", x + 1, y) != null;
    }

    private function isOnLeftWall() {
        return collide("walls", x - 1, y) != null;
    }

    private function isOnScreen() {
        var player = scene.getInstance("player");
        return collideRect(
            x, y,
            player.centerX - HXP.width / 2,
            player.centerY - HXP.height / 2,
            HXP.width, HXP.height
        );
    }
}
