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
	import flash.ui.*;
	
	public class Main extends Engine
	{
		public static var TW:int = 36;
		
		public static var devMode:Boolean = true;
		
		public static var noeditor:Boolean = false;
		
		public static const so:SharedObject = SharedObject.getLocal("draknek/cells", "/");
		
		
		[Embed(source="levels.list", mimeType="application/octet-stream")]
		public static const LEVELS:Class;
		
		[Embed(source = 'fonts/Maian.ttf', embedAsCFF="false", fontFamily = 'maian')]
		public static const FONT1:Class;
		
		
		public function Main () 
		{
			super(640, 480, 60, true);
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
					startWorld = new Editor();
				}
				
				if (stage.loaderInfo.parameters.noeditor) {
					noeditor = true;
				}
			}
			
			if (! startWorld) startWorld = new Menu;
			
			startWorld = new Level(null, 1);
			
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
		
		public function sitelock (allowed:*):Boolean
		{
			var url:String = FP.stage.loaderInfo.url;
			var startCheck:int = url.indexOf('://' ) + 3;
			
			if (url.substr(0, startCheck) == 'file://') return true;
			
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

