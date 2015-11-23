package
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import game.ui.mike.Alert;
	import game.ui.mike.OptionsUI;
	import game.ui.mike.RoomSizer;
	import game.ui.mike.SquarePillarSizer;
	
	import morn.core.components.Box;
	import morn.core.components.Dialog;
	import morn.core.events.UIEvent;
	import morn.core.handlers.Handler;
	
	import rightaway3d.house.editor2d.AddItemManager;
	import rightaway3d.house.lib.CabinetLib;
	
	public class MikeUI extends Sprite
	{
		private static var _instance:MikeUI;
		public var mainUI:MainUI;
		
		// 树选择Item的处理方法
		public var treeSelectHandler:Function;
		// 列表选择Item的处理方法
		public var listSelectHandler:Function;
		// 底部Btns选择Item的处理方法
		public var bottomBtnsHandler:Function;
		
		public var mainBtnPressed:Function;
		
		public var itemList:XMLList;
		
		// BottomBtns max row number
		public var maxRowNumber:int = 6;
		
		public var dialog:Alert;
		
		// 下方按钮列表内容
		public var bbtns:Array = ['删除', '生成面板', '重建台面', '生成面板', '重建台面', '生成面板', '重建台面'];
		
		public var icons:Array = ["removeCb.png","remove.png","removeB.png","left.png","right.png","update.png","hideCb.png","off.png","house.png","pillar.png","addItem.png","set.png"]
		
		public var roomSizer:RoomSizer;
		
		public var pillarSizer:SquarePillarSizer;
		
		//选项菜单
		private var options:OptionsUI;
		
		public function MikeUI()
		{
			addItemManager = new AddItemManager;
			
			CabinetLib.lib.addEventListener(Event.COMPLETE, function():void {
				App.init(instance);
				App.loader.loadAssets(['assets/comp.swf'], new Handler(uiLoadComplete));
			});
		}
		
		static public function get instance():MikeUI
		{
			return _instance ||= new MikeUI();
		}
		
		/**
		 * 设置底部的BottomBts内容, 参数为一个String数组,
		 * 如不指针arr,默认为 MikeUI.instance.bbtns
		 */
		public function setBottomBtns(arr:Array = null):void {
			if (!arr) {
				arr = bbtns;
			}
			
			var realArr:Array = [];
			
			for (var i:int = 0;i < arr.length; i++) {
				realArr.push({label:arr[i],icon:"assets/icon/menus/"+icons[i]});
			}
			
			mainUI.bottomBtns.array = realArr;
			
			var w:int = Math.floor(stage.stageWidth / 95) - 1;
			maxRowNumber = arr.length < maxRowNumber ? arr.length : maxRowNumber;
			w = w > maxRowNumber ? maxRowNumber : w;
			
			mainUI.bottomBtns.width = w * 98 - 5;
			mainUI.bottomBtns.height = Math.ceil(realArr.length / w) * 26;
		}
		
		
		private function onStageResize(e:Event=null):void
		{
			if(!stage)return;
			
			if (mainUI) {
				mainUI.stageWidth = stage.stageWidth;
				mainUI.stageHeight = stage.stageHeight;
				mainUI.width = stage.stageWidth;
				mainUI.height = stage.stageHeight;
				//trace(mainUI.width,mainUI.height)
				mainUI.resizeContent();
			}
			
			if(options)
			{
				options.stageWidth = stage.stageWidth;
				options.stageHeight = stage.stageHeight;
				options.resizeContent();
			}
			
			if(roomSizer)
			{
				roomSizer.stageWidth = stage.stageWidth;
				roomSizer.stageHeight = stage.stageHeight;
				roomSizer.resizeContent();
			}
			
			if(pillarSizer)
			{
				pillarSizer.stageWidth = stage.stageWidth;
				pillarSizer.stageHeight = stage.stageHeight;
				pillarSizer.resizeContent();
			}
			
			
			setBottomBtns();
		}
		
		public function uiLoadComplete():void {
			mainUI = new MainUI();
			addChild(mainUI);
			mainUI.stageWidth = stage.stageWidth;
			mainUI.stageHeight = stage.stageHeight;
			mainUI.initUI();
			mainUI.list.array = [];
			mainUI.tree.xml = CabinetLib.lib.getProductTypeList();
			
			setBottomBtns();
			
			//			bottomBtnsHandler = function(item):void {
			//				trace(item);
			//			}
			
			treeSelectHandler = function(item):void {
				var arr:Array = [];
				mainUI.list.selectedIndex = -1;
				var dataList:XMLList = CabinetLib.lib.getProductList(item.type, item.cate);
				itemList = dataList;
				
				if (dataList.length() > 0) {
					mainUI.assets.width = 410;
					mainUI.list.visible = true;
					//mainUI.width = 410;
					//mainUI.mouseEnabled = mainUI.mouseChildren = true;
				} else {
					mainUI.assets.width = 150;
					mainUI.list.visible = false;
					//mainUI.width = 150;
					//mainUI.mouseEnabled = mainUI.mouseChildren = false;
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
			
			dialog = new Alert();
			dialog.yes_btn.showBorder(0xFFFFFF);
			dialog.no_btn.showBorder(0xFFFFFF);
			dialog.no_btn.buttonMode = dialog.yes_btn.buttonMode = true;
			dialog.closeHandler = new Handler(onDialogClosed);
			
			// create Btn Click
			//			mainUI.createBtn.addEventListener(MouseEvent.CLICK, function():void {
			//				if(createBtnClick) {
			//					createBtnClick();
			//				}
			//			});
			
			// delete Btn Click
			//			mainUI.deleteBtn.addEventListener(MouseEvent.CLICK, function():void {
			//				if(deleteBtnClick) {
			//					deleteBtnClick();
			//				}
			//			});
			
			
			
			stage.addEventListener(Event.RESIZE, onStageResize);
			onStageResize(null);
		}
		
		private var onDialogOkFun:Function;
		
		public function showPopDialog(tipMsg:String,onOkFun:Function):void
		{
			onDialogOkFun = onOkFun;
			
			dialog.msg_label.text = tipMsg;
			dialog.popup();
		}
		
		
		private function onDialogClosed(type:String):void
		{
			trace("onDialogClosed:"+type);
			if(type==Dialog.YES)
			{
				//this.clearAllCabinetObject();
				if(onDialogOkFun)
				{
					onDialogOkFun();
					onDialogOkFun = null;
				}
			}
		}
		
		
		public var addItemManager:AddItemManager;
		/**
		 *显示增项菜单 
		 * 
		 */		
		public function showAddItemMenu():void
		{
			
			mainUI.showAddItemMenu();
			if(!mainUI.addItemList.hasEventListener(MainUI.ADDITEM_ADD))
			{
				mainUI.addItemList.addEventListener(MainUI.ADDITEM_ADD,onAddItemAdd);
				mainUI.addItemList.addEventListener(MainUI.ADDITEM_REMOVE,onAddItemRemove);
				mainUI.addEventListener(MainUI.ADDITEM_SEARCH,onAddItemSearch);
			}
			var dataSource:Array = addItemManager.getItems();
			if(dataSource.length==0)
			{
				mainUI.showNoDataHint();
			}else
			{
				mainUI.update(dataSource);
			}
			
			trace(addItemManager.getItems().length)
			
		}
		
		public function hideAddItemMenu():void
		{
			mainUI.hideAddItemMenu();
		}
		protected function onAddItemSearch(event:UIEvent):void
		{
			//event.data//
			trace("搜索")
			addItemManager.getProductInfo(1,null,function ():void{trace("ddd")});
			
		}
		
		protected function onAddItemRemove(event:UIEvent):void
		{
			addItemManager.removeItem(event.data);
			mainUI.update(addItemManager.getItems());;
		}
		
		protected function onAddItemAdd(event:UIEvent):void
		{
			addItemManager.addItem(event.data);
			mainUI.update(addItemManager.getItems());
		}
		
		
		
		//	====================================================选项设置======================================
		//	====================================================选项设置======================================
		//	====================================================选项设置======================================
		//	====================================================选项设置======================================
		//	====================================================选项设置======================================
		
		/**
		 *显示选项设置菜单 
		 * 
		 */		
		public function showOptionsMenu():void
		{
			if(!options)
			{
				options = new OptionsUI();
				onStageResize();
			}
			options.showOptionsUI(this);
		}
		
		
		public function showRoomSizer(roomWidth:int,roomDepth:int,wallWidth:int):void
		{
			if(!roomSizer)
			{
				roomSizer = new RoomSizer();
				onStageResize();
			}
			
			roomSizer.show(this);
			roomSizer.roomWidth_txt.text = String(roomWidth);
			roomSizer.roomDepth_txt.text = String(roomDepth);
			roomSizer.wallWidth_txt.text = String(wallWidth);
		}
		
		public function showSquarePillarSizer(pillarWidth:int,pillarDepth:int):void
		{
			if(!pillarSizer)
			{
				pillarSizer = new SquarePillarSizer();
				onStageResize();
			}
			
			pillarSizer.show(this);
			pillarSizer.pillarWidth_txt.text = String(pillarWidth);
			pillarSizer.pillarDepth_txt.text = String(pillarDepth);
		}
		
	}
}