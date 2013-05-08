package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.text.*;
	
	public class AboutScreen extends World
	{
		public var credits:TextField;
		
		public function AboutScreen ()
		{
			var scale:Number = FP.height / 480;
			
			var title:Text = new Text("Dr. Biology's\nEducational Game", 0, 0, {
				//outlineStrength: 0.0, outlineColor: Button.defaultColorTextHover, letterSpacing: 0,
				size: 50*scale, color: 0x0E394E, align: "center"
			});
		
			title.x = (FP.width - title.width) * 0.5;
			//title.x = logo.x + logo.scaledWidth;
			title.y = 50*scale;
			
			//title.scrollX = title.scrollY = 0;
		
			addGraphic(title);
			
			credits = makeHTMLText('was created by Dr. Biology\nwith assistance from <a href="http://www.draknek.org/?ref=drbiology" target="_blank">Alan Hazelden</a>\n\nGraphics by <a href="https://twitter.com/tweetleewhat" target="_blank">Cap\'n Lee</a>\n\nAudio by <a href="http://www.metzopaino.com/" target="_blank">William Robinson</a>\n ', 32*scale, 0x0, "a {color: #1F922E;} a:hover {color: #145f1e;}");
			
			credits.x = FP.width * 0.5 - credits.width*0.5;
			credits.y = FP.height * 0.7 - credits.height*0.5;
			
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
			
			Input.mouseCursor = "auto";
			
			if (Input.pressed(Key.ESCAPE) || Input.pressed(Key.SPACE) || Input.pressed(Key.ENTER)) {
				gotoMenu();
				return;
			}
			
			super.update();
		}
		
		public override function begin ():void
		{
			FP.engine.addChild(credits);
		}
		
		public override function end ():void
		{
			FP.engine.removeChild(credits);
		}
		
		public static function gotoMenu ():void
		{
			Audio.play("button_click");
			
			FP.world = new Menu;
		}
		
		public static function makeHTMLText (html:String, size:Number, color:uint, css:String): TextField
		{
			var ss:StyleSheet = new StyleSheet();
			ss.parseCSS(css);
			
			var textField:TextField = new TextField;
			
			textField.selectable = false;
			textField.mouseEnabled = true;
			
			textField.embedFonts = true;
			
			textField.multiline = true;
			
			textField.autoSize = "center";
			
			textField.textColor = color;
			
			var format:TextFormat = new TextFormat(Text.font, size);
			format.align = "center";
			
			textField.defaultTextFormat = format;
			
			textField.htmlText = html;
			
			textField.styleSheet = ss;
			
			return textField;
		}
	}
}

