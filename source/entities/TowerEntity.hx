package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class TowerEntity extends Entity {
    public static inline var FLASH_TIME = 0.4;

    private var isFlashing:Bool;
    private var flasher:Alarm;
    private var stopFlasher:Alarm;
    private var health:Int;

    public function new(x:Float, y:Float) {
        super(x, y);

        isFlashing = false;
        flasher = new Alarm(0.05, TweenType.Looping);
        flasher.onComplete.bind(function() {
            if(isFlashing) {
                visible = !visible;
            }
        });
        addTween(flasher, true);

        stopFlasher = new Alarm(FLASH_TIME, TweenType.Persist);
        stopFlasher.onComplete.bind(function() {
            visible = true;
            isFlashing = false;
        });
        addTween(stopFlasher, false);
        health = null;
    }

    private function flash() {
        if(!isFlashing) {
            visible = false;
        }
        isFlashing = true;
        stopFlasher.start();
    }

    private function takeHit() {
        // TODO: Add parameter specifying what's hitting them
        if(health != null) {
            flash();
            health -= 1;
            if(health <= 0) {
                die();
            }
        }
        if(type == "enemy") {
            cast(scene.getInstance("player"), Player).disableHurtbox();
        }
    }

    private function die() {
        scene.remove(this);
        explode(4);
    }

    private function explode(numExplosions:Int) {
        var directions = new Array<Vector2>();
        for(i in 0...numExplosions) {
            var angle = (2 / numExplosions) * i;
            directions.push(
                new Vector2(Math.cos(angle), Math.sin(angle))
            );
            directions.push(
                new Vector2(-Math.cos(angle), Math.sin(angle))
            );
            directions.push(
                new Vector2(Math.cos(angle), -Math.sin(angle))
            );
            directions.push(
                new Vector2(-Math.cos(angle), -Math.sin(angle))
            );
        }
        var count = 0;
        for(direction in directions) {
            direction.scale(0.8 * Math.random());
            direction.normalize(
                Math.max(0.1 + 0.2 * Math.random(), direction.length)
            );
            direction.scale(500);
            var explosion = new Explosion(
                centerX, centerY, directions[count]
            );
            explosion.layer = -99;
            scene.add(explosion);
            count++;
        }
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
