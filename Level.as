package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.geom.*;
	
	public class Level extends World
	{
		public var data:LevelData;
		
		public var id:int;
		
		public var done:Boolean = false;
		
		public var nextLevel:World;
		
		public var actions:Array = [];
		
		public var busy:Boolean = false;
		
		public var history:History;
		
		public function Level (_data:LevelData = null, _id:int = 0)
		{
			data = _data;
			id = _id;
			
			FP.randomSeed = id;
			
			if (id) {
				if (id > LevelData.levels.length) id = LevelData.levels.length;
				
				data = LevelData.levels[id - 1];
			}
			
			var tiles:Tilemap = data.tiles;
			
			for (var i:int = 0; i < tiles.columns; i++) {
				for (var j:int = 0; j < tiles.rows; j++) {
					var tile:uint = tiles.getTile(i, j);
					
					if (tile == 0) continue;
					
					var x:int = i*Main.TW;
					var y:int = j*Main.TW;
					
					if (tile == 1) {
						add(new Wall(x + Main.TW*0.5, y + Main.TW*0.5));
					} else {
						add(new Cell(x + Main.TW*0.5, y + Main.TW*0.5, tile - 1));
					}
				}
			}
			
			history = new History(this);
			
			centerLevel();
		}
		
		public override function update (): void
		{
			Main.so.data.currentlevel = id;
			
			History.buttonsVisible = 3;
			
			var cell:Cell;
			
			Input.mouseCursor = "auto";
			
			super.update();
			
			history.update();
			
			while (actions.length && ! busy) {
				var action:* = actions.shift();
				
				if (action is Function) {
					action();
				} else {
					cell = action.cell;
					cell.split(action.dx, action.dy);
				}
			}
			
			/*if (Input.pressed(Key.F1)) {
				Audio.startRewind();
			}
			
			if (Input.pressed(Key.F2)) {
				Audio.stopRewind();
			}*/
			
			if (Input.pressed(Key.ESCAPE)) {
				gotoMenu();
				return;
			}
			
			if (nextLevel) return;
			
			if (Input.pressed(Key.E) && ! Main.noeditor) {
				FP.world = new Editor;
				return;
			}
			
			var a:Array = [];
			
			getType("cell", a);
			
			done = true;
			
			if (a.length == 0) done = false;
			
			for each (cell in a) {
				if (cell.splitsLeft > 0) {
					done = false;
					break;
				}
			}
			
			if (id != 0 && Input.pressed(Key.SPACE)) {
				done = true;
			}
			
			if (done) {
				Main.so.data.completed[id] = true;
				
				Audio.play("yay2");
				
				if (id != 0) {
					if (id == LevelData.levels.length - 1) {
						nextLevel = new ThanksScreen;
						FP.tween(history.buttons[1], {alpha: 0}, 60);
						FP.tween(history.buttons[2], {alpha: 0}, 60);
					} else {
						nextLevel = new Level(null, id+1);
					}
					
					nextLevel.updateLists();
					nextLevel.camera.x -= FP.width;
					
					var tweenTime:int = 30;
					var tweenDelay:int = 60;
					
					FP.tween(nextLevel.camera, {x: nextLevel.camera.x + FP.width}, tweenTime, {delay: tweenDelay});
					FP.tween(camera, {x: camera.x + FP.width}, tweenTime, {delay: tweenDelay, complete: onComplete, tweener: this});
					
					FP.alarm(tweenDelay*0.5, onComplete2);
				}
			}
		}
		
		public static function gotoMenu ():void
		{
			Audio.play("button_click");
			
			FP.world = new Main.MenuClass;
		}
		
		public function onComplete ():void
		{
			FP.world = nextLevel;
		}
		
		public function onComplete2 ():void
		{
			Audio.play("yay");
		}
		
		public function centerLevel ():void
		{
			centerLevelMagic(data.tiles, camera, id);
		}
		
		public static function centerLevelMagic (tiles:Tilemap, camera:Point, id:int, w:int = 0, h:int = 0):void
		{
			if (id == 0) return;
			
			if (!w) w = FP.width;
			if (!h) h = FP.height;
			
			var minX:int = 100;
			var minY:int = 100;
			var maxX:int = -100;
			var maxY:int = -100;
			
			var i:int;
			var j:int;
			
			for (i = 0; i < tiles.columns; i++) {
				for (j = 0; j < tiles.rows; j++) {
					var tile:uint = tiles.getTile(i, j);
					
					if (tile != 0) {
						if (i < minX) minX = i;
						if (j < minY) minY = j;
						if (i > maxX) maxX = i;
						if (j > maxY) maxY = j;
					}
				}
			}
			
			camera.x = (minX + maxX + 1) * Main.TW * 0.5 - w*0.5;
			camera.y = (minY + maxY + 1) * Main.TW * 0.5 - h*0.5;
		}
		
		public override function render (): void
		{
			super.render();
			
			if (nextLevel) {
				nextLevel.render();
			}
		}
		
		public function queueSplit (cell:Cell, dx:int, dy:int):void
		{
			actions.push({cell:cell, dx:dx, dy:dy});
		}
		
		public function unbusy ():void
		{
			busy = false;
		}
	}
}

