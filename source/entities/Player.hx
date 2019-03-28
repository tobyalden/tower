package entities;

import haxepunk.*;
import haxepunk.input.*;
import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Player extends Entity {
    public static inline var RUN_SPEED = 100;

    private var sprite:Spritemap;
    private var velocity:Vector2;

    public function new(x:Float, y:Float) {
	    super(x, y);
        sprite = new Spritemap("graphics/player.png", 48, 33);
        sprite.add("idle", [0]);
        sprite.add("run", [2, 3, 1], 10);
        sprite.add("jump", [1]);
        sprite.play("idle");
        graphic = sprite;

        velocity = new Vector2(0, 0);
        setHitbox(12, 24, -6, 0);
    }

    override public function update() {
        movement();
        animation();
        super.update();
    }

    public function movement() {
        if(Main.inputCheck("left")) {
            velocity.x = -RUN_SPEED;
        }
        else if(Main.inputCheck("right")) {
            velocity.x = RUN_SPEED;
        }
        else {
            velocity.x = 0;
        }
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed);
    }

    public function animation() {
        if(velocity.x != 0) {
            sprite.play("run");
            sprite.flipX = velocity.x < 0;
        }
        else {
            sprite.play("idle");
        }
    }
}
