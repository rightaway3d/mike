package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import morn.core.handlers.Handler;
	
	import rightaway3d.house.lib.CabinetLib;
	
	public class MikeUI extends Sprite
	{
		public static var instance:MikeUI;
		public var mainUI:MainUI;
		
		public var treeSelectHandler:Function;
		public var listSelectHandler:Function;
		
		public var itemList:XMLList;
		
		public function MikeUI()
		{
			if (!instance) {
				instance = this;
			}
			
			CabinetLib.lib.addEventListener(Event.COMPLETE, function():void {
				App.init(instance);
				App.loader.loadAssets(['assets/comp.swf'], new Handler(uiLoadComplete));
			});
		}
		
		private function onStageResize(e:Event):void {
			if (mainUI) {
				mainUI.width = stage.stageWidth;
				mainUI.height = stage.stageHeight;
			}
		}
		
		public function uiLoadComplete():void {
			mainUI = new MainUI();
			mainUI.list.array = [];
			mainUI.tree.xml = CabinetLib.lib.getProductTypeList();
			
//			listSelectHandler = function(item):void {
//				trace(item);
//			};
			
			treeSelectHandler = function(item):void {
				var arr:Array = [];
				mainUI.list.selectedIndex = -1;
				var dataList:XMLList = CabinetLib.lib.getProductList(item.type, item.cate);
				itemList = dataList;
				
				if (dataList.length() > 0) {
					mainUI.assets.width = 390;
				} else {
					mainUI.assets.width = 130;
				}
				
				for each( var xml:XML in dataList) {
					var _name:String = xml.name
					var _spce:String = xml.spce;
					var _price:String = xml.price + ' 元';
					var _desc:String = xml.dscp;
					var _image:String = xml.image;
					arr.push({
						name: _name,
						size: _spce,
						price: _price,
						desc: _desc,
						image:_image
					});
				}

				mainUI.list.array = arr;
			};
			
			addChild(mainUI);
			stage.addEventListener(Event.RESIZE, onStageResize);
			onStageResize(null);
		}
	}
}