package game.ui.mike
{
	import flash.display.Shape;
	import flash.events.Event;
	
	import game.ui.AddItemRenderVO;
	
	import morn.core.components.Box;
	import morn.core.components.Button;
	import morn.core.components.Label;
	import morn.core.components.List;
	import morn.core.handlers.Handler;
	
	import rightaway3d.house.editor2d.CabinetCreator;
	import rightaway3d.house.lib.CabinetLib;
	
	/**
	 *产品编码选择更多弹窗UI 
	 * @author Heter
	 * 
	 */	
	public class AddItemIDMoreMenuUI extends Box
	{
		
		private var addProducts:Vector.<AddItemRenderVO>;
		public var product:AddItemRenderVO;
		public var productTypes:Array;
		public var productType:String;
		public static var UPDATE_ADDITEM:String = "update_additem";
		public static var CLOSE_ADDITEM:String = "close_additem";
		public var listIDDatas:Array;
		public var listTypeDatas:Array;
		public var list:List;
		public var state:String = "ID";//Type/Type_change
		public var bg:Shape;
		
		public var title:Label ;
		
		public function AddItemIDMoreMenuUI()
		{
			super();
		}
		
		private function initIDDatas():void
		{
			
			var xmlList:XMLList = CabinetLib.lib.getAddProducts();
			var len:uint = xmlList.length();
			addProducts = new Vector.<AddItemRenderVO>(len);
			listIDDatas = new Array;
			for (var i:int = 0; i < len; i++) 
			{
				var vo:AddItemRenderVO = new AddItemRenderVO;
				vo.productName = xmlList[i].name;
				vo.productSpec = xmlList[i].spec;
				vo.productID = xmlList[i].id;
				vo.productType = xmlList[i].type;
				vo.productUnit = xmlList[i].unit;
				vo.productPrice = xmlList[i].price;
				var obj:Object = {label:vo.productName};
				listIDDatas.push(obj);
				addProducts[i] = vo;
			}
			list.dataSource = listIDDatas;
			
		}
		
		private function initTypeDatas():void
		{
			listTypeDatas = [{label:"柜体"},{label:"门板(吊柜)"},{label:"台面"}];	
			list.dataSource = listTypeDatas;
		}
		public function initData():void
		{
			if(!list) 
			{
				init()
			}else
			{
				list.selectedIndex =-1;
			}
			
			if(state=="ID")
			{
				if(listIDDatas)
				{
					list.dataSource = listIDDatas;
				}else
				{
					initIDDatas();
				}
				
				title.text = "选择产品";
				bg.height = 300;
				
			}else
			{
				if(listTypeDatas)
				{
					list.dataSource = listTypeDatas;
				}else
				{
					initTypeDatas();
				}
				title.text = "选择类型";
				bg.height = 200;
			}
			
			
		}
		
		public function init():void
		{
			bg = new Shape();
			bg.graphics.beginFill(0x0,0.5);
			bg.graphics.drawRect(0,0,400,300);
			bg.graphics.endFill();
			this.addChild(bg); 
			//font="造字工房悦黑(非商用)细体" embedFonts="true"
			title = new Label("产品选择");
			title.size = 20;
			title.font = MainUI.FontName;
			title.embedFonts = true;
			title.setSize(400,50);
			title.align = "center";
			title.color = 0xFFFFFF;
			this.addChild(title);
			title.x = 0;
			title.y = 15;	
			
			
			//			var cancel:Button = new Button();
			//			cancel.setSize( 60,30);
			//			cancel.label = "取消";
			//			cancel.btnLabel.font = MainUI.FontName;
			//			cancel.btnLabel.embedFonts = true;
			//			this.addChild(cancel);
			//			cancel.showBorder(0xFFFFFF);
			//			
			//			var okBtn:Button = new Button();
			//			okBtn.setSize( 60,30);
			//			okBtn.label = "确定";
			//			okBtn.btnLabel.font = MainUI.FontName;
			//			okBtn.btnLabel.embedFonts = true;
			//			this.addChild(okBtn);
			//			okBtn.showBorder(0xFFFFFF);
			//			okBtn.x = 80;
			//			cancel.x = 260;
			//			cancel.labelSize = okBtn.labelSize = 18;
			//			cancel.labelColors = okBtn.labelColors = "0xFFFFFF,0xFFFFFF,0xFFFFFF";
			//			cancel.clickHandler = new Handler(optionsCloseClick);
			//			okBtn.clickHandler = new Handler(optionsOkClick);
			//			okBtn.y = cancel.y = 250;
			//			okBtn.buttonMode = cancel.buttonMode = true;
			
			//关闭按钮
			var closeBtn:Button = new Button("png.comp.icon_close_large");
			closeBtn.setSize(25,20);
			closeBtn.x = 400-30;
			closeBtn.y = 5;
			this.addChild(closeBtn);
			closeBtn.clickHandler = new Handler(optionsCloseClick);
			closeBtn.stateNum = 1;
			closeBtn.buttonMode = true;
			
			
			
			
			
			list = new List();
			list.width = 370;
			list.height = 210;
			list.y = 60;
			list.x = 15;
			list.repeatX = 1;
			addChild(list);
			list.vScrollBarSkin = "png.comp.vscroll";
			list.renderHandler = new  Handler(listRender);
			list.spaceY = 5;
			list.itemRender = AddItemIDMoreListRender;
			list.dataSource = [{label:"请稍等..."},{label:"请稍等..."},{label:"请稍等..."},{label:"请稍等..."},{label:"请稍等..."},{label:"请稍等..."},{label:"请稍等..."},{label:"请稍等..."}]
			list.scrollBar.showButtons = false;
			list.scrollBar.right = -15;
			list.selectHandler = new Handler(listSelectFun);
		}
		private var currentIndex:uint = 0;
		private function listSelectFun(index:int):void
		{
			// TODO Auto Generated method stub
			if(index==-1) return ;
			currentIndex = index;
			optionsOkClick(index);
		}		
		
		
		private function listRender(item:AddItemIDMoreListRender,index:uint):void
		{
			if(item.dataSource)
			{
				item.label.text = item.dataSource.label;
			}	
		}
		
		private function optionsOkClick(index:int=0):void
		{
			if(state=="ID")
			{
				product = addProducts[currentIndex];
			}else
			{
				switch(index)
				{
					case 0:
					{
						productType = CabinetCreator.getInstance().cabinetBodyDefaultMaterial;
						break;
					}
					case 1:
					{
						productType = CabinetCreator.getInstance().wallCabinetDoorMaterial;
						break;
					}
					case 2:
					{
						productType = CabinetCreator.getInstance().cabinetTableDefaultMaterial;
						break;
					}
						
				}
				
			}
			
			dispatchEvent(new Event(UPDATE_ADDITEM));
			optionsCloseClick();
		}
		
		private function optionsCloseClick():void
		{
			if(this.parent)
			{
				parent.removeChild(this);
				dispatchEvent(new Event(CLOSE_ADDITEM));
			}
		}
		
	}
}