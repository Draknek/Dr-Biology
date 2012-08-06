package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class Wall extends Entity
	{
		[Embed(source="images/wall-complete.png")]
		public static const Gfx: Class;
		
		public var image:Image;
		
		public function Wall (_x:Number, _y:Number)
		{
			x = _x;
			y = _y;
			
			setHitbox(Main.TW, Main.TW, Main.TW*0.5, Main.TW*0.5);
			
			var sprite:Spritemap = new Spritemap(Gfx, 32, 32);
			
			sprite.add("wobble", FP.frames(0, sprite.frameCount), 0.1 + Math.random()*0.1);
			
			sprite.play("wobble");
			
			sprite.originX = sprite.originY = 16;
			
			sprite.angle = FP.rand(4) * 90;
			
			sprite.scaleX = FP.choose(1, -1);
			
			image = sprite;
			
			graphic = sprite;
			
			type = "solid";
		}
		
		public override function update (): void
		{
			super.update();
		}
	}
}

