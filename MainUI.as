package
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;
	
	import game.ui.mike.AddItemListUI;
	import game.ui.mike.mainUI;
	
	import morn.core.components.Box;
	import morn.core.components.Button;
	import morn.core.components.Container;
	import morn.core.components.Image;
	import morn.core.components.Label;
	import morn.core.components.List;
	import morn.core.components.TextInput;
	import morn.core.components.Tree;
	import morn.core.events.UIEvent;
	import morn.core.handlers.Handler;
	
	import ztc.utils.Tween;
	
	public class MainUI extends mainUI
	{
		
		public static var ADDITEM_ADD:String = "additem_add";
		public static var ADDITEM_REMOVE:String = "additem_remove";
		public static var ADDITEM_SEARCH:String = "additem_search";
		public var assets:Container;
		public var tree:Tree;
		public var list:List;
		public var mainBtn:Box;
		public var bottomBtns:List;
		public var uiShow:Boolean = true;
		/**
		 * 增项详情输入面板 
		 */		
		public var addItemInfo:Box;
		
		/**
		 * 增项详情修改面板 
		 */	
		public var addItemInfoChange:Box;
		
		private var originalX:Number;
		
		public var array:Array = new Array;
		public var stageWidth:int=0;
		public var stageHeight:int = 0;
		
		public function MainUI()
		{
			super();
			
		}
		
		public function initUI():void
		{
			// container
			assets = getChildByName('assets') as Container;
			originalX = assets.x;
			// 树
			tree = assets.getChildByName('tree') as Tree;
			tree.mouseHandler = new Handler(treeMouseHandler);
			// List
			list = assets.getChildByName('list') as List;
			list.mouseHandler = new Handler(listMouseHandler);
			// mainBtn
			mainBtn = getChildByName('mainBtn') as Box;
			mainBtn.addEventListener(MouseEvent.CLICK, onMainBtnClick);
			// bottomBtns
			bottomBtns = getChildByName('bottomBtns') as List;
			bottomBtns.mouseHandler = new Handler(bottomBtnsHandler);
			bottomBtns.visible = false;
			addItemInfo = new Box;
			addItemMenu = new Box;
			addItemInfoChange = new Box;
			createAddItemInfoMenu();
			createAddItemListMenu();
			createAddItemInfoChange();
		}
		
		private function bottomBtnsHandler(e:MouseEvent, index:int):void
		{
			if (e.type == MouseEvent.CLICK) {
				if (MikeUI.instance.bottomBtnsHandler) {
					MikeUI.instance.bottomBtnsHandler(bottomBtns.selectedItem.label);
				}
			}						
		}
		
		protected function onMainBtnClick(event:MouseEvent):void
		{
			mainBtn.mouseChildren = false;
			mainBtn.mouseChildren = false;
			assets.visible = true;
			var alpha:Number, x:Number;
			assets.alpha = uiShow ? 0 : 1.0;
			assets.x = uiShow ? originalX - 200 : originalX;
			Tween.Instance.action(assets, .4, {
				alpha: uiShow ? 1.0 : 0.0,
				x : uiShow ? originalX : originalX - 200.0
			}, Tween.EaseOutBack, function():void {
				assets.visible = uiShow;
				uiShow = !uiShow;
				mainBtn.mouseEnabled = true;
				mainBtn.mouseChildren = true;
				bottomBtns.visible = !uiShow;
				
				if(MikeUI.instance.mainBtnPressed) {
					MikeUI.instance.mainBtnPressed(uiShow);
				}
			});
		}
		
		private function listMouseHandler(e:MouseEvent, index:int):void
		{
			if(e.type == MouseEvent.CLICK) {
				e.stopPropagation();
				if (MikeUI.instance.listSelectHandler) {
					MikeUI.instance.listSelectHandler(MikeUI.instance.itemList[index]);
				}
			}	
		}
		
		private function treeMouseHandler(e:MouseEvent, index:int):void
		{
			if(e.type == MouseEvent.CLICK) {
				if(MikeUI.instance.treeSelectHandler) {
					MikeUI.instance.treeSelectHandler(tree.selectedItem);
				}
			}			
		}
		
		/*=========================================================*/
		
		public var addItemMenu:Box;
		public var addItemList:List;
		/**
		 *显示增值面板 
		 */		
		public function showAddItemMenu():void
		{
			var bg:Sprite = new Sprite();
			bg.graphics.beginFill(0x0,0.3);
			bg.graphics.drawRect(0,0,stageWidth,stageHeight);
			
			bg.name = "maxBg";
			addChild(addItemMenu);
			addChildAt(bg,numChildren-1);
		}
		/**
		 * 隐藏增值面板
		 */		
		public function hideAddItemMenu():void
		{
			removeChildByName("maxBg");
			removeChild(addItemMenu);
		}
		
		
		private var isShowNoData:Boolean = false;
		/**
		 *显示无数据提示 
		 * 
		 */		
		public function showNoDataHint():void
		{
			if(!isShowNoData)
			{
				var label:Label = new Label("暂时没有增项，请点击添加按钮添加.");
				label.color = 0xFFFFFF;
				label.size = 20;
				label.setSize(680,50);
				label.align = "center";
				label.y = (500-50)/2;
				addItemMenu.addChild(label);
				label.name = "noDataHint";
			}
			
			isShowNoData = true;
		}
		/**
		 *移除无数据提示 
		 * 
		 */		
		public function hideNoDataHint():void
		{
			if(isShowNoData )
			{
				addItemMenu.removeChildByName("noDataHint");
				
			}
			isShowNoData = false;
		}
		
		/**
		 *创建增值面板 
		 * 
		 */		
		private function createAddItemListMenu():void
		{
			var bg:Shape = new Shape();
			bg.graphics.beginFill(0x0,0.5);
			bg.graphics.drawRect(0,0,680,500);
			bg.graphics.endFill();
			addItemMenu.addChild(bg);
			var title:Label = new Label("增项列表");
			title.size = 20;
			title.setSize(680,30);
			title.align = "center";
			title.color = 0xFFFFFF;
			addItemMenu.addChild(title);
			title.y = 20;
			
			var closeBtn:Button = new Button("png.comp.icon_close_large");
			closeBtn.setSize(25,20);
			closeBtn.x = 680-30;
			closeBtn.y = 5;
			addItemMenu.addChild(closeBtn);
			closeBtn.clickHandler = new Handler(addItemMenuClose);
			closeBtn.stateNum = 1;
			closeBtn.buttonMode = true;
			var item:AddItemListUI = new AddItemListUI()
			addItemMenu.addChild(item);
			addItemList  = item.getChildByName("addItemList") as List;
//			for (var i:int = 0; i < 20; i++) 
//			{
//				var obj:Object = new Object;
//				obj.name = i.toString();
//				obj.specifications = i.toString();
//				obj.memo = i.toString();
//				obj.price = i.toString();
//				obj.totalPrice = i.toString();
//				array.push(obj)
//			}
			
//			array.push({name:"1"},{name:"2"},{name:"3"},{name:"4"},{name:"5"},{name:"6"},{name:"7"},{name:"8"},{name:"9"},{name:"10"});
			addItemList.dataSource = [];
			
			addItemList.repeatY = 4;
			addItemList.repeatX=1;
			addItemList.height = 350;
			addItemList.spaceY = 10;
			addItemList.y = 80;
			addItemList.x = 20;
//			addItemList.addEventListener(UIEvent.ITEM_RENDER,onListChange);
			
			var addRenderItem:Button = new Button();
			addRenderItem.label = "添加";
			addRenderItem.labelBold = true;
			addRenderItem.setSize(110,30);
			addRenderItem.labelColors="0xFFFFFF,0xFFFFFF,0xFFFFFF";
			addItemMenu.addChild(addRenderItem);
			addRenderItem.labelSize = 20;
			addRenderItem.x = (680-110)>>1;
			addRenderItem.y = 500-60;
			addRenderItem.buttonMode = true;
			addRenderItem.clickHandler = new Handler(addRenderItemClick);
			addRenderItem.showBorder(0xFFFFFF);
//			addItemList.scrollBar.showButtons = false;
			addItemList.renderHandler = new Handler(renderHandler);
			addItemList.selectHandler = new Handler(addItemListSelect);
			
			addItemMenu.x = (stageWidth-680)>>1;
			addItemMenu.y = (stageHeight-500)>>1;
		}
		
//		protected function onListChange(event:Event):void
//		{
//			trace("------------------")			
//		}		
		
		
		
		private function addItemRemoveHint(title:String,okFun:Function,cancelFun:Function):void
		{
			var group:Box = new Box;
			var bg:Shape = new Shape();
			bg.graphics.beginFill(0x0,0.5);
			bg.graphics.drawRect(0,0,300,150);
			bg.graphics.endFill();
			group.addChild(bg);
			var hintInfo:Label = new Label(title);
			hintInfo.size = 16;
			hintInfo.align = "center";
			hintInfo.setSize(300,30)
			hintInfo.color = 0xFFFFFF;
			hintInfo.y = (150-30)/2-10;
			group.addChild(hintInfo);
			var okBtn:Button = new Button(null,"确认");
			var cancelBtn:Button = new Button(null,"取消");
			cancelBtn.setSize(80,30);
			okBtn.setSize(80,30);
			okBtn.labelSize = cancelBtn.labelSize = 16;
			okBtn.showBorder(0xFFFFFF);
			cancelBtn.showBorder(0xFFFFFF);
			cancelBtn.labelColors = okBtn.labelColors = "0xFFFFFF,0xFFFFFF,0xFFFFFF";
			group.addChild(okBtn);
			group.addChild(cancelBtn);
			okBtn.x = 50;
			cancelBtn.x = 170;
			okBtn.y = cancelBtn.y = 100;
			addChild(group);
			okBtn.addEventListener(MouseEvent.CLICK,okFun);
			cancelBtn.addEventListener(MouseEvent.CLICK,cancelFun);
			group.name = "roemveHint";
			group.x = (stageWidth-300)/2;
			group.y = (stageHeight-200)/2;
		}
		
		
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		/**
		 *创建增项详情信息 
		 * tag [productIDText,productNameText,productSpecText,productNumText,productUnitText,productPriceText,productTotalPricesText]
		 */
		public function createAddItemInfoMenu():void
		{
			var bg:Shape = new Shape();
			bg.graphics.beginFill(0x0,0.5);
			bg.graphics.drawRect(0,0,400,550);
			bg.graphics.endFill();
			addItemInfo.addChild(bg);
			var title:Label = new Label("增项");
			title.size = 25;
			title.setSize(400,50);
			title.align = "center";
			title.color = 0xFFFFFF;
			addItemInfo.addChild(title);
			title.x = (bg.width-title.width)/2;
			title.y = 30;
			var obj:Object= new Object;
			obj.productIDText = createAddItemInfoTitle(addItemInfo,"物料编号:",100-30);
			obj.productNameText = createAddItemInfoTitle(addItemInfo,"物品名称:",150-30);
			obj.productSpecText = createAddItemInfoTitle(addItemInfo,"规格:",200-30);
			obj.productModelText = createAddItemInfoTitle(addItemInfo,"型号:",250-30);
			obj.productNumText = createAddItemInfoTitle(addItemInfo,"数量:",300-30);
			obj.productUnitText = createAddItemInfoTitle(addItemInfo,"单位:",350-30);
			obj.productPriceText = createAddItemInfoTitle(addItemInfo,"单价:",400-30);
			obj.productTotalPricesText = createAddItemInfoTitle(addItemInfo,"总价:",450-30,"label");
			(obj.productPriceText as TextInput).addEventListener(Event.CHANGE,calculationItemInfoTotalPrices);
			(obj.productPriceText as TextInput).restrict = "0-9";
			(obj.productNumText as TextInput).addEventListener(Event.CHANGE,calculationItemInfoTotalPrices);
			(obj.productNumText as TextInput).restrict = "0-9";
			addItemInfo.tag = obj;
			var searchBtn:Button = new Button();
			searchBtn.skin="png.comp.search";
			searchBtn.scale = 0.6;
			searchBtn.stateNum = 1;
			searchBtn.name = "searchBtn";
			addItemInfo.addChild(searchBtn);
			searchBtn.x = 360;
			searchBtn.y = 100-30;
			searchBtn.buttonMode = true;
			searchBtn.clickHandler = new Handler(searchFun);
			
			var closeBtn:Button = new Button();
			closeBtn.setSize( 60,30);
			closeBtn.label = "取消";
			addItemInfo.addChild(closeBtn);
			closeBtn.showBorder(0xFFFFFF);
			
			var okBtn:Button = new Button();
			okBtn.setSize( 60,30);
			okBtn.label = "确定";
			
			addItemInfo.addChild(okBtn);
			okBtn.showBorder(0xFFFFFF);
			okBtn.x = 75;
			closeBtn.x = 270;
			closeBtn.labelSize = okBtn.labelSize = 18;
			closeBtn.labelColors = okBtn.labelColors = "0xFFFFFF,0xFFFFFF,0xFFFFFF";
			
			closeBtn.clickHandler = new Handler(addItemInfoCloseClick,[addItemInfo]);
			okBtn.clickHandler = new Handler(addItemInfoOkClick);
			okBtn.y = closeBtn.y = 500;
			okBtn.buttonMode = closeBtn.buttonMode = true;
			
			addItemInfo.x = (stageWidth-addItemInfo.width)>>1;
			addItemInfo.y = (stageHeight-addItemInfo.height)>>1;
		}
				
		/**
		 *计算 总价 
		 * @param event
		 * 
		 */		
		protected function calculationItemInfoTotalPricesChangePanel(event:Event):void
		{
			var tag:Object = addItemInfoChange.tag;
			var str:String = tag.productPriceText.text;
			var index:int =str.indexOf(" ");
			var newStr:String = index>0?str.slice(0,index):str;;
			var price:int = parseInt(newStr);
			trace(tag.productNumText.text)
			var num:int = tag.productNumText.text;
			tag.productTotalPricesText.text =(price*num)+" 元";
		}
		
		protected function calculationItemInfoTotalPrices(event:Event):void
		{
			var tag:Object = addItemInfo.tag;
			var str:String = tag.productPriceText.text;
			var index:int =str.indexOf(" ");
			var newStr:String = index>0?str.slice(0,index):str;
							
			var price:int = parseInt(newStr);

			var num:int = tag.productNumText.text;
			tag.productTotalPricesText.text =(price*num)+" 元";
		}
		
		private function createAddItemInfoTitle(parentDisplay:DisplayObjectContainer,titleStr:String,_y:int,type:String="textInput"):Label
		{
			var group:Box = new Box;
			group.name = "group";
			var title:Label = new Label(titleStr);
			title.size = 18;
			title.color = 0xFFFFFF;
			title.align = TextFormatAlign.LEFT;
			title.setSize(100,30);
			title.x = 18;
			title.y = 5;
			var lineW:int = 0;
			var lineH:int = 0;
			if(type=="textInput")
			{
				var inputText:TextInput = new TextInput();
				inputText.align = "center";
				inputText.size = 18;
				inputText.color = 0xFFFFFF;
				inputText.setSize(230,30);
				inputText.x = 130;
				group.addChild(inputText);
				lineW = inputText.width;
				lineH = inputText.height
			}else
			{
				var label:Label = new Label("");
				label.align = "center";
				label.size = 18;
				label.color = 0xFFFFFF;
				label.setSize(230,30);
				label.x = 130;
				group.addChild(label);
				lineW = label.width;
				lineH = label.height
			}
			
			var line:Shape = new Shape;
			line.graphics.lineStyle(1,0xEEEEEE,0.8);
			line.graphics.moveTo(120,lineH);
			line.graphics.lineTo(380,lineH);
			line.graphics.endFill();
			group.addChild(title);
			
			group.addChild(line);
			parentDisplay.addChild(group);
			group.y = _y;
			if(type=="textInput")
			{
				return inputText;
			}else
			{
				return label;
			}
		}
		//////////////////////////////////////////////////////////////////////////创建修改面板////////////////////////////////////////////////////////////
		
		public function createAddItemInfoChange():void
		{
			var bg:Shape = new Shape();
			bg.graphics.beginFill(0x0,0.5);
			bg.graphics.drawRect(0,0,400,500);
			bg.graphics.endFill();
			addItemInfoChange.addChild(bg); 
			addItemInfoChange.tag = new Object;
			var title:Label = new Label("详情信息");
			title.size = 25;
			title.setSize(400,50);
			title.align = "left";
			title.color = 0xFFFFFF;
			addItemInfoChange.addChild(title);
			title.x = (bg.width-title.width)/2;
			title.y = 40;
			addItemInfoChange.tag.productNameText = createAddItemInfoTitle(addItemInfoChange,"物品名称:",100);
			addItemInfoChange.tag.productSpecText = createAddItemInfoTitle(addItemInfoChange,"规格:",150);
			addItemInfoChange.tag.productNumText = createAddItemInfoTitle(addItemInfoChange,"数量:",200);
			addItemInfoChange.tag.productUnitText = createAddItemInfoTitle(addItemInfoChange,"单位:",250);
			addItemInfoChange.tag.productPriceText = createAddItemInfoTitle(addItemInfoChange,"单价:",300);
			addItemInfoChange.tag.productTotalPricesText = createAddItemInfoTitle(addItemInfoChange,"总价:",350,"label");
			
			(addItemInfoChange.tag.productPriceText as TextInput).addEventListener(Event.CHANGE,calculationItemInfoTotalPricesChangePanel);
			(addItemInfoChange.tag.productPriceText as TextInput).restrict = "0-9";
			(addItemInfoChange.tag.productNumText as TextInput).addEventListener(Event.CHANGE,calculationItemInfoTotalPricesChangePanel);
			(addItemInfoChange.tag.productNumText as TextInput).restrict = "0-9";
			
			
			var closeBtn:Button = new Button();
			closeBtn.setSize( 60,30);
			closeBtn.label = "取消";
			addItemInfoChange.addChild(closeBtn);
			closeBtn.showBorder(0xFFFFFF);
			
			var okBtn:Button = new Button();
			okBtn.setSize( 60,30);
			okBtn.label = "确定";
			
			addItemInfoChange.addChild(okBtn);
			okBtn.showBorder(0xFFFFFF);
			okBtn.x = 50;
			closeBtn.x = 270;
			closeBtn.labelSize = okBtn.labelSize = 18;
			closeBtn.labelColors = okBtn.labelColors = "0xFFFFFF,0xFFFFFF,0xFFFFFF";
			closeBtn.clickHandler = new Handler(addItemInfoCloseClick,[addItemInfoChange]);
			okBtn.clickHandler = new Handler(addItemInfoChangeOkClick);
			okBtn.y = closeBtn.y = 440;
			okBtn.buttonMode = closeBtn.buttonMode = true;
			addItemInfoChange.x = (stageWidth-addItemInfoChange.width)>>1;
			addItemInfoChange.y = (stageHeight-addItemInfoChange.height)>>1;
			
			var changeBtn:Button = new Button(null,"修改");
			changeBtn.setSize(50,20);
			changeBtn.showBorder(0xFFFFFF);
			changeBtn.labelColors = "0xFFFFFF,0xFFFFFF,0xFFFFFF";
			changeBtn.buttonMode = true;
			changeBtn.x = 400-50-20;
			changeBtn.y = title.y+5;
			addItemInfoChange.addChild(changeBtn);
			var maskPanel:Sprite = new Sprite;
			maskPanel.graphics.beginFill(0x0,0);
			maskPanel.graphics.drawRect(0,100,400,340);
			addItemInfoChange.addChild(maskPanel);
			
			changeBtn.clickHandler = new Handler(changeBtnClick);
			addItemInfoChange.tag.changeBtn = changeBtn;
			addItemInfoChange.tag.maskPanel = maskPanel;
		}
		/**
		 *修改按钮点击事件 
		 * 
		 */		
		private function changeBtnClick():void
		{
			var btn:Button = addItemInfoChange.tag.changeBtn;
			var bg:Sprite = addItemInfoChange.tag.maskPanel;
			
			if(bg.visible)
			{
				btn.labelColors = "0x333333,0x333333,0x333333";
				btn.showBorder(0x333333);
			}else
			{
				btn.labelColors = "0xFFFFFF,0xFFFFFF,0xFFFFFF";
				btn.showBorder(0xFFFFFF);
			}
			bg.visible = !bg.visible;
		}
		/**
		 * 改变选中信息
		 * @param product
		 * 
		 */		
		public function showChangeMenu():void
		{
			if(currentIndex==-1||!addItemList.dataSource)return;
			var tag:Object = addItemInfoChange.tag;
			var obj:Object = addItemList.dataSource[currentIndex];
			tag.productNameText.text = obj.name;
			tag.productSpecText.text = obj.specifications;
			tag.productNumText.text = obj.memo;
			
			tag.productPriceText.text = obj.price+" 元";
			tag.productUnitText.text = obj.unit;
//			tag.productTotalPricesText.text = obj.totalPrice+" 元";
			tag.changeBtn.labelColors = "0xFFFFFF,0xFFFFFF,0xFFFFFF";
			tag.changeBtn.showBorder(0xFFFFFF);
			tag.maskPanel.visible = true;
//			addItemList.refresh();
		}
		
		/**
		 *点击添加按钮 
		 */		
		private function addRenderItemClick():void
		{
			addItemMenu.alpha = 0;
			addChild(addItemInfo);		
		}
		/**
		 *添加面板 确认添加选项
		 * 
		 */		
		private function addItemInfoOkClick():void
		{
			addToAddItemList();
			addItemInfoCloseClick(addItemInfo);
			addItemMenu.alpha = 1;
			addItemList.scrollBar.value = 1;
			
			if(addItemList.length==0)
			{
				showNoDataHint();
			}else
			{
				hideNoDataHint();
			}
		}
		
		/**
		 *添加面板取消 
		 * 
		 */		
		private function addItemInfoCloseClick(itemObj:Box):void
		{
			removeChild(itemObj);
			addItemMenu.alpha = 1;
		}
		
		/**
		 *修改面板确认 
		 * 
		 */		
		private function addItemInfoChangeOkClick():void
		{
			changeToAddItemList();
			addItemInfoCloseClick(addItemInfoChange);
			addItemMenu.alpha = 1;
			
			
		}
		
		/**
		 *改变list render 内容
		 * 
		 */		
		private function changeToAddItemList():void
		{
			
			
			var obj:Object=addItemList.dataSource[currentIndex];
			var tag:Object = addItemInfoChange.tag;
			
			var name:String = tag.productNameText.text;
			var specifications:String = tag.productSpecText.text;
			var memo:String = tag.productNumText.text;
			
			var str:String = tag.productPriceText.text;
			var index:int =str.indexOf(" ");
			var price:String = index>0?str.slice(0,index):str;
			
			var totalPrice:String = tag.productTotalPricesText.text;
			
			obj.name = name;
			obj.specifications = specifications;
			obj.memo = memo; 
			
			
			obj.price = price;
//			obj.totalPrice = totalPrice;
			addItemList.refresh();
		}
		/**
		 *菜单关闭 
		 * 
		 */		
		private function addItemMenuClose():void
		{
			hideAddItemMenu();	
		}		
		
		
		public var currentIndex:int= -1;
		private function renderHandler(item:Box,index:int):void
		{
			var btn:Button = item.getChildByName("removeBtn") as Button;
			var label1:Label =  item.getChildByName("name") as Label;
			var label2:Label =  item.getChildByName("specifications") as Label;
			var label3:Label =  item.getChildByName("memo") as Label;
			var label4:Label =  item.getChildByName("price") as Label;
			var label5:Label =  item.getChildByName("totalPrice") as Label;
			var icon:Image = item.getChildByName("icon") as Image;
			
			if(item.dataSource)
			{
				label1.text = item.dataSource.name;
				label2.text = item.dataSource.specifications;
				label3.text = item.dataSource.memo+" "+item.dataSource.unit;
				label4.text = item.dataSource.price + " (元) ";
				label5.text = isNaN(parseInt(item.dataSource.price)*parseInt(item.dataSource.memo))?"0 (元)":(parseInt(item.dataSource.price)*parseInt(item.dataSource.memo))+" (元) ";
				icon.url = item.dataSource.image3dURL; 
			}
			
//				label1.text =(addItemList.array[0].price)// item.dataSource[index].name;// addItemList.array[index].name;
			
			if(!btn.clickHandler)
			{
				//btn.clickHandler = new Handler(onListRemoveClick,[item,index]);
				btn.addEventListener(MouseEvent.CLICK,onListRemoveClick);
				
				btn.buttonMode = true;
			}
			
		}
		/**
		 *增项List 选择 
		 * @param index
		 * 
		 */	
		private var stopPropagation:Boolean =false
		private function addItemListSelect(index:int):void
		{
			if(stopPropagation)return ;
			addItemList.selectedIndex = -1;
			addChild(addItemInfoChange);
			addItemMenu.alpha = 0;
			currentIndex = index;
			showChangeMenu();
		}	
		
		public var currentItem:Box;
		protected function onListRemoveClick(e:MouseEvent):void
		{
			
			stopPropagation = true;
			addItemMenu.alpha = 0.3;
			currentItem = e.currentTarget.parent;
			addItemList.selection=e.currentTarget.parent;
			currentIndex = addItemList.selectedIndex;
			addItemRemoveHint("您确定要删除本条增项吗？",removeAddItmeOk,removeAddItemCancel);
		}
		/**
		 *删除确认 
		 * @param e
		 * 
		 */		
		private function removeAddItmeOk(e:MouseEvent):void
		{
			
//			addItemList.deleteItem(currentIndex);
			addItemList.sendEvent(ADDITEM_REMOVE,addItemList.dataSource[currentIndex]);
			addItemList.selectedIndex = -1;
			removeAddItemCancel(e);
			addItemMenu.alpha = 1;
			stopPropagation = false;
			
			if(addItemList.length==0)
			{
				showNoDataHint();
			}else
			{
				hideNoDataHint();
			}
		}
		/**
		 *删除取消 
		 * @param e
		 * 
		 */		
		private function removeAddItemCancel(e:MouseEvent):void
		{
			var hint:Sprite = getChildByName("roemveHint") as Sprite;
			hint.removeChildren();
			removeChild(hint);
			addItemMenu.alpha = 1;
			stopPropagation = false;
		}
		/**
		 *更新数据 
		 * @param datas [name->物品名称，specifications->规格 ,memo->数量, price->单价 totalPrice->总价]
		 * 
		 */			
		public function update(datas:Array):void
		{
			if(datas.length>0)
			{
				hideNoDataHint();
			}else
			{
				showNoDataHint();
			}
			addItemList.dataSource = datas;
		}
		/**
		 *添加一个到顶层 
		 * @param obj
		 * [productIDText,productNameText,productSpecText,productNumText,productUnitText,productPriceText,productTotalPricesText]
		 */		
		public function addToAddItemList():void
		{
			var tag:Object = addItemInfo.tag;
			var obj:Object=new Object;
			obj.productCode = tag.productIDText.text;
			obj.name = tag.productNameText.text;
			obj.specifications = tag.productSpecText.text;
			obj.memo = tag.productNumText.text;
			obj.unit = tag.productUnitText.text;
			obj.productModel = tag.productModelText.text;
			
			var str:String = tag.productPriceText.text;
			var index:int =str.indexOf(" ");
			var price:String = index>0?str.slice(0,index):str;
			obj.price = price;
			obj.totalPrice = tag.productTotalPricesText.text;
			addItemList.sendEvent(ADDITEM_ADD,obj);
			
			
		}
		/**
		 *搜索 
		 * 
		 */		
		private function searchFun():void
		{
			// TODO Auto Generated method stub
			var ID:String = addItemInfo.tag.productIDText.text;
			sendEvent(ADDITEM_SEARCH,ID);
		}
	}
}