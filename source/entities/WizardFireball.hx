package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.masks.*;
import haxepunk.math.*;

class WizardFireball extends TowerEntity {
    public static inline var SPEED = 100;

    private var velocity:Vector2;
    private var sprite:Image;

    public function new(x:Float, y:Float, velocity:Vector2) {
        mask = new Hitbox(4, 4, -3, -3);
        super(x, y);
        type = "wizardfireball";
        this.velocity = velocity;
        sprite = new Image('graphics/wizardfireball.png');
        sprite.centerOrigin();
        graphic = sprite;
    }

    override public function update() {
        moveBy(
            velocity.x * HXP.elapsed,
            velocity.y * HXP.elapsed,
            ["walls", "shield"],
            true
        );
        super.update();
    }

    override public function moveCollideX(e:Entity) {
        blowUp();
        return true;
    }

    override public function moveCollideY(e:Entity) {
        blowUp();
        return true;
    }

    public function blowUp() {
        scene.remove(this);
        explode(2);
    }
}
