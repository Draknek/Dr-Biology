package
{
	import net.flashpunk.*;
	import net.flashpunk.debug.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.utils.*;
	
	import flash.net.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.system.*;
	import flash.desktop.*;
	import flash.display.*;
	import flash.ui.*;
	
	public class Main extends Engine
	{
		public static var TW:int = 36;
		
		public static var devMode:Boolean = true;
		
		public static var noeditor:Boolean = true;
		
		public static var touchscreen:Boolean = false;
		public static var isAndroid:Boolean = false;
		public static var isIOS:Boolean = false;
		public static var isPlaybook:Boolean = false;
		
		public static const so:SharedObject = SharedObject.getLocal("draknek/cells", "/");
		
		
		[Embed(source="levels.list", mimeType="application/octet-stream")]
		public static const LEVELS:Class;
		
		[Embed(source = 'fonts/Maian.ttf', embedAsCFF="false", fontFamily = 'maian')]
		public static const FONT1:Class;
		
		public static var MenuClass:Class;
		
		
		public function Main () 
		{
			if (Capabilities.manufacturer.toLowerCase().indexOf("ios") != -1) {
				isIOS = true;
				touchscreen = true;
			}
			else if (Capabilities.manufacturer.toLowerCase().indexOf("android") >= 0) {
				isAndroid = true;
				touchscreen = true;
			} else if (Capabilities.os.indexOf("QNX") >= 0) {
				isPlaybook = true;
				touchscreen = true;
			}
			
			if (! so.data.completed) {
				so.data.completed = [];
			}
			
			var w:int = 640;
			var h:int = 480;
			
			if (touchscreen) {
				try {
					Preloader.stage.displayState = StageDisplayState.FULL_SCREEN;
				} catch (e:Error) {}
				
				w = Preloader.stage.fullScreenWidth;
				h = Preloader.stage.fullScreenHeight;
				
				if (isAndroid && w < h) {
					var tmp:int = w;
					w = h;
					h = tmp;
				}
			} else {
				w = Preloader.stage.stageWidth;
				h = Preloader.stage.stageHeight;
			}
			
			super(w, h, 60, true);
		}
		
		public override function setStageProperties():void
		{
			super.setStageProperties();
			
			if (touchscreen) {
				try {
					stage.displayState = StageDisplayState.FULL_SCREEN;
				} catch (e:Error) {
					//stage.align = StageAlign.TOP;
					//stage.scaleMode = StageScaleMode.SHOW_ALL;
				}
			} else {
				stage.align = StageAlign.TOP;
				stage.scaleMode = StageScaleMode.SHOW_ALL;
			}
		}
		
		public override function init (): void
		{
			sitelock("draknek.org");
			
			Text.font = "maian";
			
			FP.screen.color = 0xFFFFFF;
			
			LevelData.readLevelPack(new LEVELS);
			
			Editor.init();
			
			super.init();
			
			var startWorld:World;
			
			if (stage.loaderInfo.parameters) {
				if (stage.loaderInfo.parameters.leveldata) {
					var dataString:String = stage.loaderInfo.parameters.leveldata;
					dataString = dataString.split(" ").join("+");
					
					var data:LevelData = new LevelData;
					data.fromString(dataString);
					
					startWorld = new Level(data);
					
					noeditor = true;
				}
				
				if (stage.loaderInfo.parameters.editor) {
					noeditor = false;
					startWorld = new Editor();
				}
				
				if (stage.loaderInfo.parameters.noeditor) {
					noeditor = true;
				}
			}
			
			if (! startWorld) startWorld = new Menu;
			
			//startWorld = new Level(null, 1);
			
			FP.world = startWorld;
			
			var menu:ContextMenu = contextMenu || new ContextMenu;
			
			menu.hideBuiltInItems();
			
			if (! noeditor) {
				menu.clipboardMenu = true;
				menu.clipboardItems.copy = true;
				menu.clipboardItems.paste = true;
				menu.clipboardItems.clear = true;
			
				addEventListener(Event.COPY, copyHandler);
				addEventListener(Event.PASTE, pasteHandler);
				addEventListener(Event.CLEAR, clearHandler);
			}
			
			contextMenu = menu;
		}
		
		private function copyHandler(event:Event):void 
		{
			var src:LevelData;
			
			var level:Level = FP.world as Level;
			
			if (level) {
				src = level.data;
			} else {
				src = Editor.data;
			}
			
			var levelcode:String = src.toString();
			
			if (FP.stage.loaderInfo.parameters && FP.stage.loaderInfo.parameters.editor) {
				levelcode = "http://draknek.org/games/drbiology/?level=" + levelcode;
			}
			
			System.setClipboard(levelcode);
		}
		
		private function pasteHandler(event:Event):void 
		{
			var clipboard:String = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
			
			var index:int = clipboard.indexOf('?');
			
			if (index != -1) {
				var index2:int = clipboard.indexOf('=', index);
				
				if (index2 == -1) {
					index += 1;
				} else {
					index = index2 + 1;
				}
				
				clipboard = clipboard.substring(index);
			}
			
			var level:Level = FP.world as Level;
			
			if (level) {
				var data:LevelData = new LevelData;
				data.fromString(clipboard);
				FP.world = new Level(data);
			}
			
			var editor:Editor = FP.world as Editor;
			
			if (editor) {
				Editor.data.fromString(clipboard);
			}
			
			//parseLevelPack(clipboard);
		}
		
		private function clearHandler(event:Event):void 
		{
			var level:Level = FP.world as Level;
			
			if (level) {
				//FP.world = new Level(level.src, level.id);
			}
			
			var editor:Editor = FP.world as Editor;
			
			if (editor) {
				Editor.clear();
			}
		}
		
		public override function update (): void
		{
			if (Input.pressed(FP.console.toggleKey)) {
				// Doesn't matter if it's called when already enabled
				FP.console.enable();
			}
			
			super.update();
		}
		
		[Embed(source="images/back.png")]
		public static const BgGfx: Class;
		
		[Embed(source="images/vignette.png")]
		public static const VignetteGfx: Class;
		
		public static var bg:Entity;
		public static var vignette:Bitmap;
		
		public override function preRender ():void
		{
			if (! bg) {
				bg = new Entity(0, 0, new Backdrop(BgGfx));
				vignette = new VignetteGfx;
			}
			
			bg.render();
			
			if (touchscreen) return;
			
			FP.buffer.draw(vignette, null, null, "overlay");
		}
		
		public function sitelock (allowed:*):Boolean
		{
			var url:String = FP.stage.loaderInfo.url;
			var startCheck:int = url.indexOf('://' ) + 3;
			
			if (url.substr(0, startCheck) != 'http://'
				&& url.substr(0, startCheck) != 'https://'
				&& url.substr(0, startCheck) != 'ftp://') return true;
			
			var domainLen:int = url.indexOf('/', startCheck) - startCheck;
			var host:String = url.substr(startCheck, domainLen);
			
			if (allowed is String) allowed = [allowed];
			for each (var d:String in allowed)
			{
				if (host.substr(-d.length, d.length) == d) return true;
			}
			
			parent.removeChild(this);
			throw new Error("Error: this game is sitelocked");
			
			return false;
		}
	}
}

