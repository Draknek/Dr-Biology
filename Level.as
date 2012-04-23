package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class Level extends World
	{
		public var bg:Tilemap;
		public var solidGrid:Grid;
		
		public var data:LevelData;
		
		public var id:int;
		
		public function Level (_data:LevelData = null, _id:int = 0)
		{
			data = _data;
			id = _id;
			
			if (id) {
				if (id > LevelData.levels.length) id = LevelData.levels.length;
				
				data = LevelData.levels[id - 1];
			}
			
			var tiles:Tilemap = data.tiles;
			
			bg = new Tilemap(Editor.EditTilesGfx, FP.width, FP.height, Main.TW, Main.TW);
			
			addGraphic(bg);
			
			solidGrid = new Grid(FP.width, FP.height, Main.TW, Main.TW);
			
			addMask(solidGrid, "solid");
			
			for (var i:int = 0; i < tiles.columns; i++) {
				for (var j:int = 0; j < tiles.rows; j++) {
					var tile:uint = tiles.getTile(i, j);
					
					if (tile == 0) continue;
					if (tile == 1) {
						bg.setTile(i, j, 1);
						solidGrid.setTile(i, j, true);
						continue;
					}
					
					var x:int = i*Main.TW;
					var y:int = j*Main.TW;
					
					add(new Cell(x, y, tile - 1));
				}
			}
			
			if (id >= LevelData.levels.length) {
				var title:Text = new Text("Thanks for playing\nDr. Biology's\nEducational Game!\n ", 0, 0, {size: 48, color: 0x0, align: "center"});
			
				title.centerOO();
			
				title.x = FP.width * 0.5;
				title.y = FP.height * 0.3;
			
				addGraphic(title);
				
				title = new Text("Made by Dr. Biology\n\nAnd Alan Hazelden\n ", 0, 0, {size: 36, color: 0x0, align: "center"});
			
				title.centerOO();
			
				title.x = FP.width * 0.5;
				title.y = FP.height * 0.7;
			
				addGraphic(title);
			}
		}
		
		public override function update (): void
		{
			Input.mouseCursor = "auto";
			
			if (Input.pressed(Key.E)) {
				FP.world = new Editor;
				return;
			}
			
			if (Input.pressed(Key.R)) {
				FP.world = new Level(data, id);
				return;
			}
			
			if (Input.pressed(Key.SPACE)) {
				FP.world = new Level(null, id+1);
				return;
			}
			
			super.update();
			
			var a:Array = [];
			
			getType("cell", a);
			
			var done:Boolean = true;
			
			if (a.length == 0) done = false;
			
			for each (var cell:Cell in a) {
				if (cell.splitsLeft > 0) {
					done = false;
					break;
				}
			}
			
			if (done) {
				Audio.play("yay");
				FP.alarm(60, function ():void {
					FP.world = new Level(null, id+1);
				});
			}
		}
		
		public override function render (): void
		{
			super.render();
		}
	}
}

