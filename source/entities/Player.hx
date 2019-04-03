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

class Player extends TowerEntity {
    public static inline var RUN_SPEED = 100;
    public static inline var WALK_SPEED = 50;
    public static inline var AIR_SPEED = 120;
    public static inline var JUMP_POWER = 300;
    public static inline var JUMP_DELAY = 0.15;
    public static inline var GRAVITY = 800;
    public static inline var MAX_FALL_SPEED = 300;

    public static inline var ATTACK_DELAY = 0.15;
    public static inline var ATTACK_DURATION = 0.2;
    public static inline var HIT_KNOCKBACK = 200;
    public static inline var FLASH_TIME = 2;

    public var hurtBox(default, null):Entity;
    public var shield(default, null):Entity;
    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var jumpDelay:Alarm;
    private var attackDelay:Alarm;
    private var attackDuration:Alarm;
    private var jumpThisFrame:Bool;
    private var attackThisFrame:Bool;

    public function new(x:Int, y:Int) {
	    super(x, y);
        name = "player";
        sprite = new Spritemap("graphics/player.png", 48, 33);
        sprite.add("idle", [0]);
        sprite.add("run", [2, 3, 1], 10);
        sprite.add("walk", [2, 3, 1], 5);
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
        attackDuration.onComplete.bind(function() {
            hurtBox.enabled = false;
        });
        addTween(attackDuration);

        hurtBox = new Entity();
        hurtBox.type = "attack";
        hurtBox.mask = new Hitbox(9, 4);
        hurtBox.enabled = false;

        shield = new Entity();
        shield.type = "shield";
        shield.mask = new Hitbox(2, 28);
        shield.graphic = new ColoredRect(2, 33, 0x0000FF);
    }

    override public function update() {
        movement();
        animation();
        updateHurtBox();
        updateShield();
        super.update();
    }

    private function updateHurtBox() {
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
    }

    private function updateShield() {
        shield.enabled = (
            (Main.inputCheck("up") || Main.inputCheck("down"))
            && !attackDelay.active
            && !attackDuration.active
            && !jumpDelay.active
            && isOnGround()
        );
        if(Main.inputCheck("up")) {
            shield.mask = new Hitbox(28, 2);
            shield.graphic = new ColoredRect(28, 2, 0x0000FF);
            shield.x = centerX - 14;
            shield.y = y - 3;
        }
        else if(Main.inputCheck("down")) {
            shield.mask = new Hitbox(2, 28);
            shield.graphic = new ColoredRect(2, 28, 0x0000FF);
            if(sprite.flipX) {
                shield.x = x - 5;
            }
            else {
                shield.x = x + width + 3;
            }
            shield.y = y + 5;
        }
    }


    override private function takeHit(source:Entity) {
        flash(FLASH_TIME);
        var knockback:Vector2;
        if(isOnGround()) {
            knockback = new Vector2(
                x < source.centerX ? -HIT_KNOCKBACK / 2: HIT_KNOCKBACK / 2,
                -HIT_KNOCKBACK
            );
        }
        else {
            knockback = new Vector2(
                source.centerX - centerX, source.centerY - centerY
            );
            knockback.normalize(HIT_KNOCKBACK);
            knockback.inverse();
        }
        velocity = knockback;
    }

    public function movement() {
        var enemy = collide("enemy", x, y);
        if(enemy != null && !isFlashing) {
            takeHit(enemy);
        }
        else if(isOnGround()) {
            if(
                Main.inputCheck("down")
                || jumpDelay.active
                || attackDelay.active
                || attackDuration.active
            ) {
                velocity.x = 0;
            }
            else if(Main.inputCheck("up")) {
                if(Main.inputCheck("left")) {
                    velocity.x = -WALK_SPEED;
                }
                else if(Main.inputCheck("right")) {
                    velocity.x = WALK_SPEED;
                }
                else {
                    velocity.x = 0;
                }
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
        hurtBox.enabled = true;
    }

    public function disableHurtbox() {
        hurtBox.enabled = false;
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
            if(Main.inputCheck("up")) {
                sprite.play("walk");
            }
            else {
                sprite.play("run");
            }
            sprite.flipX = velocity.x < 0;
        }
        else {
            if(Main.inputCheck("down") && !Main.inputCheck("up")) {
                sprite.play("crouch");
            }
            else {
                sprite.play("idle");
            }
        }
    }
}
