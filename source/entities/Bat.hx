package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;

class Bat extends TowerEntity {
    public static inline var ACCEL = 200;
    public static inline var MAX_SPEED = 50;
    public static inline var ACTIVATE_DISTANCE = 100;

    public static inline var BOB_SPEED = 3;
    public static inline var BOB_AMOUNT = 4;

    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var isActive:Bool;
    private var bob:Float;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "enemy";
        sprite = new Spritemap("graphics/bat.png", 16, 16);
        sprite.add("idle", [0]);
        sprite.add("chasing", [1, 2], 5);
        sprite.play("idle");
        graphic = sprite;
        velocity = new Vector2(0, MAX_SPEED);
        mask = new Hitbox(16, 16);
        isActive = false;
        health = 1;
        bob = Math.PI;
    }

    override public function update() {
        if(isActive) {
            bob += BOB_SPEED * HXP.elapsed;
            if(bob >= Math.PI * 2) {
                bob -= Math.PI * 2;
            }
        }

        var player = scene.getInstance("player");
        var wasActive = isActive;
        if(
            distanceFrom(player, true) < ACTIVATE_DISTANCE
            && player.centerY > centerY
        ) {
            isActive = true;
        }
        var towardsPlayer = new Vector2(
            player.centerX - centerX,
            player.top - centerY
        );
        var accel = ACCEL;
        if(distanceFrom(player, true) < 50) {
            accel *= 2;
        }
        towardsPlayer.normalize(accel * HXP.elapsed);
        velocity.add(towardsPlayer);

        collidable = true;
        if(collide("walls", x, y) != null) {
            collidable = false;
        }

        if(velocity.length > MAX_SPEED) {
            velocity.normalize(MAX_SPEED);
        }
        velocity.y += Math.sin(bob - Math.PI / 2) * BOB_AMOUNT;
        if(isActive) {
            moveBy(
                velocity.x * HXP.elapsed,
                velocity.y * HXP.elapsed,
                ["walls", "enemy", "shield"]
            );
        }
        animation();

        var attack = collide("attack", x, y);
        if(attack != null) {
            takeHit(attack);
        }
        super.update();
    }

    override public function moveCollideX(e:Entity) {
        velocity.x = -velocity.x;
        return true;
    }

    override public function moveCollideY(e:Entity) {
        velocity.y = -velocity.y;
        return true;
    }

    private function animation() {
        var player = scene.getInstance("player");
        sprite.flipX = centerX > player.centerX;
        if(isActive) {
            sprite.play("chasing");
        }
        else {
            sprite.play("idle");
        }
    }
}

