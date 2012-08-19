package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class Menu extends World
	{
		public function Menu ()
		{
			var title:Text = new Text("Dr. Biology's\nEducational Game", 0, 0, {size: 48, color: 0x0, align: "center"});
			
			title.centerOO();
			
			title.x = FP.width * 0.5;
			title.y = 100;
			
			addGraphic(title);
			
			var button:Button = new Button({text: "Play", size: 33}, function ():void {
				FP.world = new Level(null, 1);
			});
			
			button.x = (FP.width - button.width)*0.5;
			button.y = 280;
			
			add(button);
			
			button = new Button({text: "Level select", size: 33}, function ():void {
				FP.world = new LevelSelect;
			});
			
			button.x = (FP.width - button.width)*0.5;
			button.y = 340;
			
			add(button);
		}
		
		public override function update ():void
		{
			History.buttonsVisible = 0;
			Main.MenuClass = Menu;
			Input.mouseCursor = "auto";
			super.update();
		}
	}
}

