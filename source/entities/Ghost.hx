package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.math.*;

class Ghost extends TowerEntity {
    public static inline var ACCEL = 200;
    public static inline var MAX_SPEED = 60;
    public static inline var MAX_SPEED_PHASED = 40;
    public static inline var ACTIVATE_DISTANCE = 200;

    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var isActive:Bool;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "ghost";
        sprite = new Spritemap("graphics/ghost.png", 30, 30);
        sprite.add("idle", [0, 1], 6);
        sprite.add("phasing", [2, 3], 6);
        sprite.play("idle");
        graphic = sprite;
        velocity = new Vector2(0, 0);
        setHitbox(30, 30);
        isActive = false;
        health = 1;
    }

    override public function update() {
        var player = scene.getInstance("player");
        var wasActive = isActive;
        if(distanceFrom(player, true) < ACTIVATE_DISTANCE) {
            isActive = true;
        }
        var towardsPlayer = new Vector2(
            player.centerX - centerX, player.centerY - centerY
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

        var maxSpeed = collidable ? MAX_SPEED : MAX_SPEED_PHASED;
        if(velocity.length > maxSpeed) {
            velocity.normalize(maxSpeed);
        }
        if(isActive) {
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed);
        }
        animation();

        var attack = collide("attack", x, y);
        if(attack != null) {
            takeHit(attack);
        }
        super.update();
    }

    private function animation() {
        var player = scene.getInstance("player");
        sprite.flipX = centerX > player.centerX;
        if(collidable) {
            sprite.play("idle");
        }
        else {
            sprite.play("phasing");
        }
    }
}
