import haxepunk.*;
import haxepunk.debug.Console;
import haxepunk.input.*;
import haxepunk.input.gamepads.*;
import scenes.*;

class Main extends Engine {
    public static inline var DEAD_ZONE = 0.5;

    public static var gamepad:Gamepad;
    private static var lastVerticalAxis:Float;
    private static var lastHorizontalAxis:Float;

    static function main() {
        new Main();
    }

    override public function init() {
#if debug
        Console.enable();
#end
        Key.define("left", [Key.LEFT, Key.LEFT_SQUARE_BRACKET]);
        Key.define("right", [Key.RIGHT, Key.RIGHT_SQUARE_BRACKET]);
        Key.define("up", [Key.UP]);
        Key.define("down", [Key.DOWN]);
        Key.define("jump", [Key.Z]);
        Key.define("action", [Key.X]);
        Key.define("quit", [Key.ESCAPE]);

        gamepad = Gamepad.gamepad(0);
        Gamepad.onConnect.bind(function(newGamepad:Gamepad) {
            if(gamepad == null) {
                gamepad = newGamepad;
            }
        });
        Gamepad.onDisconnect.bind(function(_:Gamepad) {
            gamepad = null;
        });
        lastVerticalAxis = 0;
        lastHorizontalAxis = 0;

        HXP.scene = new GameScene();
    }

    override public function update() {
#if desktop
        if(Input.pressed("quit")) {
            Sys.exit(0);
        }
#end
        super.update();
        lastVerticalAxis = gamepad != null ? gamepad.getAxis(1) : 0;
        lastHorizontalAxis = gamepad != null ? gamepad.getAxis(0) : 0;
    }

    public static function inputPressed(inputName:String) {
        if(gamepad == null || Input.pressed(inputName)) {
            return Input.pressed(inputName);
        }
        if(inputName == "jump") {
            return gamepad.pressed(XboxGamepad.A_BUTTON);
        }
        if(inputName == "action") {
            return gamepad.pressed(XboxGamepad.X_BUTTON);
        }
        if(inputName == "left") {
            return (
                gamepad.pressed(XboxGamepad.DPAD_LEFT)
                || gamepad.getAxis(0) <= -DEAD_ZONE
                && lastHorizontalAxis > -DEAD_ZONE
            );
        }
        if(inputName == "right") {
            return (
                gamepad.pressed(XboxGamepad.DPAD_RIGHT)
                || gamepad.getAxis(0) >= DEAD_ZONE
                && lastHorizontalAxis < DEAD_ZONE
            );
        }
        if(inputName == "up") {
            return (
                gamepad.pressed(XboxGamepad.DPAD_UP)
                || gamepad.getAxis(1) <= -DEAD_ZONE
                && lastVerticalAxis > -DEAD_ZONE
            );
        }
        if(inputName == "down") {
            return (
                gamepad.pressed(XboxGamepad.DPAD_DOWN)
                || gamepad.getAxis(1) >= DEAD_ZONE
                && lastVerticalAxis < DEAD_ZONE
            );
        }
        return false;
    }

    public static function inputReleased(inputName:String) {
        if(gamepad == null || Input.released(inputName)) {
            return Input.released(inputName);
        }
        if(inputName == "jump") {
            return gamepad.released(XboxGamepad.A_BUTTON);
        }
        if(inputName == "action") {
            return gamepad.released(XboxGamepad.X_BUTTON);
        }
        if(inputName == "left") {
            return (
                gamepad.getAxis(0) >= -DEAD_ZONE
                && lastHorizontalAxis < -DEAD_ZONE
                || gamepad.released(XboxGamepad.DPAD_LEFT)
            );
        }
        if(inputName == "right") {
            return (
                gamepad.getAxis(0) <= DEAD_ZONE
                && lastHorizontalAxis > DEAD_ZONE
                || gamepad.released(XboxGamepad.DPAD_RIGHT)
            );
        }
        if(inputName == "up") {
            return (
                gamepad.getAxis(1) >= -DEAD_ZONE
                && lastVerticalAxis < -DEAD_ZONE
                || gamepad.released(XboxGamepad.DPAD_UP)
            );
        }
        if(inputName == "down") {
            return (
                gamepad.getAxis(1) <= DEAD_ZONE
                && lastVerticalAxis > DEAD_ZONE
                || gamepad.released(XboxGamepad.DPAD_DOWN)
            );
        }
        return false;
    }

    public static function inputCheck(inputName:String) {
        if(gamepad == null || Input.check(inputName)) {
            return Input.check(inputName);
        }
        if(inputName == "jump") {
            return gamepad.check(XboxGamepad.A_BUTTON);
        }
        if(inputName == "action") {
            return gamepad.check(XboxGamepad.X_BUTTON);
        }
        if(inputName == "left") {
            return (
                gamepad.getAxis(0) < -DEAD_ZONE
                || gamepad.check(XboxGamepad.DPAD_LEFT)
            );
        }
        if(inputName == "right") {
            return (
                gamepad.getAxis(0) > DEAD_ZONE
                || gamepad.check(XboxGamepad.DPAD_RIGHT)
            );
        }
        if(inputName == "up") {
            return (
                gamepad.getAxis(1) < -DEAD_ZONE
                || gamepad.check(XboxGamepad.DPAD_UP)
            );
        }
        if(inputName == "down") {
            return (
                gamepad.getAxis(1) > DEAD_ZONE
                || gamepad.check(XboxGamepad.DPAD_DOWN)
            );
        }
        return false;
    }
}
