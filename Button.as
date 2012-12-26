package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Button extends Entity
	{
		public var image:Image;
		public var callback:Function;
		
		public var alpha:Number = 1.0;
		public var disabled:Boolean = false;
		
		public static var defaultColorTextNormal:uint = 0x6AAE26;
		public static var defaultColorTextHover:uint = 0x1F922E;
		public static var defaultColorImageNormal:uint = 0xFFFFFF;
		public static var defaultColorImageHover:uint = 0xCCCCCC;
		
		public var normalColor:uint;
		public var hoverColor:uint;
		
		public var over:Boolean;
		
		public static var lastPressed:Button;
		
		public function Button (_gfx:*, _callback:Function, options:Object = null)
		{
			if (_gfx is Image) {
				image = _gfx;
			} else {
				var textOpts:Object = {};
				textOpts.size = _gfx.size;
				//textOpts.font = "orbitron";
				textOpts.outlineStrength = 4.0;
				textOpts.outlineColor = defaultColorTextHover;
				textOpts.letterSpacing = 2.0;
			
				image = new Text(_gfx.text, 0, 0, textOpts);
			}
			
			if (image is Text) {
				normalColor = defaultColorTextNormal;
				hoverColor = defaultColorTextHover;
			} else {
				normalColor = defaultColorImageNormal;
				hoverColor = defaultColorImageHover;
			}
			
			if (options) {
				if (options.hasOwnProperty("normalColor")) normalColor = options.normalColor;
				if (options.hasOwnProperty("hoverColor")) hoverColor = options.hoverColor;
			}
			
			image.color = normalColor;
			
			image.scrollX = image.scrollY = 0;
			
			graphic = image;
			
			type = "button";
			
			width = image.scaledWidth;
			height = image.scaledHeight;
			
			callback = _callback;
		}
		
		public override function update (): void
		{
			if (disabled || !world || !collidable || !visible) {
				image.color = normalColor;
				over = false;
				return;
			}
			
			over = collidePoint(x, y, Input.mouseX, Input.mouseY);
			
			if (Main.touchscreen && ! Input.mouseDown) over = false;
			
			if (over) {
				Input.mouseCursor = "button";
			}
			
			image.color = over ? hoverColor : normalColor;
			
			if (image is Text) {
				Text(image).outlineColor = over ? FP.colorLerp(0x0, defaultColorTextHover, 0.8) : defaultColorTextHover;
				Text(image).updateTextBuffer();
			}
			
			if (over && Input.mousePressed && callback != null) {
				lastPressed = this;
				callback();
			}
		}
		
		public override function render (): void
		{
			if (world != FP.world) return;
			
			image.alpha = alpha * (disabled ? 0.5 : 1.0);
			
			super.render();
		}
	}
}

