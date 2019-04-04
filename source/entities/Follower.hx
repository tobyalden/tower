package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Follower extends TowerEntity {
    public static inline var ACCEL = 100;
    public static inline var MAX_SPEED = 100;
    public static inline var BOUNCE_FACTOR = 0.75;
    public static inline var ACTIVATE_DISTANCE = 200;
    public static inline var KNOCKBACK_SPEED = 100;
    public static inline var KNOCKBACK_TIME = 1;

    private var sprite:Spritemap;
    private var accel:Float;
    private var velocity:Vector2;
    private var isActive:Bool;
    private var knockbackTimer:Alarm;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "enemy";
        sprite = new Spritemap("graphics/follower.png", 24, 24);
        sprite.add("idle", [
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 1, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
        ], 24);
        sprite.add("chasing", [3]);
        sprite.add("hit", [4]);
        sprite.play("idle");
        sprite.x = -3;
        sprite.y = -3;
        graphic = sprite;
        velocity = new Vector2(0, 0);
        mask = new Hitbox(20, 20);
        isActive = false;
        health = 2;
        knockbackTimer = new Alarm(KNOCKBACK_TIME, TweenType.Persist);
        addTween(knockbackTimer);
    }

    override public function update() {
        var player = scene.getInstance("player");
        var wasActive = isActive;
        if(distanceFrom(player, true) < ACTIVATE_DISTANCE) {
            isActive = true;
        }
        trace('knockbackTimer.active = ${knockbackTimer.active}');
        if(!knockbackTimer.active) {
            var towardsPlayer = new Vector2(
                player.centerX - centerX, player.centerY - centerY
            );
            var accel = ACCEL;
            towardsPlayer.normalize(accel * HXP.elapsed);
            velocity.add(towardsPlayer);
            if(velocity.length > MAX_SPEED) {
                velocity.normalize(MAX_SPEED);
            }
        }
        if(isActive) {
            moveBy(
                velocity.x * HXP.elapsed, velocity.y * HXP.elapsed,
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

    override private function takeHit(source:Entity) {
        var player = scene.getInstance("player");
        var awayFromPlayer = new Vector2(
            player.centerX - centerX, player.centerY - centerY
        );
        awayFromPlayer.normalize(KNOCKBACK_SPEED);
        awayFromPlayer.inverse();
        velocity = awayFromPlayer;
        knockbackTimer.start();
        super.takeHit(source);
    }

    private function animation() {
        var player = scene.getInstance("player");
        sprite.flipX = centerX < player.centerX;
        if(stopFlasher.active) {
            sprite.play("hit");
        }
        else if(isActive) {
            sprite.play("chasing");
        }
        else {
            sprite.play("idle");
        }
    }

    public override function moveCollideX(e:Entity) {
        if(e.type == "shield") {
            velocity.x = -velocity.x * BOUNCE_FACTOR * 2;
        }
        else {
            velocity.x = -velocity.x * BOUNCE_FACTOR;
        }
        return true;
    }

    public override function moveCollideY(e:Entity) {
        if(e.type == "shield") {
            velocity.y = -velocity.y * BOUNCE_FACTOR * 2;
        }
        else {
            velocity.y = -velocity.y * BOUNCE_FACTOR;
        }
        return true;
    }
}
