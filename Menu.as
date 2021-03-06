package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.net.*;
	
	public class Menu extends World
	{
		public var title:Text;
		
		[Embed(source="images/moregames.png")]
		public static const MoreGamesGfx: Class;
		
		public var moreGamesButton:Button;
		
		public function Menu ()
		{
			var scale:Number = FP.height / 480;
			
			title = new Text("Dr. Biology's\nEducational Game", 0, 0, {
				//outlineStrength: 0.0, outlineColor: Button.defaultColorTextHover, letterSpacing: 0,
				size: 50*scale, color: 0x0E394E, align: "center"
			});
			
			/*var logo:Image = new Image(LogoGfx);
			logo.scale = title.height / logo.height;
			logo.smooth = true;
			
			logo.x = (FP.width - logo.scaledWidth - title.width) * 0.5;
			logo.y = 50;
			
			/*logo.tintMode = 1.0;
			logo.color = title.color;*/
			
			title.x = (FP.width - title.width) * 0.5;
			//title.x = logo.x + logo.scaledWidth;
			title.y = 50*scale;
			
			//addGraphic(logo);
			addGraphic(title);
			
			var moreGamesImage:Image = new Image(MoreGamesGfx);
			moreGamesImage.scale = scale*0.25;
			moreGamesImage.smooth = true;
			
			moreGamesButton = new Button(moreGamesImage, gotoMoreGames);
			//moreGamesButton.x = FP.width - moreGamesButton.width - 10*scale;
			moreGamesButton.x = int((FP.width - moreGamesButton.width)*0.5);
			moreGamesButton.y = int(FP.height - moreGamesButton.height - 10*scale);
			add(moreGamesButton);
			
			var buttons:Array = [];
			
			var button:Button;
			
			var lastPlayed:int = Main.so.data.currentlevel;
			
			var playText:String = "Play";
			
			if (lastPlayed >= 2 && lastPlayed <= 12) {
				playText = "Continue";
			}
			
			button = new Button({text: playText, size: 40*scale}, gotoLevel);
			buttons.push(button);
			
			if (Main.so.data.completed[1]) {
				button = new Button({text: "Level select", size: 40*scale}, gotoLevelSelect);
				buttons.push(button);
			}
			
			button = new Button({text: "About", size: 40*scale}, gotoAbout);
			buttons.push(button);
			
			addButtons(buttons);
		}
		
		public static function gotoLevel ():void
		{
			Audio.play("button_click");
			
			var lastPlayed:int = Main.so.data.currentlevel;
			
			if (lastPlayed >= 1 && lastPlayed <= 12) {
				FP.world = new Level(null, lastPlayed);
			} else {
				FP.world = new Level(null, 1);
			}
		}
		
		public static function gotoLevelSelect ():void
		{
			Audio.play("button_click");
			
			FP.world = new LevelSelect;
		}
		
		public static function gotoAbout ():void
		{
			Audio.play("button_click");
			
			FP.world = new AboutScreen;
		}
		
		public static function gotoMoreGames ():void
		{
			Audio.play("button_click");
			
			var url:String = "http://www.draknek.org/games/more/?from=drbiology&platform=" + Main.platform;
			
			var urlRequest:URLRequest = new URLRequest(url);
			navigateToURL(urlRequest,'_blank');
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
			
			var padding:Number = (moreGamesButton.y - start - h) / (itemCount + 5);
			
			var y:Number = start + padding*2;
			
			for each (e in array) {
				e.x = (FP.width - e.width)*0.5;
				e.y = y;
				
				y += padding + e.height;
				
				add(e);
			}
		}
	}
}

