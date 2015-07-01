package rightaway3d.house.editor2d
{
	import flash.utils.Dictionary;
	
	import rightaway3d.engine.product.ProductManager;
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.engine.product.ProductObjectName;
	import rightaway3d.house.cabinet.CabinetType;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.House;
	import rightaway3d.house.vo.WallHole;
	import rightaway3d.house.vo.WallObject;
	import rightaway3d.house.vo.WallSubArea;

	public class TableBuilder
	{
		private var productManager:ProductManager;
		private var cabinetCreator:CabinetCreator;
		private var cabinetCtrl:CabinetController;
		
		public function TableBuilder()
		{
			productManager = ProductManager.own;
			cabinetCreator = CabinetCreator.getInstance();
			cabinetCtrl = CabinetController.getInstance();
		}
		
		private var groundCabinetDict:Dictionary;
		private var wallCabinetDict:Dictionary;
		
		public function builderTable():String
		{
			groundCabinetDict = new Dictionary();
			wallCabinetDict = new Dictionary();
			
			var msg:String = countCabinetWithWall();
			
			sortCabinet(groundCabinetDict);
			sortCabinet(wallCabinetDict);
			
			var groundArea:Array = sortCrossWall(groundCabinetDict);
			
			var depthss:Array = [];
			var tabless:Array = resetGroundArea(groundArea,depthss);
			cabinetCreator.createCabinetTable3(tabless,depthss);//[[600,600,600],[600,600,600],[600,600,600]]);
			
			var house:House = House.getInstance();
			house.updateBounds();
			cabinetCreator.updateTableMeshsPos(house.x,house.z);
			
			var wallArea:Array = sortCrossWall(groundCabinetDict);
			
			return msg;
		}
		
		public function builderDoor():void
		{
			var cabs:Array = productManager.getProductObjectsByType(CabinetType.BODY);
			for each(var po:ProductObject in cabs)
			{
				cabinetCreator.addSingleDoor(po);
			}			
		}
		
		public var alongWidth:int = 20;//台面两端出沿宽度
		public var maxAlongWidth:int = 100;//台面两端出沿宽度
		
		//创建台面前检查，同一面墙不出现连续门洞，同一面墙上的柜子之间不能有间隙，有障碍物（烟道、方柱）除外
		//柜子之间不能有中高柜，同一墙同一区域的柜子深度须一致，拐角柜只能出现在拐角处
		private function testCabinet():void
		{
			
		}
		
		/*厨柜分区判断
		厨柜子区域墙体数量超过一时，拐角处需放置拐角柜，如不放拐角柜，将作新增拆分子区域处理
		如果在厨柜之间有门隔开，则要增加厨柜子区域，如果门洞不在厨柜之间，则要避开门洞
		*/
		
		private function resetGroundArea(groundArea:Array,depthss:Array):Array
		{
			var tabless:Array = [];
			var areaLen:int = groundArea.length;
			var tableData:WallSubArea;
			var tables:Array;
			var depths:Array;
			
			for(var i:int=0;i<areaLen;i++)
			{
				var cws:Array = groundArea[i];
				var cwLen:int = cws.length;
				tableData = null;
				
				for(var j:int=0;j<cwLen;j++)
				{
					var cw:CrossWall = cws[j];
					var gos:Array = cw.groundObjects;
					var woLen:int = gos.length;
					
					for(var k:int=0;k<woLen;k++)
					{
						var wo:WallObject = gos[k];
						var object:* = wo.object;
						
						if(!tableData)
						{
							if(!(object is ProductObject))//避开门洞
							{
								tables = null;
								continue;
							}
							
							var po:ProductObject = object;
							if(!tables && po.productInfo.type!=CabinetType.BODY)continue;//避开障碍物
							
							if(!tables)
							{
								tables = [];
								tabless.push(tables);
								
								depths = [];
								depthss.push(depths);
								depths.push(getTableWidth(wo));//当前子区域台面宽度
							}
							else if(po.name==ProductObjectName.CORNER_CABINET)//存在拐角柜
							{
								if(wo.width==900)
								{
									addGroundCabinetPlate(cw,450,wo.x-450,551,"拐角地柜左侧封板");
								}
								else if(wo.width == 800)//窄柜转角柜
								{
									
								}
								else//转角柜在另一边，此处为投影
								{
									var two:WallObject = gos[k+1];
									var tx1:Number = two.x - two.width;
									var w:Number = tx1 - wo.x - 20;
									if(w>1)
									{
										addGroundCabinetPlate(cw,w,tx1,551,"地柜拐角侧缝挡板");
									}
								}
							}
							
							tableData = new WallSubArea();//台面子区域开始
							tableData.cw = cw;
							tables.push(tableData);
							
							setHeadTableData(tableData,wo,cw);
						}
						else if(depths.length<tables.length)
						{
							depths.push(getTableWidth(wo));//当前子区域台面宽度
						}
						
						if(!hasGroundCabinet(gos,k+1))//柜子右侧没有柜子了
						{
							if(cwLen==1)//当前子区域只有一面墙
							{
								setEndTableData(tableData,wo,cw);
								//trace("柜子右侧没有柜子了");
								tables = null;
								break;
							}
							else//相连子区域
							{
								po = object;
								if(po.name==ProductObjectName.CORNER_CABINET)//存在拐角柜
								{
									tableData.x1 = cw.localEnd.x;
									
									if(wo.width==900)
									{
										addGroundCabinetPlate(cw,450,wo.x,551,"拐角地柜右侧封板");
									}
									else if(wo.width == 800)//窄柜转角柜
									{
										
									}
									else//转角柜在另一边，此处为投影
									{
										two = gos[k-1];
										tx1 = wo.x - wo.width - 20;
										w = tx1 - two.x;
										if(w>1)
										{
											addGroundCabinetPlate(cw,w,tx1,551,"地柜拐角侧缝挡板");
										}
									}
								}
								else//如果拐角处没有拐角柜，将新建子区域
								{
									setEndTableData(tableData,wo,cw);
									
									tables = null;
								}
								
								tableData = null;
							}
						}
						else if(object is WallHole)//在柜子右侧遇到墙洞，并且墙洞右侧还有柜子
						{
							wo = gos[k-1];
							setEndTableData(tableData,wo,cw);
							
							tables = null;
							tableData = null;
						}
					}
				}
			}
			
			return tabless;
		}
		
		public function addGroundCabinetPlate(cw:CrossWall,width:int,xPos:Number,zPos:Number,name:String):ProductObject
		{
			var po:ProductObject = cabinetCreator.createCabinetPlate(cw,width,720,16,xPos,CrossWall.IGNORE_OBJECT_HEIGHT,zPos,CabinetType.DOOR_PLANK,name);
			cabinetCreator.addGroundCabinet(po);
			productManager.updateProductModel(po);
			return po;
		}
		
		public function addWallCabinetPlate(cw:CrossWall,width:int,xPos:Number,zPos:Number,name:String):ProductObject
		{
			var po:ProductObject = cabinetCreator.createCabinetPlate(cw,width,720,16,xPos,CrossWall.WALL_OBJECT_HEIGHT,zPos,CabinetType.DOOR_PLANK,name);
			cabinetCreator.addWallCabinet(po);
			productManager.updateProductModel(po);
			return po;
		}
		
		public function addCabinetLegPlate(cw:CrossWall,width:int,height:int,depth:int,xPos:Number,zPos:Number):ProductObject
		{
			var po:ProductObject = cabinetCreator.createCabinetPlate(cw,width,height,depth,xPos,0,zPos,CabinetType.LEG_BAFFLE,"柜腿封板");
			productManager.updateProductModel(po);
			return po;
		}
		
		public function addWallCabinetBottomPlate(cw:CrossWall,width:int,height:int,depth:int,xPos:Number,yPos:Number,zPos:Number):ProductObject
		{
			var po:ProductObject = cabinetCreator.createCabinetPlate(cw,width,10,330,xPos,CrossWall.WALL_OBJECT_HEIGHT,0,CabinetType.BODY_PLANK,"吊柜拐角底缝挡板");
			productManager.updateProductModel(po);
			return po;
		}
		
		//计算厨柜所在台面的宽度
		private function getTableWidth(wo:WallObject):Number
		{
			var z:Number = wo.z + wo.depth + 50;
			//trace("getTableWidth:"+z,wo.z,wo.depth);
			return z;
		}
		
		private function setHeadTableData(tableData:WallSubArea,wo:WallObject,cw:CrossWall):void
		{
			//trace("setHeadTableData:"+wo.height);
			var tx0:Number = wo.x - wo.width;
			if(tx0-cw.localHead.x>maxAlongWidth)//第一个柜子与墙端的距离大于限制值
			{
				tableData.x0 = tx0 - alongWidth;
				//trace("1");
			}
			else
			{
				tableData.x0 = cw.localHead.x;//柜子与墙之间小于限制值时，会用封板封上
				//trace("2");
			}
			
			if(wo.height>CrossWall.GROUND_OBJECT_HEIGHT)//厨柜高度大于800时，作为中高柜处理
			{
				tableData.headCabinet = wo.object;
				tableData.x0 = tx0;
				//trace("3");
			}
			
			if(tableData.x0 == cw.localHead.x)
			{
				var w:Number = tx0-tableData.x0;
				if(w>1)
				{
					addGroundCabinetPlate(cw,w,tx0,wo.depth+1,"地柜侧缝挡板");
				}
			}
		}
		
		private function setEndTableData(tableData:WallSubArea,wo:WallObject,cw:CrossWall):void
		{
			trace("setEndTableData:"+wo.height);
			var tx1:Number = wo.x;
			if(cw.localEnd.x-tx1>maxAlongWidth)
			{
				tableData.x1 = tx1 + alongWidth;
			}
			else
			{
				tableData.x1 = cw.localEnd.x;
			}
			
			if(wo.height>CrossWall.GROUND_OBJECT_HEIGHT)
			{
				tableData.endCabinet = wo.object;
				tableData.x1 = tx1;
			}
			
			if(tableData.x1 == cw.localEnd.x)
			{
				var w:Number = tableData.x1 - tx1;
				trace("w:"+w);
				if(w>1)
				{
					addGroundCabinetPlate(cw,w,tableData.x1,wo.depth+1,"地柜侧缝挡板");
				}
			}
		}
		
		//检测从startIndex位置起，gos数组中是否存在柜子
		private function hasGroundCabinet(gos:Array,startIndex:int):Boolean
		{
			var len:int = gos.length;
			for(var i:int=startIndex;i<len;i++)
			{
				var wo:WallObject = gos[i];
				var object:* = wo.object;
				if(object is ProductObject)
				{
					var po:ProductObject = object;
					if(po.productInfo.type==CabinetType.BODY)
					{
						return true;
					}
				}
				//if(wo.y+wo.height==CrossWall.GROUND_OBJECT_HEIGHT)return true;
			}
			
			return false;
		}
		
		//计算对应到墙面上的厨柜组合
		private function countCabinetWithWall():String
		{
			var cabs:Array = productManager.getProductObjectsByType(CabinetType.BODY);
			//var len:int = cabs.length;
			//trace("getCabinetProduct:"+len);
			
			for each(var po:ProductObject in cabs)
			{
				var wo:WallObject = po.objectInfo;
				var cw:CrossWall = wo.crossWall;
				if(!cw)
				{
					return "发现未吸附到墙面的厨柜："+po.name;
				}
				
				//cabinetCreator.addSingleDoor(po);
				
				var a:Array;
				if(wo.y<CrossWall.GROUND_OBJECT_HEIGHT)//地柜
				{
					if(groundCabinetDict[cw])
					{
						a = groundCabinetDict[cw];
					}
					else
					{
						a = [];
						groundCabinetDict[cw] = a;
					}
					a.push(po);
				}
				
				if(wo.y>CrossWall.GROUND_OBJECT_HEIGHT)//吊柜
				{
					if(wallCabinetDict[cw])
					{
						a = wallCabinetDict[cw];
					}
					else
					{
						a = [];
						wallCabinetDict[cw] = a;
					}
					a.push(po);
				}
			}
			
			return "";
		}
		
		private function sortCabinet(cabDict:Dictionary):void
		{
			for each(var a:Array in cabDict)
			{
				a.sortOn("objectX",Array.NUMERIC);
			}
		}
		
		private function sortCrossWall(cabDict:Dictionary):Array
		{
			var a:Array = [];
			for(var cw:CrossWall in cabDict)
			{
				a.push(cw);
			}
			
			var len:int = a.length;
			if(len==1)return [a];
			
			var cw0:CrossWall;
			var cw1:CrossWall;
			var cw2:CrossWall;
			
			if(len==2)
			{
				cw0 = a[0];
				cw1 = a[1];
				
				if(cw0.endCrossWall==cw1)return [a];
				if(cw0.headCrossWall==cw1)return [[cw1,cw0]];
				return [[cw1],[cw0]];
			}
			
			if(len==3)
			{
				cw0 = a[0];
				cw1 = a[1];
				cw2 = a[2];
				//012*
				//021*
				//102*
				//120
				//210
				//201*
				if(cw0.endCrossWall==cw1 && cw1.endCrossWall==cw2)return [a];
				if(cw0.endCrossWall==cw2 && cw2.endCrossWall==cw1)return [[cw0,cw2,cw1]];
				
				if(cw1.endCrossWall==cw0 && cw0.endCrossWall==cw2)return [[cw1,cw0,cw2]];
				if(cw1.endCrossWall==cw2 && cw2.endCrossWall==cw0)return [[cw1,cw2,cw0]];
				
				if(cw2.endCrossWall==cw1 && cw1.endCrossWall==cw0)return [[cw2,cw1,cw0]];
				if(cw2.endCrossWall==cw0 && cw0.endCrossWall==cw1)return [[cw2,cw0,cw1]]
			}
			
			return null;
		}
		
		//==================================================
		static private var _own:TableBuilder;
		static public function get own():TableBuilder
		{
			return _own ||= new TableBuilder();
		}
	}
}