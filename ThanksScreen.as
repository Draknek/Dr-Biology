package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class ThanksScreen extends World
	{	
		public function ThanksScreen ()
		{
			var scale:Number = FP.height / 480;
			
			Main.so.data.currentlevel = 0;
			Main.MenuClass = Menu;
			
			var title:Text = new Text("Dr. Biology's\nEducational Game", 0, 0, {
				//outlineStrength: 0.0, outlineColor: Button.defaultColorTextHover, letterSpacing: 0,
				size: 50*scale, color: 0x0E394E, align: "center"
			});
		
			title.x = (FP.width - title.width) * 0.5;
			//title.x = logo.x + logo.scaledWidth;
			title.y = 50*scale;
		
			addGraphic(title);
			
			var text:Text = new Text("Thanks for playing", 0, 0, {size: 30*scale, color: 0x0});
		
			text.x = (FP.width - text.width) * 0.5;
			text.y = title.y - text.height;
		
			addGraphic(text);
			
			text = new Text("!", 0, 0, {size: 50*scale, color: 0x0});
		
			text.x = title.x + title.width;
			text.y = title.y + title.height - text.height;
		
			addGraphic(text);
			
			text = new Text("If you enjoyed it, please\ncheck out my other games!", 0, 0, {size: 36*scale, color: 0x0, align: "center"});
		
			text.centerOO();
		
			text.x = FP.width * 0.5;
			text.y = FP.height * 0.5;
			
			addGraphic(text);
			
			
			var moreGamesImage:Image = new Image(Menu.MoreGamesGfx);
			moreGamesImage.scale = scale*0.25;
			moreGamesImage.smooth = true;
			
			var moreGamesButton:Button = new Button(moreGamesImage, Menu.gotoMoreGames);
			//moreGamesButton.x = FP.width - moreGamesButton.width - 10*scale;
			moreGamesButton.x = int((FP.width - moreGamesButton.width)*0.5);
			moreGamesButton.y = int(text.y + text.height*0.75);
			add(moreGamesButton);
			
			
			text = new Text("(and tell people about them)", 0, 0, {size: 36*scale, color: 0x0, align: "center"});
		
			text.centerOO();
		
			text.x = FP.width * 0.5;
			text.y = moreGamesButton.y + moreGamesButton.height + text.height*0.75;
			
			addGraphic(text);
			
			var buttonImage:Spritemap = new Spritemap(History.ButtonsGfx, 48, 48);
			buttonImage.scale = Main.SCALE_BUTTONS;
			buttonImage.smooth = true;
			buttonImage.frame = 2;
			
			var button:Button = new Button(buttonImage, gotoMenu);
			
			if (Main.touchscreen) {
				button.x -= button.width * (1 - 1.5)*0.3;
				button.y -= button.height * (1 - 1.5)*0.3;
			}
			
			add(button);
		}
		
		public override function update (): void
		{
			History.buttonsVisible = 1;
			
			Main.so.data.currentlevel = 0;
			
			Input.mouseCursor = "auto";
			
			if (Input.pressed(Key.ESCAPE) || Input.pressed(Key.SPACE) || Input.pressed(Key.ENTER)) {
				gotoMenu();
				return;
			}
			
			super.update();
		}
		
		public static function gotoMenu ():void
		{
			Audio.play("button_click");
			
			FP.world = new Menu;
		}
	}
}

