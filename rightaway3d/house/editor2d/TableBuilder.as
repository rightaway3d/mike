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
		private var allCabinetDict:Dictionary;
		
		public function builderTable():String
		{
			groundCabinetDict = new Dictionary();
			wallCabinetDict = new Dictionary();
			allCabinetDict = new Dictionary();
			
			var msg:String = countCabinetWithWall();
			if(msg)return msg;
			
			updateCrossWallFace();
			
			sortCabinet(groundCabinetDict);
			
			var groundArea:Array = sortCrossWall(groundCabinetDict);
			if(groundArea)
			{
				var depthss:Array = [];
				var tabless:Array = resetGroundArea(groundArea,groundCabinetDict,depthss);
				cabinetCreator.createCabinetTable3(tabless,depthss);//[[600,600,600],[600,600,600],[600,600,600]]);
				
				var house:House = House.getInstance();
				house.updateBounds();
				cabinetCreator.updateTableMeshsPos(house.x,house.z);
			}
			
			sortCabinet(wallCabinetDict);
			var wallArea:Array = sortCrossWall(wallCabinetDict);
			if(wallArea)
			{
				resetWallCabinetPlate(wallArea,wallCabinetDict);
			}
			
			return null;
		}
		
		private function updateCrossWallFace():void
		{
			var ccws:Vector.<CrossWall> = this.cabinetCreator.cabinetCrossWalls;
			ccws.length = 0;
			
			var allArea:Array = sortCrossWall(allCabinetDict);
			var alen:int = allArea.length;
			for(var i:int=0;i<alen;i++)
			{
				var cws:Array = allArea[i];
				var clen:int = cws.length;
				for(var j:int=0;j<clen;j++)
				{
					var cw:CrossWall = cws[j];
					ccws.push(cw);
				}
			}
		}
		
		public function builderDoor():void
		{
			var cabs:Array = productManager.getProductObjectsByType(CabinetType.BODY);
			for each(var po:ProductObject in cabs)
			{
				cabinetCreator.addSingleDoor(po,null);
			}			
		}
		
		public var alongWidth:int = 20;//台面两端出沿宽度
		public var maxAlongWidth:int = 100;//台面两端出沿宽度
		
		//创建台面前检查，同一面墙不出现连续门洞，同一面墙上的柜子之间不能有间隙，有障碍物（烟道、方柱）除外
		//同一墙同一区域的柜子深度须一致，拐角柜只能出现在拐角处
		//同一面墙上，两个放置台面的柜子之间不能有中高柜
		private function testCabinet():void
		{
			
		}
		
		
		private function resetGroundArea(groundArea:Array,wallDict:Dictionary,depthss:Array):Array
		{
			var tables:Array;
			var depths:Array;
			var tableData:WallSubArea;
			var isAreaStart:Boolean = false;
			
			var cab0:ProductObject;
			var cab1:ProductObject;
			
			var tabless:Array = setGroundArea(groundArea,wallDict);
			setGroundLeg(tabless);
			setGroundArea2(tabless);
			
			var areaLen:int = tabless.length;
			
			for(var i:int=0;i<areaLen;i++)
			{
				var subs:Array = tabless[i];
				var subLen:int = subs.length;
				cab0 = null;
				
				depths = [];
				depthss.push(depths);
				
				for(var j:int=0;j<subLen;j++)
				{
					tableData = subs[j];
					var cw:CrossWall = tableData.cw;
					var cabs:Array = tableData.groundObjects;
					var woLen:int = cabs.length;
					isAreaStart = false;
					
					for(var k:int=0;k<woLen;k++)
					{
						//trace("i,j,k:",i,j,k);
						cab1 = cabs[k];
						var wo:WallObject = cab1.objectInfo;
						if(!isAreaStart)
						{
							if(wo.height>CrossWall.GROUND_OBJECT_HEIGHT)//当前为中高柜
							{
								var two:WallObject = cabs[k+1].objectInfo;
								if(two.height>CrossWall.GROUND_OBJECT_HEIGHT)//如果碰到连续的中高柜，则跳过前面的
								{
									continue;//跳出当前循环，进入下一轮循环
								}
								
								tableData.headCabinet = cab1;
							}
							
							if(j>0)//拐角区域
							{
								setCornerCabinet(cab0,cab1);
								tableData.x0 = cw.localHead.x;
							}
							else
							{
								this.setHeadTableData(tableData,wo,cw);
							}
							
							depths.push(this.getTableWidth(wo));
							//trace("depths:"+depths.length,depths);
							
							isAreaStart = true;
						}
						
						if(isAreaStart && tableData.headCabinet!=cab1)
						{
							tableData.x1 = wo.x;
							if(wo.height>CrossWall.GROUND_OBJECT_HEIGHT)//碰到尾部第一个拐角柜
							{
								tableData.endCabinet = cab1;
								break;
							}
							
							if(k==woLen-1)//当前子区域最后一个柜子
							{
								if(j==subLen-1)//当前区域的尾部
								{
									this.setEndTableData(tableData,wo,cw);
								}
								else//后面还有子区域
								{
									tableData.x1 = cw.localEnd.x;
								}
							}
							
							var dz:int = 19;//地柜封板缩进距离
							if(cab0)
							{
								var w0:WallObject = cab0.objectInfo;
								var w1:WallObject = cab1.objectInfo;
								
								var dx1:Number = w1.x - w1.width;
								var dw:Number = dx1 - w0.x;
								if(dw>10)
								{
									this.addGroundCabinetPlate(cw,dw,dx1,w0.z+w0.depth-dz,"地柜间隙封板");
								}
							}
						}
						
						cab0 = cab1;
					}
					
					//trace("tableData.x0,tableData.x1,wall.index:"+tableData.x0,tableData.x1,cw.wall.index);
				}
			}
			
			return tabless;
		}
		
		//设置拐角柜及封板
		private function setCornerCabinet(cab0:ProductObject, cab1:ProductObject):void
		{
			var w0:WallObject = cab0.objectInfo;
			var cw0:CrossWall = w0.crossWall;
			var w1:WallObject = cab1.objectInfo;
			var cw1:CrossWall = w1.crossWall;
			var dz:int = 19;//地柜拐角封板缩进距离
			
			if(cab0.name == ProductObjectName.CORNER_CABINET)//子区域尾部是拐角柜
			{
				var d:Number = w0.z+w0.depth;
				var ww:Number = w0.width*0.5;
				//addGroundCabinetPlate(cw0,w0.width*0.5,w0.x,d-dz,"拐角地柜右侧封板");
				if(cw0.localEnd.x - (w0.x-ww+maxWidth)>w1.z+w1.depth)
				{
					this.addGroundCabinetPlate(cw0,ww,w0.x,d-dz,"拐角地柜右侧封板");
				}
				else
				{
					this.addGroundCornerPlate(cw0,ww-100,w0.x,d-dz,"拐角地柜右侧封板1");
					this.addGroundCabinetPlate(cw0,100,w0.x-ww+100,d-dz,"拐角地柜右侧封板2");
				}
				
				tx = w1.x - w1.width;
				w = tx - cw1.localHead.x - d;
				if(w>1)// && w<=100)
				{
					addGroundCabinetPlate(cw1,w,tx,w1.z+w1.depth-dz,"地柜拐角侧缝挡板");
				}
			}
			else if(cab1.name==ProductObjectName.CORNER_CABINET)//子区域头部是拐角柜
			{
				var w:Number = w1.width * 0.5;
				d = w1.z+w1.depth;
				ww = w1.width*0.5;
				//addGroundCabinetPlate(cw1,w,w1.x-w,d-dz,"拐角地柜左侧封板");
				if(w1.x-ww-maxWidth-cw1.localHead.x>w0.z+w0.depth)
				{
					this.addGroundCabinetPlate(cw1,ww,w1.x-ww,d-dz,"拐角地柜左侧封板");
				}
				else
				{
					this.addGroundCornerPlate(cw1,ww-100,w1.x-ww-100,d-dz,"拐角地柜左侧封板1");
					this.addGroundCabinetPlate(cw1,100,w1.x-ww,d-dz,"拐角地柜左侧封板2");
				}
				
				var tx:Number = cw0.localEnd.x - d;
				w = tx - w0.x;
				if(w>1)// && w<=100)
				{
					addGroundCabinetPlate(cw0,w,tx,w0.z+w0.depth-dz,"地柜拐角侧缝挡板");
				}
			}
		}
		
		//设置厨柜分区，去掉不能放置台面的分区
		private function setGroundArea2(tabless:Array):void
		{
			var areaLen:int = tabless.length;
			for(var i:int=areaLen-1;i>=0;i--)
			{
				var subs:Array = tabless[i];
				var subLen:int = subs.length;
				for(var j:int=subLen-1;j>=0;j--)
				{
					var subArea:WallSubArea = subs[j];
					if(!hasTableCabinet(subArea))//如果子区域中不存在可放置台面的柜子，将从当前区域中去掉
					{
						subs.splice(j,1);
					}
				}
				
				if(subs.length==0)//如果当前区域为空，也将去掉
				{
					tabless.splice(i,1);
				}
			}
		}
		
		//设置柜脚挡板
		private function setGroundLeg(tabless:Array):void
		{
			var areaLen:int = tabless.length;
			for(var i:int=0;i<areaLen;i++)
			{
				var subs:Array = tabless[i];
				var subLen:int = subs.length;
				
				var subArea:WallSubArea = subs[0];
				var cw1:CrossWall = subArea.cw;
				var areas:Array = subArea.groundObjects;
				
				var p10:ProductObject = areas[0];
				var w10:WallObject = p10.objectInfo;
				
				var p11:ProductObject = areas[areas.length-1];
				var w11:WallObject = p11.objectInfo;
				
				var isHeadPlate:Boolean = isNeedHeadPlate(cw1,w10);//柜子左侧是否需要封板
				var td:Number = this.getGroundPlateDepth(w10);
				var tx0:Number = isHeadPlate ? w10.x - w10.width + 15 : cw1.localHead.x;
				
				if(isHeadPlate)
				{
					var legPlate:ProductObject = this.addCabinetLegPlate(cw1,5,td,tx0+5,0);
				}
				
				for(var j:int=1;j<subLen;j++)
				{
					var cw0:CrossWall = cw1;
					var w00:WallObject = w10;
					var w01:WallObject = w11;
					
					subArea = subs[j];
					cw1 = subArea.cw;
					areas = subArea.groundObjects;
					
					p10 = areas[0];
					w10 = p10.objectInfo;
					
					p11 = areas[areas.length-1];
					w11 = p11.objectInfo;
					
					tx1 = cw0.localEnd.x - this.getGroundPlateDepth(w10);
					tw = tx1 - tx0;
					tz = this.getGroundPlateDepth(w00);
					this.addCabinetLegPlate(cw0,tw,5,tx1,tz);
					
					tx0 = cw1.localHead.x + this.getGroundPlateDepth(w01);
				}
				
				var isEndPlate:Boolean = isNeedEndPlate(cw1,w11);
				var tx1:Number = isEndPlate ? w11.x - 15 : cw1.localEnd.x;
				//if(w01)tx0 = cw1.localHead.x + this.getGroundPlateDepth(w01);
				
				var tw:Number = tx1 - tx0;
				var tz:Number = this.getGroundPlateDepth(w10);
				
				this.addCabinetLegPlate(cw1,tw,5,tx1,tz);
				
				if(isEndPlate)
				{
					legPlate = this.addCabinetLegPlate(cw1,5,tz,tx1,0);
				}
			}
		}
		
		//计算柜子左侧是否需要加侧封板
		private function isNeedHeadPlate(cw:CrossWall,wo:WallObject):Boolean
		{
			var dw:Number = wo.x - wo.width - cw.localHead.x;
			
			//中高柜没有贴墙放时，需要加侧封板
			if(wo.height > CrossWall.GROUND_OBJECT_HEIGHT && dw > 1)return true;
			
			//普通柜子距墙端超过100的，要加侧封板
			if(dw > 100)return true;
			
			return false;
		}
		
		//计算柜子右侧是否需要加侧封板
		private function isNeedEndPlate(cw:CrossWall,wo:WallObject):Boolean
		{
			var dw:Number = cw.localEnd.x - wo.x;
			
			//中高柜没有贴墙放时，需要加侧封板
			if(wo.height > CrossWall.GROUND_OBJECT_HEIGHT && dw > 1)return true;
			
			//普通柜子距墙端超过100的，要加侧封板
			if(dw > 100)return true;
			
			return false;
		}
		
		//检查当前子分区中是否存在可创建台面的柜子
		private function hasTableCabinet(subArea:WallSubArea):Boolean
		{
			var areas:Array = subArea.groundObjects;
			var len:int = areas.length;
			for(var i:int=0;i<len;i++)
			{
				var po:ProductObject = areas[i];
				var wo:WallObject = po.objectInfo;
				if(wo.height==720)return true;
			}
			return false;
		}
		
		//设置厨柜分区，每一块相连厨柜为一个分区
		private function setGroundArea(groundArea:Array,wallDict:Dictionary):Array
		{
			var tabless:Array = [];
			var tableData:WallSubArea;
			var tables:Array;
			var areaLen:int = groundArea.length;
			var cab0:ProductObject,cab1:ProductObject;
			var w0:WallObject,w1:WallObject;
			
			for(var i:int=0;i<areaLen;i++)
			{
				var cws:Array = groundArea[i];
				var cwLen:int = cws.length;
				
				tables = [];
				tabless.push(tables);
				//cab0 = null;
				
				for(var j:int=0;j<cwLen;j++)
				{
					var cw:CrossWall = cws[j];
					var cabs:Array = wallDict[cw];
					var woLen:int = cabs.length;
					
					cab0 = cabs[0];
					w0 = cab0.objectInfo;
					
					if(j>0)
					{
						if(w0.height>CrossWall.GROUND_OBJECT_HEIGHT//后一面墙的第一个柜子为中高柜时
							|| w1.height>CrossWall.GROUND_OBJECT_HEIGHT//前一面墙的最后一个柜子是中高柜
							|| (cab0.name!=ProductObjectName.CORNER_CABINET && cab1.name!=ProductObjectName.CORNER_CABINET))//拐角没有拐角柜
						{
							//开始新的台面分区
							tables = [];
							tabless.push(tables);
						}
					}
					
					var subArea:Array = [];
					
					tableData = new WallSubArea();
					tableData.groundObjects = subArea;
					tableData.cw = cw;
					
					tables.push(tableData);
					
					subArea.push(cab0);
					
					cab1 = cab0;//防止当前子区域只有一个柜子的情况
					w1 = w0;
					
					for(var k:int=1;k<woLen;k++)
					{
						cab1 = cabs[k];
						w1 = cab1.objectInfo;
						
						var a:Array = [];
						cw.getGroundObjectOfPos(w0.x,w1.x-w1.width,a);//计算两个柜子这间是否存在门洞
						
						var dist:Number = w1.x - w1.width - w0.x;//计算两个柜子之间的距离
						
						if(dist>800 || hasWallHole(a))//从门洞后面开始新的分区
						{
							tables = [];
							tabless.push(tables);
							
							subArea = [];
							
							tableData = new WallSubArea();
							tableData.groundObjects = subArea;
							tableData.cw = cw;
							
							tables.push(tableData);
						}
						
						cab0 = cab1;
						w0 = w1;
						
						subArea.push(cab1);
					}
				}
			}
			
			return tabless;
		}
		
		//检测数组中是否有墙洞存在
		private function hasWallHole(a:Array):Boolean
		{
			var len:int=a.length;
			for(var i:int=0;i<len;i++)
			{
				var wo:WallObject = a[i];
				if(wo.object is WallHole)
				{
					return true;
				}
			}
			return false;
		}
		
		/*厨柜分区判断
		厨柜子区域墙体数量超过一时，拐角处需放置拐角柜，如不放拐角柜，将作新增拆分子区域处理
		如果在厨柜之间有门隔开，则要增加厨柜子区域，如果门洞不在厨柜之间，则要避开门洞
		*/
		/*private function resetGroundArea2(groundArea:Array,depthss:Array):Array
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
							
							var isCreateNewSubArea:Boolean = true;//是否要创建新的子分区，只有拐角另一面墙以中高柜开始时，才不要创建
							
							if(!tables)//新的分区开始
							{
								tables = [];
								tabless.push(tables);
								
								depths = [];
								depthss.push(depths);
								depths.push(getTableWidth(wo));//当前子区域台面宽度
							}
							else if(po.name==ProductObjectName.CORNER_CABINET)//拐角开始处存在拐角柜
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
									if(two.height>CrossWall.GROUND_OBJECT_HEIGHT)//拐角柜过来是中高柜
									{
										isCreateNewSubArea = false;//此处没有考虑中高柜的右边再放置台面的情况
									}
									else
									{
										var tx1:Number = two.x - two.width;
										var w:Number = tx1 - wo.x - 20;
										if(w>1)
										{
											addGroundCabinetPlate(cw,w,tx1,two.z+two.depth+1,"地柜拐角侧缝挡板");
										}
									}
								}
							}
							
							if(isCreateNewSubArea)
							{
								tableData = new WallSubArea();//台面子区域开始
								tableData.cw = cw;
								tables.push(tableData);
								
								setHeadTableData(tableData,wo,cw);
							}
						}
						else if(depths.length<tables.length)
						{
							depths.push(getTableWidth(wo));//当前子区域台面宽度
						}
						
						if(!hasGroundCabinet(gos,k+1))//柜子右侧没有柜子了(当前到了墙尾)
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
										if(two.height>CrossWall.GROUND_OBJECT_HEIGHT)//拐角柜过来是中高柜
										{
											//isCreateNewSubArea = false;//此处没有考虑中高柜的右边再放置台面的情况
										}
										else
										{
											tx1 = wo.x - wo.width - 20;
											w = tx1 - two.x;
											if(w>1)
											{
												addGroundCabinetPlate(cw,w,tx1,two.z+two.depth+1,"地柜拐角侧缝挡板");
											}
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
		}*/
		
		private const maxWidth:int = 90;//使用窄封板时，最大露出宽度
		
		private function resetWallCabinetPlate(wallArea:Array,wallDict:Dictionary):void
		{
			var areaLen:int = wallArea.length;
			for(var i:int=0;i<areaLen;i++)
			{
				var cws:Array = wallArea[i];
				var cwLen:int = cws.length;
				
				if(cwLen>1)
				{
					for(var j:int=1;j<cwLen;j++)
					{
						var cw0:CrossWall = cws[j-1];//前一面墙
						var cw1:CrossWall = cws[j];//当前墙
						
						var wos0:Array = wallDict[cw0];//前一面墙的所有柜子
						var wos1:Array = wallDict[cw1];//当前墙上的所有柜子
						
						var p0:ProductObject = wos0[wos0.length-1];//前一面墙的最后一个柜子
						var p1:ProductObject = wos1[0];//当前墙上的第一个柜子
						
						var w0:WallObject = p0.objectInfo;//拐角处的前一个柜子
						var w1:WallObject = p1.objectInfo;//拐角处的后一个柜子
						
						if(p0.name==ProductObjectName.CORNER_CABINET)//前一个柜子是拐角柜
						{
							var tx11:Number = w1.x - w1.width;
							var tw1:Number = tx11 - cw1.localHead.x - 350;
							if(tw1>1 && tw1<=100 && cw0.localEnd.x-w0.x < 350)//侧缝宽度不超过100，且拐角柜侧面距墙不超过柜子深度
							{
								this.addWallCabinetPlate(cw1,tw1,tx11,331,"吊柜拐角侧缝挡板");
								this.addWallCabinetBottomPlate(cw1,tw1,tx11);
								//在拐角柜的右侧创建封板
								if(cw0.localEnd.x - (w0.x-w0.width*0.5+maxWidth)>w1.z+w1.depth)
								{
									this.addWallCabinetPlate(cw0,400,w0.x,331,"拐角吊柜右侧封板");
								}
								else
								{
									this.addWallCornerPlate(cw0,300,w0.x,331,"拐角吊柜右侧封板1");
									this.addWallCabinetPlate(cw0,100,w0.x-300,331,"拐角吊柜右侧封板2");
								}
							}
							else
							{
								this.addWallCabinetPlate(cw0,400,w0.x,331,"拐角吊柜右侧封板");
							}
						}
						else if(p1.name==ProductObjectName.CORNER_CABINET)
						{
							var tw0:Number = cw0.localEnd.x - w0.x - 350;
							if(tw0>1 && tw0<100 && w1.x-w1.width-cw1.localHead.x < 350)//侧缝宽度不超过100，且拐角柜侧面距墙不超过柜子深度
							{
								var tx01:Number = w0.x+tw0;
								this.addWallCabinetPlate(cw0,tw0,tx01,331,"吊柜拐角侧缝挡板");
								this.addWallCabinetBottomPlate(cw0,tw0,tx01);
								
								if(w1.x-w1.width*0.5-maxWidth-cw1.localHead.x>w0.z+w0.depth)
								{
									this.addWallCabinetPlate(cw1,400,w1.x-400,331,"拐角吊柜左侧封板");
								}
								else
								{
									this.addWallCornerPlate(cw1,300,w1.x-500,331,"拐角吊柜左侧封板1");
									this.addWallCabinetPlate(cw1,100,w1.x-400,331,"拐角吊柜左侧封板2");
								}
							}
							else
							{
								this.addWallCabinetPlate(cw1,400,w1.x-400,331,"拐角吊柜左侧封板");
							}
						}
					}
				}
			}
		}
		
		private function addGroundCabinetPlate(cw:CrossWall,width:int,xPos:Number,zPos:Number,name:String):ProductObject
		{
			var po:ProductObject = cabinetCreator.createCabinetPlate(cw,width,720,16,xPos,CrossWall.IGNORE_OBJECT_HEIGHT,zPos,CabinetType.DOOR_PLANK,name);
			cabinetCreator.addGroundCabinet(po);
			//productManager.updateProductModel(po);
			return po;
		}
		
		private function addGroundCornerPlate(cw:CrossWall,width:int,xPos:Number,zPos:Number,name:String):ProductObject
		{
			var po:ProductObject = cabinetCreator.createCabinetPlate(cw,width,720,16,xPos,CrossWall.IGNORE_OBJECT_HEIGHT,zPos,CabinetType.BODY_PLANK,name);
			//cabinetCreator.addGroundCabinet(po);
			//productManager.updateProductModel(po);
			return po;
		}
		
		private function addWallCabinetPlate(cw:CrossWall,width:int,xPos:Number,zPos:Number,name:String):ProductObject
		{
			var po:ProductObject = cabinetCreator.createCabinetPlate(cw,width,720,16,xPos,CrossWall.WALL_OBJECT_HEIGHT,zPos,CabinetType.DOOR_PLANK,name);
			cabinetCreator.addWallCabinet(po);
			//productManager.updateProductModel(po);
			return po;
		}
		
		private function addWallCornerPlate(cw:CrossWall,width:int,xPos:Number,zPos:Number,name:String):ProductObject
		{
			var po:ProductObject = cabinetCreator.createCabinetPlate(cw,width,720,16,xPos,CrossWall.WALL_OBJECT_HEIGHT,zPos,CabinetType.BODY_PLANK,name);
			//cabinetCreator.addWallCabinet(po);
			//productManager.updateProductModel(po);
			return po;
		}
		
		private function addCabinetLegPlate(cw:CrossWall,width:int,depth:int,xPos:Number,zPos:Number):ProductObject
		{
			var po:ProductObject = cabinetCreator.createCabinetPlate(cw,width,80,depth,xPos,0,zPos,CabinetType.LEG_BAFFLE,"柜腿封板");
			//productManager.updateProductModel(po);
			addLegPlateConnection(po);
			return po;
		}
		
		private function addWallCabinetBottomPlate(cw:CrossWall,width:int,xPos:Number):ProductObject
		{
			var po:ProductObject = cabinetCreator.createCabinetPlate(cw,width,10,330,xPos,CrossWall.WALL_OBJECT_HEIGHT,0,CabinetType.BODY_PLANK,"吊柜拐角底缝挡板");
			//productManager.updateProductModel(po);
			return po;
		}
		
		private function addLegPlateConnection(po:ProductObject):void
		{
			var subData:XML =
				<item>
					<infoID></infoID>
					<objectID>0</objectID>
					<name></name>
					<name_en/>
					<file></file>
					<dataFormat>text</dataFormat>
					<position>0,0,0</position>
					<rotation>0,0,0</rotation>
					<scale>1,1,1</scale>
					<active>false</active>
				</item>;

			var w:int = po.objectInfo.width;
			var d:int = po.objectInfo.depth;
			var length:Number;
			trace("addLegPlateConnection width,depth:",w,d);
			
			if(d>w)
			{
				subData.infoID = "1703";
				subData.file = "leg_plank_1703_jiao.pdt";
				productManager.addDynamicSubProduct(po,subData);
				length = d*0.001;//长度单位转化为米
			}
			else
			{
				length = w*0.001;//长度单位转化为米
			}
			
			do{
				var n:Number;
				if(length>3)
				{
					subData.infoID = "1702";
					subData.file = "leg_plank_1702_ping.pdt";
					productManager.addDynamicSubProduct(po,subData);
					n = 3;
				}
				else
				{
					n = length;
				}
				
				subData.infoID = "1701";
				subData.file = "leg_plank_1701.pdt";
				var spo:ProductObject = productManager.addDynamicSubProduct(po,subData);
				spo.memo = String(n);
				
				length -= 3;
			}while(length>0)
		}
		
		//计算厨柜所在台面的宽度
		private function getTableWidth(wo:WallObject):Number
		{
			var z:Number = wo.z + wo.depth + 30;
			//trace("getTableWidth:"+z,wo.z,wo.depth);
			return z;
		}
		
		private function getGroundPlateDepth(wo:WallObject):Number
		{
			var z:Number = wo.z + wo.depth - 50;
			//trace("getGroundPlateDepth:"+z,wo.z,wo.depth);
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
			
			var dz:int = 19;//地柜封板缩进距离
			if(tableData.x0 == cw.localHead.x)
			{
				var w:Number = tx0-tableData.x0;
				if(w>1)
				{
					addGroundCabinetPlate(cw,w,tx0,wo.z+wo.depth-dz,"地柜侧缝挡板");
				}
			}
		}
		
		private function setEndTableData(tableData:WallSubArea,wo:WallObject,cw:CrossWall):void
		{
			//trace("setEndTableData:"+wo.height);
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
			
			var dz:int = 19;//地柜封板缩进距离
			if(tableData.x1 == cw.localEnd.x)
			{
				var w:Number = tableData.x1 - tx1;
				//trace("w:"+w);
				if(w>1)
				{
					addGroundCabinetPlate(cw,w,tableData.x1,wo.depth-dz,"地柜侧缝挡板");
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
					return "发现未吸附到墙面的厨柜："+po.productInfo.name;
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
				else if(wo.y>CrossWall.GROUND_OBJECT_HEIGHT)//吊柜
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
				
				if(!allCabinetDict[cw])
				{
					allCabinetDict[cw] = cw;
				}
			}
			
			return null;
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