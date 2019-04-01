package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Hopper extends TowerEntity {
    public static inline var ACTIVE_RANGE = 150;
    public static inline var JUMP_VEL_X = 140;
    public static inline var JUMP_VEL_Y = 300;
    public static inline var GRAVITY = 800;
    public static inline var TIME_BETWEEN_JUMPS = 3;
    public static inline var JUMP_TELL_DURATION = 0.5;
    public static inline var LAND_DURATION = 0.2;
    public static inline var STARTING_HEALTH = 3;

    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var jumpTimer:Alarm;
    private var landTimer:Alarm;
    private var wasOnGround:Bool;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "enemy";
        sprite = new Spritemap("graphics/hopper.png", 24, 24);
        sprite.add("idle", [0]);
        sprite.add("active", [2]);
        sprite.add("crouch", [3]);
        sprite.add("jump", [2]);
        sprite.add("hit", [4], 6);
        sprite.play("idle");
        sprite.y = -1;
        graphic = sprite;
        mask = new Hitbox(24, 23);
        velocity = new Vector2(0, 0);
        jumpTimer = new Alarm(TIME_BETWEEN_JUMPS, TweenType.Persist);
        jumpTimer.onComplete.bind(function() {
            jump();
        });
        addTween(jumpTimer);
        landTimer = new Alarm(LAND_DURATION, TweenType.Persist);
        addTween(landTimer);
        wasOnGround = false;
        health = STARTING_HEALTH;
    }

    public override function update() {
        if(isOnCeiling()) {
            // Bonk head
            velocity.y = 0;
        }
        if(isOnGround()) {
            if(!wasOnGround) {
                if(isOnScreen()) {
                    //MemoryEntity.allSfx["hopperland"].play();
                }
                velocity.x = 0;
                velocity.y = 0;
                landTimer.start();
            }
        }
        else {
            velocity.y += HXP.elapsed * GRAVITY;
        }
        wasOnGround = isOnGround();
        moveBy(
            HXP.elapsed * velocity.x, HXP.elapsed * velocity.y,
            ["walls", "enemy"]
        );

        if(isOnGround()) {
            var player = scene.getInstance("player");
            if(distanceFrom(player, true) < ACTIVE_RANGE) {
                if(!jumpTimer.active) {
                    jumpTimer.start();
                }
                if(
                    jumpTimer.remaining < JUMP_TELL_DURATION
                    || landTimer.active
                ) {
                    sprite.play("crouch");
                }
                else {
                    sprite.play("active");
                }
            }
            else {
                jumpTimer.active = false;
                sprite.play("idle");
            }
        }
        else {
            sprite.play("jump");
        }

        if(collide("attack", x, y) != null) {
            takeHit();
        }
        super.update();
    }

    private function jump() {
        var player = scene.getInstance("player");
        if(
            !isOnScreen()
            || distanceFrom(player, true) > ACTIVE_RANGE
            || !isOnGround()
        ) {
            return;
        }
        if(centerX < player.centerX) {
            velocity.x = JUMP_VEL_X;
        }
        else {
            velocity.x = -JUMP_VEL_X;
        }
        velocity.y = -JUMP_VEL_Y;
        sprite.play("jump");
        //MemoryEntity.allSfx["hopperjump"].play();
    }
}
