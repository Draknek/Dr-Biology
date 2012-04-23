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

