package rightaway3d.house.editor2d
{
	import flash.events.Event;
	
	import rightaway3d.engine.core.EngineManager;
	import rightaway3d.engine.model.ModelType;
	import rightaway3d.engine.product.ProductInfo;
	import rightaway3d.engine.product.ProductManager;
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.engine.product.ProductObjectName;
	import rightaway3d.house.cabinet.CabinetType;

	public class AddItemManager
	{
		private var productManager:ProductManager;
		
		public function AddItemManager()
		{
			productManager = ProductManager.own;
		}
		
		public function addItem(item:Object):void
		{
			var rpo:ProductObject = productManager.getProductByName(ProductObjectName.ROOT_INCREASE_PRODUCT);
			if(!rpo)
			{
				rpo = productManager.createCustomizeProduct(ModelType.BOX_C,ProductObjectName.ROOT_INCREASE_PRODUCT,"",1,1,1,0,false);
				//rpo.createContainer3D();
				rpo.container3d.visible = false;
				//trace("rpo.name:",rpo.name);
				productManager.setProductObject(rpo);
				//EngineManager.instance.addRootChild(rpo.container3d);
			}
			
			var infoID:int = item.infoID;
			var name:String = item.name;//产品名称
			
			if(infoID>0)
			{
				var info:ProductInfo = productManager.getInfo(infoID);
				var spo:ProductObject = productManager.createProductObject(info,0,name,"",false);
			}
			else
			{
				spo = productManager.createCustomizeProduct(ModelType.BOX_C,name,"",1,1,1,0,false);//创建增项产品信息的容器
				//spo.createContainer3D();
				spo.container3d.visible = false;
				//info = spo.productInfo;
			}
			productManager.addDynamicSubProduct(rpo,spo);
			
			spo.specifications = item.specifications;//产品规格
			spo.productModel = item.productModel;//产品型号
			spo.productCode = item.productCode?item.productCode:"000000000";//物料编码
			spo.price = item.price;//单价
			spo.unit = item.unit;//单位
			spo.memo = item.memo;//数量
			spo.image3dURL = "assets/icon/increase_product.jpg";
			
			spo.type = CabinetType.INCREASE_PRODUCT;
		}
		
		public function removeItem(po:ProductObject):void
		{
			po.dispose();
		}
		
		public function getItems():Array
		{
			var a:Array = [];
			var rpo:ProductObject = productManager.getProductByName(ProductObjectName.ROOT_INCREASE_PRODUCT);
			
			//trace("rpo:",rpo,rpo.dynamicSubProductObjects);
			if(!rpo || !rpo.dynamicSubProductObjects)return a;
			
			for each(var po:ProductObject in rpo.dynamicSubProductObjects)
			{
				a.push(po);
			}
			return a;
		}
		
		private var setProductInfoCallback:Function;
		
		public function getProductInfo(infoID:int,fileURL:String,setProductInfoFun:Function):void
		{
			var info:ProductInfo = productManager.createProductInfo(infoID,fileURL,"text");
			if(info.isReady)
			{
				setProductInfoFun(info);
			}
			else
			{
				setProductInfoCallback = setProductInfoFun;
				info.addEventListener("ready",onInfoReady);
				productManager.loadProduct();
			}
		}
		
		protected function onInfoReady(e:Event):void
		{
			var info:ProductInfo = e.currentTarget as ProductInfo;
			info.removeEventListener("ready",onInfoReady);
			
			setProductInfoCallback(info);
		}
	}
}































