package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.utils.*;

class Explosion extends TowerEntity {
    private var sprite:Spritemap;
    private var velocity:Vector2;

    public function new(
        x:Float, y:Float, velocity:Vector2, isSmall:Bool = false
    ) {
	    super(x, y);
        this.velocity = velocity;
        if(isSmall) {
            sprite = new Spritemap(
                'graphics/smallexplosion.png', 12, 12
            );
            sprite.originX = 6;
            sprite.originY = 6;
        }
        else {
            sprite = new Spritemap('graphics/explosion.png', 24, 24);
            sprite.originX = 12;
            sprite.originY = 12;
        }
        sprite.add(
            'idle', [0, 1, 2, 3], Std.int(Math.random() * 6 + 7), false
        );
        sprite.play('idle');
        graphic = sprite;
    }

    public override function update() {
        moveBy(
            velocity.x * HXP.elapsed,
            velocity.y * HXP.elapsed
        );
        velocity.scale(0.9);
        graphic.alpha -= (
            (1 - (Math.abs(velocity.x) + Math.abs(velocity.y)))
            * HXP.elapsed
        );
        if(sprite.complete) {
            scene.remove(this);
        }
        super.update();
    }
}


