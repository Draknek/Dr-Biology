package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class Menu extends World
	{
		public var title:Text;
		
		[Embed(source="images/logocolour.png")]
		public static const LogoGfx: Class;
		
		public function Menu ()
		{
			title = new Text("Dr. Biology's\nEducational Game", 0, 0, {size: 48, color: Button.defaultColorTextNormal, outlineStrength: 4.0, outlineColor: Button.defaultColorTextHover});
			
			var logo:Image = new Image(LogoGfx);
			logo.scale = title.height / logo.height;
			logo.smooth = true;
			
			//logo.tintMode = 1.0;
			//logo.color = title.color;
			
			logo.x = (FP.width - logo.scaledWidth - title.width) * 0.5;
			logo.y = 50;
			
			title.x = logo.x + logo.scaledWidth;
			title.y = 50;
			
			addGraphic(logo);
			addGraphic(title);
			
			var buttons:Array = [];
			
			var button:Button;
			
			var lastPlayed:int = Main.so.data.currentlevel;
			
			var playText:String = "Play";
			
			if (lastPlayed >= 2 && lastPlayed <= 12) {
				playText = "Continue";
			}
			
			button = new Button({text: playText, size: 33}, gotoLevel);
			buttons.push(button);
			
			if (Main.so.data.completed[1]) {
				button = new Button({text: "Level select", size: 33}, gotoLevelSelect);
				buttons.push(button);
			}
			
			addButtons(buttons);
		}
		
		public static function gotoLevel ():void
		{
			var lastPlayed:int = Main.so.data.currentlevel;
			
			if (lastPlayed >= 1 && lastPlayed <= 12) {
				FP.world = new Level(null, lastPlayed);
			} else {
				FP.world = new Level(null, 1);
			}
		}
		
		public static function gotoLevelSelect ():void
		{
			FP.world = new LevelSelect;
		}
		
		public override function update ():void
		{
			History.buttonsVisible = 0;
			Main.MenuClass = Menu;
			Input.mouseCursor = "auto";
			super.update();
		}
		
		public function addButtons (array:Array):void
		{
			var e:Entity;
			
			var itemCount:int = 0;
			var h:Number = 0;
			
			for each (e in array) {
				if (! e) continue;
				h += e.height;
				
				itemCount += 1;
			}
			
			var start:Number = title.y + title.height;
			
			var padding:Number = (FP.height - start - h) / (itemCount + 4);
			
			var y:Number = start + padding*3;
			
			for each (e in array) {
				e.x = (FP.width - e.width)*0.5;
				e.y = y;
				
				y += padding + e.height;
				
				add(e);
			}
		}
	}
}

