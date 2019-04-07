package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Wizard extends TowerEntity {
    public static inline var IDLE_SPEED = 35;
    public static inline var FIREBALL_SPEED = 100;
    public static inline var CAST_COOLDOWN = 2;
    public static inline var CAST_STARTUP = 0.5;
    public static inline var MIN_CAST_DISTANCE = 75;
    public static inline var MAX_CAST_DISTANCE = 150;

    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var castCooldown:Alarm;
    private var castStartup:Alarm;
    private var canMove:Bool;

    public function new(x:Float, y:Float) {
        super(x, y);
        type = "enemy";
        sprite = new Spritemap("graphics/wizard.png", 16, 32);
        sprite.add("idle", [0]);
        sprite.add("attack", [1]);
        sprite.play("idle");
        graphic = sprite;
        velocity = new Vector2(IDLE_SPEED, 0);
        if(Random.random > 0.5) {
            velocity.x *= -1;
        }
        mask = new Hitbox(15, 32);
        health = 2;

        castCooldown = new Alarm(CAST_COOLDOWN, TweenType.Persist);
        addTween(castCooldown);

        castStartup = new Alarm(CAST_STARTUP, TweenType.Persist);
        castStartup.onComplete.bind(function() {
            castFireball();
            castCooldown.start();
        });
        addTween(castStartup);
        canMove = true;
    }

    private function castFireball() {
        scene.add(new WizardFireball(
            centerX, centerY,
            new Vector2(
                sprite.flipX ? -FIREBALL_SPEED : FIREBALL_SPEED, 0
            )
        ));
    }

    override public function update() {
        var player = cast(scene.getInstance("player"), Player);
        
        // If you're casting a spell, don't move
        if(castStartup.active || castCooldown.active) {
            if(castStartup.active) {
                sprite.play("attack");
            }
            else {
                sprite.play("idle");
            }
        }
        // If the player isn't on your platform or is out of range, wander
        else if(
            bottom != player.bottom
            || distanceFrom(player, true) > MAX_CAST_DISTANCE
        ) {
            if(willGoOffEdge()) {
                velocity.x = -velocity.x;
            }
            if(!isFlashing) {
                moveBy(velocity.x * HXP.elapsed, 0, ["walls", "shield"]);
            }
            animation();
        }
        // If the the player is on our platform and in range, fire
        else if(
            bottom == player.bottom
            && distanceFrom(player, true) < MAX_CAST_DISTANCE
            && distanceFrom(player, true) > MIN_CAST_DISTANCE
        ) {
            castStartup.start();
            sprite.flipX = centerX > player.centerX;
        }
        // If the player is on our platform and too close...
        else if(
            bottom == player.bottom
            && distanceFrom(player, true) < MIN_CAST_DISTANCE
        ) {
            velocity.x = centerX < player.centerX ? -IDLE_SPEED : IDLE_SPEED;
            if(!willGoOffEdge() && !isOnWall()) {
                // Run away if you can
                if(!isFlashing) {
                    moveBy(velocity.x * HXP.elapsed, 0, ["walls", "shield"]);
                }
                animation();
            }
            else {
                // Otherwise turn and fight
                castStartup.start();
                sprite.flipX = centerX > player.centerX;
            }
        }

        var attack = collide("attack", x, y);
        if(attack != null) {
            takeHit(attack);
        }

        super.update();
    }

    private function willGoOffEdge() {
        x += velocity.x * HXP.elapsed;
        var edgeCheck = false;
        if(velocity.x < 0) {
            if(!isBottomLeftCornerOnGround()) {
                edgeCheck = true;
            }
        }
        else if(velocity.x > 0) {
            if(!isBottomRightCornerOnGround()) {
                edgeCheck = true;
            }
        }
        x -= velocity.x * HXP.elapsed;
        return edgeCheck;
    }

    private function animation() {
        sprite.play("idle");
        if(velocity.x < 0) {
            sprite.flipX = true;
        }
        else if(velocity.x > 0) {
            sprite.flipX = false;
        }
    }

    public override function moveCollideX(e:Entity) {
        velocity.x = -velocity.x;
        return true;
}
}
