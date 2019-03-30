package entities;

import haxepunk.*;
import haxepunk.input.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Player extends Entity {
    public static inline var RUN_SPEED = 100;
    public static inline var AIR_SPEED = 120;
    public static inline var JUMP_POWER = 300;
    public static inline var JUMP_DELAY = 0.15;
    public static inline var GRAVITY = 800;
    public static inline var MAX_FALL_SPEED = 300;

    public static inline var ATTACK_DELAY = 0.15;
    public static inline var ATTACK_DURATION = 0.2;

    public var hurtBox(default, null):Entity;
    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var jumpDelay:Alarm;
    private var attackDelay:Alarm;
    private var attackDuration:Alarm;
    private var jumpThisFrame:Bool;
    private var attackThisFrame:Bool;

    public function new(x:Int, y:Int) {
	    super(x, y);
        sprite = new Spritemap("graphics/player.png", 48, 33);
        sprite.add("idle", [0]);
        sprite.add("run", [2, 3, 1], 10);
        sprite.add("jump", [9]);
        sprite.add("fall", [10]);
        sprite.add("crouch", [6]);
        sprite.add("preattack", [4]);
        sprite.add("attack", [5]);
        sprite.add("crouchattack", [7]);
        sprite.play("idle");
        graphic = sprite;
        sprite.x = -16;
        sprite.y = -1;

        velocity = new Vector2(0, 0);
        mask = new Hitbox(16, 32);

        jumpDelay = new Alarm(JUMP_DELAY, TweenType.Persist);
        jumpDelay.onComplete.bind(function() {
            jumpThisFrame = true;

        });
        addTween(jumpDelay);
        jumpThisFrame = false;

        attackDelay = new Alarm(ATTACK_DELAY, TweenType.Persist);
        attackDelay.onComplete.bind(function() {
            attackThisFrame = true;
        });
        addTween(attackDelay);
        attackThisFrame = false;

        attackDuration = new Alarm(ATTACK_DURATION, TweenType.Persist);
        addTween(attackDuration);

        hurtBox = new Entity();
        hurtBox.mask = new Hitbox(9, 4);
        hurtBox.enabled = false;
    }

    override public function update() {
        movement();
        animation();
        hurtBox.enabled = attackDuration.active;
        if(sprite.flipX) {
            hurtBox.x = x - 16;
        }
        else {
            hurtBox.x = x + 23;
        }
        if(Main.inputCheck("down")) {
            hurtBox.y = y + 20;
        }
        else {
            hurtBox.y = y + 10;
        }
        super.update();
    }

    public function movement() {
        if(isOnGround()) {
            if(
                Main.inputCheck("down")
                || jumpDelay.active
                || attackDelay.active
                || attackDuration.active
            ) {
                velocity.x = 0;
            }
            else if(Main.inputCheck("left")) {
                velocity.x = -RUN_SPEED;
            }
            else if(Main.inputCheck("right")) {
                velocity.x = RUN_SPEED;
            }
            else {
                velocity.x = 0;
            }

            if(jumpThisFrame) {
                jump();
                jumpThisFrame = false;
            }
            else {
                velocity.y = 0;
            }

            if(Main.inputPressed("jump") && !jumpDelay.active) {
                jumpDelay.start();
            }
        }
        else {
            velocity.y = Math.min(
                velocity.y + GRAVITY * HXP.elapsed,
                MAX_FALL_SPEED
            );
        }

        if(attackThisFrame) {
            attack();
            attackThisFrame = false;
        }
        if(
            Main.inputPressed("action")
            && !attackDelay.active
            && !attackDuration.active
        ) {
            attackDelay.start();
        }

        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
    }

    private function jump() {
        velocity.y = -JUMP_POWER;
        if(Main.inputCheck("left")) {
            velocity.x = -AIR_SPEED;
        }
        else if(Main.inputCheck("right")) {
            velocity.x = AIR_SPEED;
        }
    }

    private function attack() {
        attackDuration.start();
    }

    private function isOnGround() {
        return collide("walls", x, y + 1) != null;
    }

    public function animation() {
        if(attackDuration.active) {
            if(Main.inputCheck("down")) {
                sprite.play("crouchattack");
            }
            else {
                sprite.play("attack");
            }
        }
        else if(attackDelay.active) {
            sprite.play("preattack");
        }
        else if(jumpDelay.active) {
            sprite.play("crouch");
        }
        else if(!isOnGround()) {
            if(velocity.y < 0) {
                sprite.play("jump");
            }
            else {
                sprite.play("fall");
            }
        }
        else if(velocity.x != 0) {
            sprite.play("run");
            sprite.flipX = velocity.x < 0;
        }
        else {
            if(Main.inputCheck("down")) {
                sprite.play("crouch");
            }
            else {
                sprite.play("idle");
            }
        }
    }
}
