package scenes;

import haxepunk.*;
import entities.*;

class GameScene extends Scene {
    override public function begin() {
        add(new Player(100, 100));
	}
}
