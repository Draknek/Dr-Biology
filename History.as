package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.utils.*;
	
	public class History
	{
		public var level:Level;
		
		public var undoStack:Array = [];
		public var redoStack:Array = [];
		
		public var repeatUndo:int = 0;
		
		public var reseting:Boolean = false;
		
		[Embed(source="images/buttons.png")]
		public static const ButtonsGfx: Class;
		
		public function History (_level:Level)
		{
			level = _level;
			
			const BUTTON_CALLBACKS: Array = [function ():void {FP.world = new Menu;}, reset, queueUndo];
			
			for (var i:int = 0; i < BUTTON_CALLBACKS.length; i++) {
				var image:Spritemap = new Spritemap(ButtonsGfx, 32, 32);
				image.frame = i;
				
				var button:Button = new Button(image, BUTTON_CALLBACKS[i]);
				button.x = i*button.width;
				
				level.add(button);
			}
		}
		
		public function moved (undoData:Object):void
		{
			redoStack.length = 0;
			undoStack.push(undoData);
		}
		
		public function update ():void
		{
			var delta:int = 0;
			
			if (Input.check(Key.CONTROL) || Input.check(Key.COMMAND)) {
				if (Input.pressed(Key.Z)) {
					queueUndo();
				}
				
				if (Input.pressed(Key.Y)) {
					queueRedo();
				}
				
				delta = int(Input.check(Key.Z)) - int(Input.check(Key.Y));
			}
			
			if (delta && delta*repeatUndo >= 0) {
				repeatUndo += delta;
			} else {
				repeatUndo = 0;
			}
			
			if (Input.pressed(Key.R)) {
				reset();
			}
			
			if (level.busy) {
				return;
			}
			
			if (level.actions.length == 0) {
				if (repeatUndo > 45) {
					queueUndo();
				}
				if (repeatUndo < -45) {
					queueRedo();
				}
			}
		}
		
		public function reset ():void
		{
			for (var i:int = 0; i < undoStack.length; i++) {
				reseting = true;
				level.actions.push(undo);
			}
			
			level.actions.push(endReset);
		}
		
		private function endReset ():void
		{
			reseting = false;
		}
		
		public function queueUndo ():void
		{
			if (undoStack.length == 0) return;
			
			level.actions.push(undo);
		}
		
		public function queueRedo ():void
		{
			//if (redoStack.length == 0) return;
			//actions.push(redo);
		}
		
		private function undo ():void
		{
			var undoData:Object = undoStack.pop();
			
			var dx:int = undoData.dx * Main.TW;
			var dy:int = undoData.dy * Main.TW;
			
			level.busy = true;
			
			var cell:Cell;
			
			var time:int = 10;
			
			for each (cell in undoData.pushed) {
				FP.tween(cell, {x: cell.x - dx, y: cell.y - dy}, time);
			}
			
			cell = undoData.newCell;
			
			FP.tween(cell, {x: cell.x - dx, y: cell.y - dy}, time, function ():void {
				level.remove(undoData.newCell);
				undoData.origCell.splitsLeft++;
				level.unbusy();
			});
		}
		
		/*private function redo ():void
		{
			var state:Object = redoStack.pop();
			
			if (! state) {
				level.canMove = true;
				return;
			}
			
			undoStack.push(state);
			
			var pair:Array;
			var atom:*;
			
			for each (pair in state.killedBonds) {
				FP.remove(pair[0].bonds, pair[1]);
				FP.remove(pair[1].bonds, pair[0]);
			}
			
			var time:int = 8;
			
			for each (atom in state.atoms) {
				FP.tween(atom.atom, {x: atom.afterX, y: atom.afterY}, time);
			}
			
			FP.alarm(time, function ():void {
				level.canMove = true;
				
				for each (atom in state.atoms) {
					atom.atom.bonds = atom.bondsAfter.slice();
					atom.atom.isPlayer = atom.isPlayerAfter;
				}
			});
		}*/
	}
}

