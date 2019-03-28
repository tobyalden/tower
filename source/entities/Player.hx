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
    public static inline var AIR_CONTROL = 0;
    public static inline var JUMP_POWER = 250;
    public static inline var GRAVITY = 800;
    public static inline var MAX_FALL_SPEED = 300;

    private var sprite:Spritemap;
    private var velocity:Vector2;

    public function new(x:Int, y:Int) {
	    super(x, y);
        sprite = new Spritemap("graphics/player.png", 48, 33);
        sprite.add("idle", [0]);
        sprite.add("run", [2, 3, 1], 10);
        sprite.add("jump", [9]);
        sprite.add("fall", [10]);
        sprite.play("idle");
        graphic = sprite;
        sprite.x = -16;
        sprite.y = -1;

        velocity = new Vector2(0, 0);
        mask = new Hitbox(16, 32);
    }

    override public function update() {
        movement();
        animation();
        super.update();
    }

    public function movement() {
        if(isOnGround()) {
            if(Main.inputCheck("left")) {
                velocity.x = -RUN_SPEED;
            }
            else if(Main.inputCheck("right")) {
                velocity.x = RUN_SPEED;
            }
            else {
                velocity.x = 0;
            }

            velocity.y = 0;
            if(Main.inputPressed("jump")) {
                velocity.y = -JUMP_POWER;
                if(Main.inputCheck("left")) {
                    velocity.x = -AIR_SPEED;
                }
                else if(Main.inputCheck("right")) {
                    velocity.x = AIR_SPEED;
                }
            }
        }
        else {
            if(Main.inputCheck("left")) {
                velocity.x -= AIR_CONTROL * HXP.elapsed;
            }
            else if(Main.inputCheck("right")) {
                velocity.x += AIR_CONTROL * HXP.elapsed;
            }
            velocity.y = Math.min(
                velocity.y + GRAVITY * HXP.elapsed,
                MAX_FALL_SPEED
            );
        }

        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
    }

    private function isOnGround() {
        return collide("walls", x, y + 1) != null;
    }

    public function animation() {
        if(!isOnGround()) {
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
            sprite.play("idle");
        }
    }
}
