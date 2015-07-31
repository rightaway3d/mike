package rightaway3d.house.editor2d
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import rightaway3d.engine.product.ProductInfo;
	import rightaway3d.engine.product.ProductManager;
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.engine.product.ProductObjectName;
	import rightaway3d.engine.utils.GlobalEvent;
	import rightaway3d.engine.utils.Tips;
	import rightaway3d.house.cabinet.CabinetType;
	import rightaway3d.house.cabinet.ListType;
	import rightaway3d.house.lib.CabinetLib;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.WallObject;

	[SWF(backgroundColor="#E2E2E2", frameRate="30", width="1600", height="800")]
	public class Mike extends Editor2D
	{
		private var productManager:ProductManager = ProductManager.own;
		
		private var ui:MikeUI;
		
		private var subElecData:XML;//子产品电器数据源
		
		private const BTN_DELET_PRODUCT:String = "删除厨柜";
		private const BTN_CLEAR_PRODUCT:String = "清除厨柜";
		private const BTN_CLEAR_PLANK:String = "清除封板";
		private const BTN_CABINET_DOOR:String = "更新门板";
		private const BTN_UPDATE_TABLE:String = "更新台面";
		private const BTN_SWITCH_TABLE:String = "显示/ 隐藏 台面";
		private const BTN_ADD_ITEM:String = "增项";
		
		private const BTN_LEFT_DOOR:String = "设为左开门";
		private const BTN_RIGHT_DOOR:String = "设为右开门";
		
		public function Mike()
		{
			super();
			
			if(stage)init();
			else
				this.addEventListener(Event.ADDED_TO_STAGE,init);
		}
		
		private function init(e:Event=null):void
		{
			if(e)this.removeEventListener(Event.ADDED_TO_STAGE,init);
//			graphics.beginFill(0xFFFF00);
//			graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight)
			ui = new MikeUI();
			trace("--------initMikeUI parent:",this.parent);
			this.parent.addChild(ui);
			//if(!stage)
				ui.visible = false;
			
			ui.listSelectHandler = onSelectItem;
			ui.mainBtnPressed = onMainBtnSwitch;
			//ui.deleteBtnClick = onDeleteProduct;
			//ui.createBtnClick = createTable;
			ui.bottomBtnsHandler = onBottomClick;
			ui.bbtns = [BTN_DELET_PRODUCT,BTN_CLEAR_PRODUCT,BTN_CLEAR_PLANK,BTN_CABINET_DOOR,BTN_UPDATE_TABLE,BTN_SWITCH_TABLE,BTN_LEFT_DOOR,BTN_RIGHT_DOOR,BTN_ADD_ITEM];
			
			subElecData =
				<item>
					<infoID></infoID>
					<objectID>0</objectID>
					<name></name>
					<name_en/>
					<file></file>
					<dataFormat>text</dataFormat>
					<position>300,18,551</position>
					<rotation>0,0,0</rotation>
					<scale>1,1,1</scale>
					<active>true</active>
				</item>;
			
			GlobalEvent.event.addEventListener("product_created",onProductCreated);
		}
		
		private function onBottomClick(lable:String):void
		{
			trace("label:",lable);
			switch(lable)
			{
				case BTN_DELET_PRODUCT:
					this.deleteSelectProduct();
					break;
				case BTN_CLEAR_PRODUCT:
					//this.deleteAllProduct();
					this.clearAllCabinetObject();
					break;
				case BTN_UPDATE_TABLE:
					updateTable();
					break;
				case BTN_CABINET_DOOR:
					updateCabinetDoor();
					break;
				case BTN_CLEAR_PLANK:
					cabinetCreator.claerAllPlate();
					break;
				case BTN_SWITCH_TABLE:
					cabinetCreator.switchCabinetTableVisible();
					break;
				case BTN_LEFT_DOOR:
					resetDoorDirection("left");
					break;
				case BTN_RIGHT_DOOR:
					resetDoorDirection("right");
					break;
				case BTN_ADD_ITEM:
					showAddPeoductItemMenu();
					break;
			}
		}
		
		
		private function showAddPeoductItemMenu():void
		{
			ui.showAddItemMenu();
		}
		private function resetDoorDirection(direction:String):void
		{
			if(gv.currProduct)
			{
				var po:ProductObject = gv.currProduct;
				if(po.name!=ProductObjectName.CORNER_CABINET)
				{
					cabinetCreator.clearSingleDoor(po);
					cabinetCreator.addSingleDoor(po,direction);
				}
			}
		}
		
		private function updateCabinetDoor():void
		{
			cabinetCreator.clearAllSingleDoor();
			TableBuilder.own.builderDoor();
		}
		
		private function updateTable():void
		{
			cabinetCreator.clearCabinetTalbes();
			var msg:String = TableBuilder.own.builderTable();
			//trace(stage.mouseX);
			if(msg)
			{
				Tips.show(msg,stage.mouseX-100,stage.mouseY-70,3000);
			}
			else
			{
				updateCabinetDoor();
			}
		}
		
		private function onMainBtnSwitch(uiVisible:Boolean):void
		{
			trace("uiVisible:"+uiVisible);
			this.lockCabinetObject(uiVisible);
			this.scene3d.house3d.updateWallMark(!uiVisible);
		}
		
		override public function switchView():Boolean
		{
			var result:Boolean = super.switchView();
			ui.visible = !result;
			
			return result;
		}
		
			/*<item>
			  <name>900对开地柜</name>
			  <cate>general</cate>
			  <spce>W900*D550*H720</spce>
			  <dscp/>
			  <price>388</price>
			  <image>assets/icon/cabinet/A90.jpg</image>
			  <id>507</id>
			  <file>cabinet_507_900x720x570.pdt</file>
			  <width>900</width>
			  <height>720</height>
			  <depth>550</depth>
			  <type>ground_cabinet</type>
			</item>*/
		//水盆、灶台及烟机每个有且只有一个，烤箱与消毒柜每个最多只能有一个
		//1，水盆必须依附于水盆柜存在，拖入任一水盆柜时，会创建默认水盆，如果已经存在水盆柜，要先手工删除，才可拖入新水盆柜，删除水盆柜时，水盆也将被删除，
		//无水盆柜时，不允许拖入水盆，存在水盆柜时，拖入水盆将替换当前水盆，移动水盆柜时，水盆将自动跟随，不允许单独移动或删除水盆
		//2，灶台及烟机同时依附于灶台柜存在，规则与水盆相同
		//3，烤箱与消毒柜必须依附于电器柜存在，拖入电器柜时，自动创建指定类型电器，如果该类型电器已经存在，要先手工删除，才可以拖入新电器柜
		//
		private function onSelectItem(item:XML):void
		{
			//trace(item);
			
			var type:String = item.type;
			var cate:String = item.cate;
			var id:int = item.id;
			var file:String = item.file;
			var name:String = item.name;
			var width:int = item.width;
			var height:int = item.height;
			var depth:int = item.depth;
			
			var p:ProductObject;
			
			if(type==ListType.GROUND_CABINET)//"ground_cabinet")//地柜
			{
				//trace(type,cate,name);return;
				switch(cate)
				{
					case ListType.DRAINER://"drainer"://水盆地柜
						var pname:String = ProductObjectName.DRAINER_CABINET;
						var drainerCabinet:ProductObject = getProduct(pname);
						
						if(drainerCabinet)
						{
							Tips.show("水槽柜已经存在\n先删除再重新创建",stage.mouseX-100,stage.mouseY-70,3000,14);
							return;
						}
						
						p = drainerCabinet = this.createCabinet(id,file,CrossWall.IGNORE_OBJECT_HEIGHT,pname,width,height,depth);
						break;
					
					case ListType.FLUE://灶台地柜
						pname = ProductObjectName.FLUE_CABINET;
						var flueCabinet:ProductObject = getProduct(pname);
						
						if(flueCabinet)
						{
							Tips.show("灶台柜已经存在\n先删除再重新创建",stage.mouseX-100,stage.mouseY-70,3000,14);
							return;
						}
						
						var subItem:String = item.sub_item;
						if(subItem)
						{
							p = createElecCabinet(subItem,id,file,width,height,depth,pname);//以电器柜作灶台柜
							if(!p)return;//如果产品未创建则返回
						}
						else
						{
							p = flueCabinet = this.createCabinet(id,file,CrossWall.IGNORE_OBJECT_HEIGHT,pname,width,height,depth);
						}
						break;
					
					case ListType.ELEC://"elec"://电器地柜
					case ListType.MIDDLE_ELEC://"middle_elec"://电器中高柜
					case ListType.HEIGHT_ELEC://"height_elec"://电器高柜
						subItem = item.sub_item;
						p = createElecCabinet(subItem,id,file,width,height,depth);
						if(!p)return;//如果产品未创建则返回
						break;
					
					case ListType.CORNER://拐角柜
					case ListType.CORNER_Z://窄拐角柜
						p = this.createCabinet(id,file,CrossWall.IGNORE_OBJECT_HEIGHT,ProductObjectName.CORNER_CABINET,width,height,depth);
						break;
					
					default:
						p = this.createCabinet(id,file,CrossWall.IGNORE_OBJECT_HEIGHT,name,width,height,depth);
						break;
				}
				
				cabinetCreator.addGroundCabinet(p);
				//setProductEvent(p);
			}
			else if(type==ListType.WALL_CABINET)//"wall_cabinet")//吊柜
			{
				//trace(type);
				pname = cate==ListType.CORNER ? ProductObjectName.CORNER_CABINET : name;
				p = this.createCabinet(id,file,CrossWall.WALL_OBJECT_HEIGHT,pname,width,height,depth);
				
				cabinetCreator.addWallCabinet(p);
				//setProductEvent(p);
			}
			else if(type==ListType.DRAINER)//"drainer")//水盆
			{
				drainerCabinet = getProduct(ProductObjectName.DRAINER_CABINET);
				if(!drainerCabinet)
				{
					Tips.show("请先放置水槽柜",stage.mouseX-50,stage.mouseY-50,3000,14);
					return;
				}
				
				pname = ProductObjectName.DRAINER;
				var drainer:ProductObject = getProduct(pname);
				if(drainer)
				{
					//productManager.replaceSubProductObject(drainer.modelObject,id,file,pname);
					po = productManager.replaceProductObject(drainer,id,file,pname,width,depth,height);
					if(po)
					{
						//this.cabinetCtr.addCabinetDict(po);
						this.cabinetCreator.addCabinet(po);
						cabinetCreator.setCookerProduct(drainerCabinet.objectInfo.crossWall,drainerCabinet,po,false);//更新水盆位置信息
						this.cabinetCreator.updateCabinetTable();
					}
				}
				else
				{
					//drainer = this.createCabinet(id,file,CrossWall.GROUND_OBJECT_HEIGHT,pname,width,depth);
					Tips.show("场景中找不到水槽，请检查是否被单独删除了",stage.mouseX-50,stage.mouseY-50,3000,14);
				}
			}
			else if(type==ListType.FLUE || type==ListType.HOOD)//"flue")//灶台或烟机
			{
				flueCabinet = getProduct(ProductObjectName.FLUE_CABINET);
				if(!flueCabinet)
				{
					Tips.show("请先放置灶台柜",stage.mouseX-50,stage.mouseY-50,3000,14);
					return;
				}
				
				if(type==ListType.FLUE)
				{
					pname = ProductObjectName.FLUE;
					var pname_cn:String = "灶台";
				}
				else
				{
					pname = ProductObjectName.HOOD;
					pname_cn = "烟机";
				}
				
				po = getProduct(pname);
				if(po)
				{
					//productManager.replaceSubProductObject(drainer.modelObject,id,file,pname);
					po = productManager.replaceProductObject(po,id,file,pname,width,depth,height);
					//this.cabinetCtr.addCabinetDict(po);
					this.cabinetCreator.addCabinet(po);
				}
				else
				{
					//drainer = this.createCabinet(id,file,CrossWall.GROUND_OBJECT_HEIGHT,pname,width,depth);
					Tips.show("场景中找不到"+pname_cn+"，请检查是否被单独删除了",stage.mouseX-50,stage.mouseY-50,3000,14);
				}
			}
			else if(type==ListType.OVEN)//"oven")//烤箱
			{
				pname = ProductObjectName.OVEN;
				var oven:ProductObject = getProduct(pname);
				if(!oven)//不能直接放置烤箱，必须要先放配烤箱电器柜
				{
					//oven = this.createCabinet(id,file,CrossWall.WALL_OBJECT_HEIGHT,pname,width,depth);
					Tips.show("请先放置配烤箱电器柜",stage.mouseX-50,stage.mouseY-50,3000,14);
					return;
				}
				
				productManager.replaceSubProductObject(oven.modelObject,id,file,pname);
			}
			else if(type==ListType.STERILIZER)//"sterilizer")//消毒柜
			{
				pname = ProductObjectName.STERILIZER;
				var sterilizer:ProductObject = getProduct(pname);
				if(!sterilizer)//不能直接放置消毒柜，必须要先放配消毒柜电器柜
				{
					//sterilizer = this.createCabinet(id,file,CrossWall.WALL_OBJECT_HEIGHT,pname,width,depth);
					Tips.show("请先放置配消毒柜电器柜",stage.mouseX-50,stage.mouseY-50,3000,14);
					return;
				}
				
				productManager.replaceSubProductObject(sterilizer.modelObject,id,file,pname);
			}
			else if(type==ListType.HANDLE)//"handle")//拉手
			{
				var ps:Array = ProductManager.own.getProductsByType(CabinetType.HANDLE);
				for each(var info:ProductInfo in ps)
				{
					var pos:Array = info.getProductObjects();
					for each(var po:ProductObject in pos)
					{
						this.replaceProductObject(po.modelObject,[item]);
						return;//只运行一次
					}
				}
			}
			else
			{
				/*trace("DRAINER:",productManager.getProductByName(ProductObjectName.DRAINER));
				trace("FLUE:",productManager.getProductByName(ProductObjectName.FLUE));
				trace("HOOD:",productManager.getProductByName(ProductObjectName.HOOD));
				trace("OVEN:",productManager.getProductByName(ProductObjectName.OVEN));
				trace("STERILIZER:",productManager.getProductByName(ProductObjectName.STERILIZER));
				trace("DRAINER_CABINET:",productManager.getProductByName(ProductObjectName.DRAINER_CABINET));*/
			}
			
			if(p)
			{
				this.hideUI();
				flash.utils.setTimeout(updateProduct,10,p);
			}
		}
		
		private function updateProduct(p:ProductObject):void
		{
			this.cabinetCtr.setProductPos(p,null,house.x,p.objectInfo.y,house.z);
		}
		
		//创建电器柜
		private function createElecCabinet(subItem:String,id:int,file:String,width:Number,height:Number,depth:Number,pname:String=""):ProductObject
		{
			var sub:XML = getSubItem(subItem);
			var subName:String = sub.name;
			var elec:ProductObject = getProduct(subName);//检查场景中是否存在同类电器，如存在将不能继续创建电器柜
			
			if(elec)
			{
				var elecName:String = subName==ProductObjectName.OVEN?"烤箱":"消毒柜";
				Tips.show("场景中已经存在【"+elecName+"】\n先删除再重新创建",stage.mouseX-100,stage.mouseY-70,3000,14);
				return null;
			}
			
			var p:ProductObject = this.createCabinet(id,file,CrossWall.IGNORE_OBJECT_HEIGHT,pname,width,height,depth);
			addSubItem(p,sub);
			
			return p;
		}
		
		//添加电器柜时，获取要添加的电器数据信息
		private function getSubItem(sub_item:String):XML
		{
			var a:Array = sub_item.split("|");
			var id:String = a[0];
			var pos:String = a[1];
			var data:XML = CabinetLib.lib.getCabinetData(id);
			
			var type:String = data.type;
			var elecName:String = type=="oven"?ProductObjectName.OVEN:ProductObjectName.STERILIZER;
			var elecFile:String = data.file;
			
			subElecData.infoID = id;
			subElecData.name = elecName;
			subElecData.file = elecFile;
			subElecData.position = pos;
			
			return subElecData;
		}
		
		//为指定产品添加子产品
		private function addSubItem(parent:ProductObject,subData:XML):void
		{
			var subpo:ProductObject = productManager.addDynamicSubProduct(parent,subData);
		}
		
		//获取指定名称的产品实例
		private function getProduct(name:String):ProductObject
		{
			return productManager.getProductByName(name);
		}
		
		//设置产品实例事件
		private function onProductCreated(e:Event):void
		{
			var po:ProductObject = GlobalEvent.event.currentTarget;
			
			po.addEventListener("draging",onDragingProduct);
			po.addEventListener("end_drag",onEndDragProduct);
			po.addEventListener("will_dispose",onDispose);
		}
		
		//拖动产品处理事件
		private function onDragingProduct(e:Event):void
		{
			//hideUI();
			ui.visible = false;
		}
		
		//结束拖动产品处理事件
		private function onEndDragProduct(e:Event):void
		{
			showUI();
			var po:ProductObject = e.currentTarget as ProductObject;
			followMoveProduct(po);
		}
		
		private function followMoveProduct(po:ProductObject):void
		{
			var name:String = po.name;
			
			switch(name)
			{
				case ProductObjectName.DRAINER_CABINET://水盆柜拖动结束后，水盆要跟随移动
					moveProduct(ProductObjectName.DRAINER,ListType.DRAINER,po);
					break;
				
				case ProductObjectName.FLUE_CABINET://灶台柜拖动结束后，灶台与烟机要跟随移动
					moveProduct(ProductObjectName.FLUE,ListType.FLUE,po);
					moveProduct(ProductObjectName.HOOD,ListType.HOOD,po,true);
					break;
			}
		}
		
		//结束拖动产品后，移动与其相关联的产品
		private function moveProduct(name:String,type:String,masterProduct:ProductObject,isHood:Boolean=false):void
		{
			var po:ProductObject = getProduct(name);
			if(!po)
			{
				po = createProductByType(name,type,masterProduct,isHood);
				//this.cabinetCtr.addCabinetDict(po);
				this.cabinetCreator.addCabinet(po);
			}
			else
			{
				var wo:WallObject = masterProduct.objectInfo;
				cabinetCreator.setCookerProduct(wo.crossWall,masterProduct,po,isHood);
				productManager.updateProductModel(po);
			}
		}
		
		private function createProductByType(name:String,type:String,masterProduct:ProductObject,isHood:Boolean=false):ProductObject
		{
			var wo:WallObject = masterProduct.objectInfo;
			var list:XMLList = CabinetLib.lib.getProductList(type,"");
			if(list.length()>0)
			{
				var xml:XML = list[0];
				var cw:CrossWall = wo.crossWall;
				var po:ProductObject = cabinetCreator.addCookerProduct(xml,cw,masterProduct,name,isHood);
				if(isHood)
				{
					//cabinetCtr.createProduct(po);
				}
				//po.isActive = false;
				po.isLock = false;
				
				return po;
			}
			return null;
		}
		
		private function hideUI():void
		{
			ui.visible = false;
		}
		
		private function showUI():void
		{
			ui.visible = true;
		}
		
		private function onDispose(e:Event):void
		{
			var po:ProductObject = e.currentTarget as ProductObject;
			po.removeEventListener("draging",onDragingProduct);
			po.removeEventListener("end_drag",onEndDragProduct);
			po.removeEventListener("will_dispose",onDispose);
		}
		
		override protected function moveCurrProduct(dx:int):void
		{
			super.moveCurrProduct(dx);
			if(gv.currProduct)
			{
				followMoveProduct(gv.currProduct);
			}
		}
		
		//private var cabinetCtr:CabinetController = CabinetController.getInstance();
		//private var cabinetCreator:CabinetCreator = CabinetCreator.getInstance();
		
		override public function deleteProduct(po:ProductObject):void
		{
			var name:String = po.name;
			switch(name)//水槽，灶台，烟机，不能单独删除
			{
				case ProductObjectName.DRAINER:
					var pname1:String = "水槽";
					var pname2:String = "水槽柜";
					break;
				case ProductObjectName.FLUE:
					pname1 = "灶台";
					pname2 = "灶台柜";
					break;
				case ProductObjectName.HOOD:
					pname1 = "烟机";
					pname2 = "灶台柜";
					break;
			}
			
			if(pname1)
			{
				Tips.show(pname1+"不能单独删除\n直接删除"+pname2+"即可",stage.mouseX-100,stage.mouseY-70,3000,14);
				return;
			}
			
			var addHistory:Boolean = true;
			switch(name)
			{
				case ProductObjectName.DRAINER_CABINET://删除水盆柜时，把水盆也删除掉
					cabinetCtr.deleteProductByName(ProductObjectName.DRAINER);
					addHistory = false;
					break;
				case ProductObjectName.FLUE_CABINET://删除灶台柜时，把灶台与烟机也删除掉
					cabinetCtr.deleteProductByName(ProductObjectName.FLUE);
					cabinetCtr.deleteProductByName(ProductObjectName.HOOD);
					addHistory = false;
					break;
			}
			
			cabinetCtr.deleteProduct(po,false,addHistory);
		}
		
		override protected function on2DSceneKeyDown(e:KeyboardEvent):void
		{
			super.on2DSceneKeyDown(e);
			
			switch(e.keyCode)
			{
				case Keyboard.G:
					updateTable();
					break;
			}
		}
	}
}

//http://gate.jd.com/InitCart.aspx?pid=1175412&pcount=1&ptype=1









