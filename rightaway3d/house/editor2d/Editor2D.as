package rightaway3d.house.editor2d
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	
	import rightaway3d.URLTool;
	import rightaway3d.engine.model.ModelObject;
	import rightaway3d.engine.product.ProductInfo;
	import rightaway3d.engine.product.ProductManager;
	import rightaway3d.engine.product.ProductObject;
	import rightaway3d.engine.product.ProductObjectName;
	import rightaway3d.engine.utils.ActionHistory;
	import rightaway3d.engine.utils.BMP;
	import rightaway3d.engine.utils.GlobalEvent;
	import rightaway3d.engine.utils.GlobalVar;
	import rightaway3d.engine.utils.Tips;
	import rightaway3d.house.cabinet.CabinetType;
	import rightaway3d.house.lib.CabinetLib;
	import rightaway3d.house.lib.CabinetTool;
	import rightaway3d.house.view2d.BackGrid2D;
	import rightaway3d.house.view2d.Base2D;
	import rightaway3d.house.view2d.NodeController2D;
	import rightaway3d.house.view2d.Product2D;
	import rightaway3d.house.view2d.ScaleRuler2D;
	import rightaway3d.house.view2d.SizeMarking2D;
	import rightaway3d.house.view2d.Wall2D;
	import rightaway3d.house.view2d.WinDoor2D;
	import rightaway3d.house.view3d.Scene3D;
	import rightaway3d.house.vo.CrossWall;
	import rightaway3d.house.vo.Floor;
	import rightaway3d.house.vo.House;
	import rightaway3d.house.vo.WallHole;
	import rightaway3d.user.User;
	import rightaway3d.utils.MyTextField;
	
	import ztc.meshbuilder.room.DragObject;
	import ztc.meshbuilder.room.MaterialLibrary;
	import ztc.meshbuilder.room.RenderUtils;
	import ztc.utils.Tools;

	[SWF(backgroundColor="#E2E2E2", frameRate="30", width="800", height="600")]
	public class Editor2D extends Sprite
	{
		protected var container2d:Sprite;
		
		protected var masker:Shape;
		protected var scene2d:Scene2D;
		
		protected var wallFaceContainer:Sprite;
		
		protected var wallFaceViewer:WallFaceViewer;
		
		protected var scene3d:Scene3D;
		
		protected var sceneCtr:SceneController2D;
		
		protected var nodeCtr:NodeController2D;
		
		protected var windCtr:WindoorController;
		
		protected var wallCtr:WallController;
		
		protected var cabinetCtr:CabinetController;
		
		protected var cabinetCreator:CabinetCreator;
		
		protected var ruler:ScaleRuler2D;
		
		//private var user:User;
		//private var projectManager:ProjectManager;
		
		protected var house:House = House.getInstance();
		
		public function Editor2D()
		{
			super();
			
			init();
			
			if(stage)
			{
				initView();
			}
			else
			{
				//initScene();
				this.addEventListener(Event.ADDED_TO_STAGE,initView);
			}
			
			MyTextField;
			Tools;
			DragObject;
		}
		
		private function initView(e:Event=null):void
		{
			trace("--init--");
			Tips.stage = stage;
			
			initScene();
			
			if(e)//作为一个模块被加载时
			{
				this.removeEventListener(Event.ADDED_TO_STAGE,initView);
				initStage2();
			}
			else//调试时
			{
				initStage();
			}
		}
		
		private function init():void
		{
			container2d = new Sprite();
			this.addChild(container2d);
			
			masker = new Shape();
			container2d.addChild(masker);
			
			Scene2D.sceneWidth = 1000;
			Scene2D.sceneHeight = 1000;
			
			Wall2D.lineColor = 0xffffff;
			Wall2D.normalColor = 0xffffff;
			Wall2D.overColor = 0xffffff;
			Wall2D.selectColor = 0xffffff;
			
			WinDoor2D.lineColor = 0xeeeeee;
			WinDoor2D.fillColor = 0xcccccc;
			
			scene2d = new Scene2D();
			container2d.addChild(scene2d);
			scene2d.mask = masker;
			
			wallFaceContainer = new Sprite();
			container2d.addChild(wallFaceContainer);
			
			ruler = new ScaleRuler2D();
			container2d.addChild(ruler);
			ruler.x = 30;
			
			windCtr = WindoorController.getInstance();
			windCtr.scene = scene2d;
			
			sceneCtr = new SceneController2D(scene2d,masker,ruler);
			
			nodeCtr = NodeController2D.getInstance();
			
			wallCtr = WallController.getInstance();
			
			cabinetCtr = CabinetController.getInstance();
			cabinetCtr.scene = scene2d;
			cabinetCtr.sceneController = sceneCtr;
			
			cabinetCreator = CabinetCreator.getInstance();
			
			wallFaceViewer = new WallFaceViewer(wallFaceContainer,cabinetCreator.cabinetCrossWalls);
			
			//user = User.own;
			//projectManager = user.projectManager;
		}
		
		private function initScene():void
		{
			scene2d.backGrid.updateView(Scene2D.sceneWidth,Scene2D.sceneHeight,this.scene2d.scaleX);
			
			ruler.updateView(scene2d.scaleX);
			
			scene3d = new Scene3D();
			this.addChild(scene3d);
			scene3d.visible = false;
			
			cabinetCtr.engineManager = scene3d.engineManager;
			
			var s:String = "1/posX.jpg,1/negX.jpg,1/posY.jpg,1/negY.jpg,1/posZ.jpg,1/negZ.jpg";
			var a:Array = s.split(",");
			scene3d.loadSkyBoxTextures(a);
			
			this.setBackGridAlpha(0.2);
			
			//sceneCtr.createRoom(0,800,200,200);
			//TestNumer.test();
			//*
			//setBackGroundAlpha(0);
			//scene2d.createFloor(null);
			//sceneCtr.createRoom(350,350,125,200);
			//this.fitScreen(true);
			//*/
			//createRoom(3000,3000,3000,150);
			//lockRoom(true);
			
			//var data:String = "eNrFVV1v0zAU/S9+TqfZ8bK0rwMEEkKIDe0BVchLnMbMtSPHYR1VJcQTT/yOvfLGG3+G8Tu4dj6aTG1ZhURVKarPPffe4+P4Zom4mgnF0QShAOW6KuHvEmVSa1OiybslEirlCzQ5DpBic8f79ePz/fcvwJ4ZXan0ORez3HpCwoUUatYiJD5egxe5SK4VL6EodvANk/JSpDYHHoV1Cg3PhZRtMm6wbj32WaBG3/R5Y9zB61RHrdW91kLZwUZwgOAZec6tl/0JQArrVdCRiCdhsptFN7LiISna1M9zprULD9U1NiO3rbU/rdks9aR6+VSlXmuuJXdloGJmtLJnRpflJdR2Z2n5wlbGlVQVINBAmzmT7XoVoCuWXO+VMnTq74LJQDA9qODwMYLpQHB0UMH0MYKjgWB8AMHQyGg93/I233+7+/31Zzc0Lupqb9+8hBhcoJAeFWrWhV/52nW0A88LnlSSmf6oGdRBHfwgv0EHBXo3r6wtRNZUHNitdn8Em2NkRyzcEaOrqf8FqDA6rZJuMmX6xRNgjzBwMyF7NqfMsmduO3aN2duix9BXH3hi63yCOsdTw2CumwZ4z1XtBUus+OjiGZOlk1boUlihlTvkhZundDDywojQlTtay3qsmoLjmgTjDpUJk7yJ4jpaF4DYXKdcnmmpwfqYEhyFuJMNW2+ywmHnEe7edv/ByJvpfuI+DLzo8MaMo0SmbvdJ/6XderTN/WptD//Rdrq2PZO+016eYxxR0jcdhzHZZvpovL/pODql9OQ02uA6iXD8f1wn4Pp09QcDmqP5";
			//var data:String = "eNrFVc2O0zAQfhefyyp20iTbawGBhBBiF+0BVZWbuK1Z144Sh+2yqoQ4ceI59sqNGy/D8hyM7TQ/7bYsZaWqUtSZ+fzNzDfx5AYxOeOSoQFCPTRXZQF/b9BUKJUXaPD+BnGZsiUaeD0k6cLgfv34fPf9C6BnuSpl+oLx2VxbQMK44HK29pDYa5znc55cSlYAKTbuKyrEBU/1HHAB2CkkPONCrA/jylfbp/YUVKOu2rhTXLubowbqqnujuNSdRnAPwTO0mGtb9idwBmCvejWIWBAm+1HBvai4Cwrvy2cxI6fCZnWVzMi01eizFpumFuTMZzK1tc6VYI7G1O6R2KZyylgKK968I6VuBhIb8zpj5ghwl7kw+U0PQOdHQWDpTlt8uN8h9HYSkjYhNDzNldTDXBXFBbRuXjXNlrrMTceyBA/0r/IFFWt71UMTmlz+05HuIP+uJ+noGTR6HqFg/yEFB52Cw6MWHDyk4LBTMD5CwZAoV2qx47Ldfbv9/fVnvdPOHdu7t68gBvfbD04yOavDry23i1bpXOAsY0kpaN7ehh0uVLvbHI23Q9BaDoWTEem8ZIBe12/HcH+M7In5e2LBamR/PZTlKi2TenlO1cungH6CATvloiV1SjV9btrRjc/d/rWlJh9Yot15gmrVM9jj0Kuzx0w6KWii+UcTnlJRmMoyVXDNlTRzNqs0IJ2l7Mcx7FuYrqYtlIPg2IEMoEioYFUUu6gjgNhCpUwMlVC5IQwIjiJSlw2tV8e6mZt16Le3ofvspSyrI5UYJxO1NN0n7Rd352irO1bJHnpho3tCJ/DJ1mNwjiHZMiLe0ve9kyzVm+Mw92LvOPxmHENHu3MeVYUb44hIJYr5Oj7eRLa0x1t5Gv3jtv4Racnve5vNH6J+3+tvqw9OmIBTvx8dpj7+b/W9x78M29J7O977cJfu/f7Buo9WfwCTK0Jp";
			//var data:String = "eNrFVE2P0zAQ/S8+h1WcJv26LiCQEELsoj2gVeU6bmLWtaPEYbtUkRAnTvwOrty48WdYfgdjO3GTqluWU1Wpqt+8efM8484WMZlxydAcoQDlqq7g5xathFJlhebvt4jLlG3QPAyQJGvD+/3z8/2PL8DOSlXL9AXjWa4tgTIuuMw6JJqGO/Ay5/RGsgpEsYFviRBXPNU58GI4p1DwggvRJeMW8+eZzQI36rbPm2EP71IN1bl7o7jUg4vgAMH32HLurO1PAMZwbgJPiiwJR8dZ8UHWdEgaH6pnOdeuC/vu2jYjc61df7pmk9SS3PGZTK3XXAlmZEBxVSqpz0tVVVegbWap2UbXpZGUNSBQQJVrIrpzE6AloTf/lTLs1L8NRwPD8UkNjx5jOB4YHp/UcPwYw+OBYXwCw1CoVGr9wGu+//b9z9dffmlcOrV3b19BDP5Ao/iskJkPv7baLurBi4LRWpCyv2oGOsjDe/ktOhDo/fMq10Kky5oBu/NuR3A4Fh2JjY7E4ubafgJUlCqtqd9MK/XyKbCTMAHyigvTMkqWsJj1AsAFrI/NJAo3ySQ8K1INpJRo8txcU5sq0AbA9F3RG5BafmBUW90nGPlJnDvZFlgw6XpEqOYf2c5xoSquuZJm9mZ/wZD6mxCH8bQxE9ekx3KUmePAEkQVJYK1QWyD2OU33h/cvSWMQLNXI/SvfWx2Z95u94kxkrLCBJIk3L817T/aB8cAz7X5CzFJNzgA";
			//var data:String = "eNrdW81u4zYQfhedk4Ac/ojMNW3RAkVRdLfYQ7EwFEuO1SiiIcvdbIMARU899Tn22ltvfZlun6OUZFuSTbmx5ZHQTZDFmhoNqfk43zek6CcvSu/iNPKuPe/Cm5vV0v73yZslxmRL7/qHJy9Ow+jRuyYXXho8FHZ///nLxz9+tdZ3mVml4ZdRfDfPS4NpFCdxerdpAUXqxtfzeHqfRkvrlBbN74IkeROH+dzacfs5tB2+ipNkczNdt20/6/IuOxrzrmmn6ba5vrUwrUb3rYnTvPUg9MKz/8rS5n057J9tI7efny+2RlAaUThsxZ1Wqm0kXf2VNm+rKOyObh1mr3isOj6bYAdhaVR9/DwNy7HOTRJVboqxUybLrqrIlC7K4M1bocxrQFTx8f0iKm6xvldZUvRfjG+WmTS/ycxy+caOtJgZefSYr7JigOnKttjhmuwhSDafny+822B6f9Qt7bj/9+ND6/F5/fgjDJi9ZMC8NWA56oD5SwYsWwOmOxOMAUA5wXRjhlHRmmKkc4rBKFPMdpQZ89CRax9///DPb39tKe115e37776212x6M361SO+2l78pfVdXt42vFtF0lQRZkwhbfrxt887969aWgwYvLCtIvDxbRdZ6M/YSUvc1OHCNHbjGn9+WvxfeIjPharrlzZn56jNrLYhvjWdxUoRsGtxa2cgntnFi+eTRB/IofHK1CHNrFAZ58EXxmHnRiw2Dt4F/A5C5/TGa5qXfS0q9LRSH/RZGkyitAhdM8/inqH6MhVnGeWzSYkIUIaJKtdib+syGxs6DPGiYVSaXujKyzO0tp0ESbZxUTFo5eN4O24ZkbQAgVaOTDsq1T2GDEi2KC0KQ3WBMm3O5E9V1Gm/R4C40uP3riQZzoeHy2wsNQhDQYLoDDYGMhnTlhmzMYcZORMPfR8Pt9zQ0qOCb9JCMnD89mL/TzwsyxD7TeTBhLkzYhIuemAgXJi6/fTFhHAET0Q0JF7iQiJLqd0mL0gnrSVrgIi2n32MgUcyXzard1gJdaJxKWBK4k7DYmQmL7SWHdCWHnKiehMWUKzlcfo9BQiqQ7UmLAIagPu/KDHVmstrDA1x4QH88XPoBfeFwcJWi1hOpf+j5eUt1E5ci2MTlqn1p/9pXuXjr7KUvERjFFh+t9EVaiICPsRDRak9FXpQop5ZctENSNLqkYNXAeqAaWCuEcovTMUtg6oKkrotOVnknJC6/R6m8AHGlGz/7ko+ZOYJ36z9D1v9LqIFau2khsm47gEgNSJgFFpCsM/izIFk6E6JdjFKi+6vGgwmj5MYkJrP4cbCLTOqSEkKbUnJJ633FZtxFHfayfR2Nq2kSwokZcsl7xr2xFpwlZU9HBV2TtjhwCv1mdTPgVPqci6KDfZVQPh8m4rszXYBLveEM6s0d6g191VvJQdWbsU9NvRlDUW8CA6wIqd+tCBp7RYim3QJDu7UYAA8YUaEpbQFizH2UTebGhJPiymmMBQ0k3A6PoirfBcEZ2aqlLZxQpol2cRi8dB+F1ChxchaUhGvTVzQ2Z09VF0Zca0OX3+Mq3kHVRfAOdenc+D2buoCLzGDC+5IZuMjM5fe4tSEdgM1Ud5pwdHHBWqurod5XER9hsW6p6xNcrEsMwberOfwUYWI8wcd7ReJjvCLx5QB4cDbiKxIsDeEEQ0OklZCWlh8uzeDcUj+iugjhWuKL/kt8B5G53fZ5W6IAMF66t/oY8mUJVkFMUQpiZ9YMnDJDV8doGIHCwMjXMOSihRN/rEULVpEshyqSQSAUyZSPVySjHXsEiXLskfjYR4godKzpBcFmLazzwGSQ88AgEQ5FUDbWoQi0o3UC42idHnbjC/ho5+yQDqECGegQqmYK4VCEhPEOobr2WQTpnykUXLzVN1P2v8fAMb7HIDp4i/1fD3NRPoSKaIoABlcjiQjeNj3H2GLRCvmFl+Nw3Yi7Kli8pQehLYZxBpWPxlrChYWwk7ona9VY3FRuj99AaVe5DGRX2E+OOmttANRhl2cOOx/s5K/GEAufAPLij2t/rONCWHUtHaiuVRrju1Vk2C9XvX3+F+4TVkEA";
			//var data:String = "eNrFVD1PwzAQ/S+eI9R8NLRdERIDQogWdUAdQuImFq4dOYnaUkVCTEz8DlY2Nv4M5XdwtpsPo7aUqaoU9e7evXv3nHiFMIsJw2iAkIUSXmTwd4WmlHORocHdChEW4QUadCzEgpnEfX08rd+fAR0LXrDoApM4yRUgxIQSFlcZp9dpkqOEhA8MZ0Bqy/Q8oHRMojwBnAdxBAOHhNKq2d7k6rivukANn7dxfbtON60SqtVdc8JyYxHbQvD0FWapZD9C0oO4tGqQo0C2sx/lbUX1TJC/bZ7CTLQLv9VtbEZyrcafyuwgUiAdnrNIaU04xZpGUnR9PUo7oyiUeYlhZd4cSE+GyxTLFuAuBJXz5Q5A5zqnvqLrt/jsrkHY2UnotAlh4angLD8TPMvGsLp81XK8yAshN2YFZGB/LmYBreLSQvdB+PCvFvMg//bTMfz0Gj+PINg9RLBnCPaPKtg7RLBvCLaPIBgGCc5nOz629evb98tnfaeNNNvtzSXU4Pt2vZOUxXX5SnHr6macLgxTHBY0EO3b0OBCdbrN0WQNgtblkGkbUS4KDOhKvzqG7TVnT83dU/PKifpZKBU8KkJ1eU7KHzjm9r8A";
			//var data:String = "eNrFVLFOwzAQ/ZebI9SkVtR2RUgMCCFa1AF1CIlJrLp25cRqoYqEmJj4DlY2Nn6G8h2cnSatq1LKVEWKcu/evXs+x14AFSkTFHoAHmRS5/i5gHsupcqhd7sAJhI6h17LAxFNDO/r42n5/ozsVEktknPK0qywhJgyzkRaI0GntQYHGYvHguYo6ht4FnE+ZEmRIY9gnGDDPuO8LvZXWBN3bRW6kbNNXtdv4HWpoVburiQThbMQ3wN8h5bzYG0/IkgwLr2GFFiSH+xnkZ2sjksKd/WznFE1hW13qzGDWdZ6PvWwo8SSqvBMJNZrJjk1Mqh4r6QoTpXM8yFqm70s6LzQykgKjQg2kGoS8TouPbiL4vG/StxJ/W04cAyToxpuH2KYOIbDoxomhxgOHcP+EQxjIyXl5Je/efn69v3y2Vwag0rt5voCc3iA2uRkKtImfWm1q2wD9qc01jxSm1eNowMNvFW/Qh2BjZOXVyOEQmmK7Nq73YLduWBPrr0nR8qRfTyYKpno2N5Mo/IHVeLJHgAA";
			//var data:String = "eNrFVLFOwzAQ*ZebI9SkVtR2RUgMCCFa1AF1CIlJrLp25cRqoYqEmJj4DlY2Nn6G8h2cnSatq1LKVEWKcu*evXs#x14AFSkTFHoAHmRS5*i5gHsupcqhd7sAJhI6h17LAxFNDO*r42n5*ozsVEktknPK0qywhJgyzkRaI0GntQYHGYvHguYo6ht4FnE#ZEmRIY9gnGDDPuO8LvZXWBN3bRW6kbNNXtdv4HWpoVburiQThbMQ3wN8h5bzYG0*IkgwLr2GFFiSH#xnkZ2sjksKd*WznFE1hW13qzGDWdZ6PvWwo8SSqvBMJNZrJjk1Mqh4r6QoTpXM8yFqm70s6LzQykgKjQg2kGoS8TouPbiL4vG*StxJ*W04cAyToxpuH2KYOIbDoxomhxgOHcP#EQxjIyXl5Je*efn69v3y2Vwag0rt5voCc3iA2uRkKtImfWm1q2wD9qc01jxSm1eNowMNvFW*Qh2BjZOXVyOEQmmK7Nq73YLduWBPrr0nR8qRfTyYKpno2N5Mo*IHVeLJHgAA";
			//var data:String = "EnRfvlfoWZaq*zEBi9sKvTr2ruGmccfA1af1ciLjRlP25CrQOyQeMjJ4dLy2nN6g8H2CNsATQ1lkvewkCU*EVxS#X14afsKtfhOahMrs5*I5GhSUPCQHD7SajHi6H17laXfndo*R42N5*OZSveKTKNpk0QYWHjGYZKrAi0gNTqyhgyVhGUyO6HT4fNe#zeMriy9GNgddpUo8lVzxwbn3Brw6KBnnxTDV4hwPOvBURIqtHBmq3Wn8H5BZyg0*iKGWlR2gffIsh#XNKz2SJKSkD*wZNfe1Hw13QZgdwDz6pVwWO8ssQVbmjnzRjJK1mQH4R6qOtPxm8YfQM70S6lZqYKGkJqG2KgOs8tOUpBIl4Vg*sTXj*w04CaYtOXPUh2kyoiBdOXOMHXGohCp#eqXJiYxL5jE*EFN69V3Y2vWAG0RT5VOcC3Ia2UrKkTiMFwM1Q2Wd9QC01JXsM1EnOWmnVfw*qH2bJzoxvYoeqMMk7nQ73ylDUwbpRR0Nr8QrFtYykPNO2n5mO*ihvEljhGaa";
			//
			//testLogin();
			
			MaterialLibrary.instance.addEventListener(Event.COMPLETE,onMaterialLibraryLoaded);
			
			var cabinetLib:CabinetLib = CabinetLib.lib;
		}
		
		private var sceneData:String;
		
		private function onMaterialLibraryLoaded(e:Event):void
		{
			trace("-----------------------");
			setWallMaterial(RenderUtils.getDefaultMaterial("wall"));
			setGroundMaterial(RenderUtils.getDefaultMaterial("ground"));
			setCeilingMaterial(RenderUtils.getDefaultMaterial("ceiling"));
			setCabinetTableMaterial(RenderUtils.getDefaultMaterial("table"));
			setCabinetDoorMaterial(null,RenderUtils.getDefaultMaterial("cabinetDoor"),"all");
			setCabinetBodyMaterial(RenderUtils.getDefaultMaterial('cabinetBody'));
			
			GlobalEvent.event.dispatchMaterialLibCompleteEvent();
			
			if(sceneData)
			{
				_setSceneData(sceneData);
				//sceneData = null;
			}
		}
		
		/**
		 * 创建房间，创建之前会自动清空场景
		 * @param width：房间宽度（mm）
		 * @param depth：房间进深（mm）
		 * @param height：房间高度（2800mm）
		 * @param wallWidth：墙体宽度（默认240mm）
		 * @param windowSillHeight：窗台高度（默认910mm）
		 * @param doorSillHeight：门槛高度（默认10mm）
		 * 
		 */
		public function createRoom(width:int=3000,depth:int=3000,height:int=2800,wallWidth:int=240,windowSillHeight:int=910,doorSillHeight:int=10):void
		{
			this.clearScene();
			
			var floor:Floor = new Floor();
			floor.doorSillHeight = doorSillHeight;
			floor.ceilingHeight = height;
			floor.wallWidth = wallWidth;
			scene2d.createFloor(floor);
			
			//trace(Scene2D.sceneWidth,Scene2D.sceneHeight);
			//var ww:Number = wallWidth * 0.5;
			var x:Number = (Scene2D.sceneWidthSize - width - wallWidth)/2;
			var y:Number = (Scene2D.sceneHeightSize - depth - wallWidth)/2;
			//trace("createRoom:"+x,y,width,depth);
			
			x = Base2D.sizeToScreen(x);
			y = Base2D.sizeToScreen(y);//Scene2D.sceneHeight - 
			
			var w:Number = Base2D.sizeToScreen(width + wallWidth);
			var h:Number = Base2D.sizeToScreen(depth + wallWidth);
			//trace("createRoom:"+x,y,w,h);
			
			sceneCtr.createRoom(x,y,w,h);
			
			if(currWallMaterial)this.setWallMaterial(currWallMaterial);
			if(currGroundMaterial)this.setGroundMaterial(currGroundMaterial);
			if(currCeilingMaterial)this.setCeilingMaterial(currCeilingMaterial);
			
			//this.fitScreen(true);
			
			scene2d.house.currFloor.wallAreaSelector.scene = scene2d;
		}
		
		/**
		 * 是否锁定房间，锁定房间后，将禁止编辑房间
		 * @param value
		 */
		public function lockRoom(value:Boolean):void
		{
			WallController.getInstance().dragEnable = !value;
		}
		
		private function initStage():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, on2DSceneKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, on2DSceneKeyUp);
			stage.addEventListener(Event.RESIZE,onStageResize);
			//onStageResize();
			//stage.addEventListener(MouseEvent.RIGHT_CLICK,onRightClick);
			//sceneData = "EnRTxE1V3eGz*1*8oDUBv9VtBXaoonRsQc0Ql6OSz9Djtdz2Tc9T2IOsijdGdSejbaJucJGHENYbNVGaqNd9z5Q0918W45F12dU7gw*ITzootUQTX7pJ2EF5Zw9#88ZJYvmRIhBdklcUw9AgTrDpX*ZJu2TNgmEJSxx9E0#TmbOer9z1Sgff*OgO9*RFpZJ57eE89U4ONKAdRWFH7T4KQDapWMey7EyLYavf4B29Sl8FbwpEkbtfJ*ZH8h44MoZXA8QVb*YbD8pHmp8YZmPM1YZ5fU9n*eIUX#cSUpIQQjR2BISoO0NPH8anI**ReKq3RmDjT5*WqKGDERWXQ4sssKNPKLPewuS0lvwYvC9l6JXiRvdTxwzMs*YSWJ65SF1buIM9Fd8Ajh3DI4EbAiA3UdokO8NMkb6p7*o2Hs8p*eKWcN3#2tR55pDFpp*eTO43Rg2*V7#OMNvCnSxzpukLhPfME4r1EKrkpBklhJ1nFqzsD6tOszPialzxGTUKak0RlH8FbUiR3p7tuDQTjN4F0FL9DUN3WsySZLSAXFhbaNYE*olt05##MThalEKjZ16##DnVOtuB#*k9V*ZT7yEFNt5*zvSL9i*tx2vnrToa38MFLLHfFq8TUyEx3cphd5l*Eo*8BC58K3V#9JaHVyN4KpzN4eE7471PwocfcJXWWdceGwI9vjH8YKOzDUvcBStTEdqirNLtXx3azL9kpI8Pvt51HA4iKmX#e3crND0MYjK9e2cYRbqWb89kzY0KPqiW*IcCCHTI*UbXShSqrhWWUCw4iRW8r9K3uYdDUGebtKBsyorZH4Y2rVfG2P8iL4trtVZbv3GLIhGDJUXq9d#V6iLs7XTFVOVUEBDVBR6paBT2ojJWEGn*4N81hVeNcF8hr6iS3V5#0j8KRtNwdmzE#AfEDSClONt8#F1j#dcquds#gFF35EVBQxFZGODH8aGpYTDixo*4W7eOoiZh4ssmi*h7eImsNhRjjFK0G4ql#EcB#flfTblnkOKk476FiJCDMi#tF58KW8y6IaFbCdmEXQpKM8NLhvwdrxozGBJjSWQiacJxMBgrW1dHuIOWmaGoXq1cQtdjb7TrpaPUj#0vLKJPuXI1l5poWRhpozelKwMGXamgSmcdQowjiU9RwXbd8f2OHWpijcbiJ2ObbClNjrqWfY8eaxlwcak4caqqsYaabqBWHweahsCGoeY9KK9egqr6eGcQRQ64UFbYnTOx#JD3J76d82*mpjX*48dFdDdGw3DU8Jj*pa4M4*EsSVFcFHX5yNy5dkjRH9gUIHnCf5sej1NmcncTdWAUp6gn4CQ8qeUYgcWquyN#Z1eHpP#bIMVB8rgQqW8YgPaUgLcbbJhK24Fce5*Bp1YabeIa7a8XPs8cqO*vbWk0hukOy69mdKWlcqG0cavuGyilAigftor5VncZatHcxpOFuqFOtrc4WmPM2LbZm0n2pqCawGkaA#nZa2dEJyXqjCFBjsDcwdIruPut8XfqM#z5H6FB2EYBTLzHE6jY6KH0ZbnHaO*F9YHZJHZOhefBZ7UifU49*EoZl373QBz3c3i458tpRQwwD6h48eqyLI3YR553ZZaKTcvdPGBKy83JXBxTj82RAZdC4df*qHJDcq6hFJ*ifG*c91Tdp9R3KVxMDdYjd6tL5Q3nw98bcxiQzQ8A9bZ2RTkPBwoKq6CLZSlakBYY50EdyEdXmS9N0muEyfGt0E17joS8MRC5yIadU02DLmWU0pj8RyizyfQwF1cYpBgD5DrIo8NqGnITWs12H7GfRi9Chdw5RgbbWY6gxvzJf9aYUtXOsO6s1UxOlkq42Xe5*8j0tO4Y2QyAHtPQfcP8oGX28HKdxK4XsMDJAh1YLeMwtcYytbJmQfeZxZq6x*q6k0CDzYM3ojDuJuRKSJ49YHWLUXG5AUHLFFtslt1kKuk78mjeJZQOHHYvfmVYDTyRuDKAjcQKoHQvw6e1IqPTEyD0lfHIgd4rM#B8HSFfS*SL2exMQ3Gt58KoBJzHWiSBrQa2CYfhYKi4tkHytcI8ojLqMkS9NuG7ZYCVF3J6*fwBK4RhAS0Nmcm2b4clD0QTwAxmBd2SUWDyLKnVF*lQ9oD*RVOGP7rTF2DNgcZDgvZDjxngf9358r9M3tMd2WbZlZrtHbVFCrcKk24hvLIXr8xUOiOy3yixyBp7WIzX6j1mhjl1dLsSP3IHX#RQhvEHD5tTRhEhEc5zPaNbu8N5wldp36BGiFjav#4qy4#qEJeLAzzEZ5P5#rtD*T4XvM*V1lESwu6B5xsD3r1iUXMSG3J5rSakiWn0H3ssVLrC4BAXsycvytXdo4z2gO7IDyH3kOTDORVyzzD0StSNBdU22Q1i4TjQL7wZ2U1r7zX4CfLdilJtOgcDI4d0hg1msfX88UWL98pPrX#*FFgR15#*EppF553bX#k4jj90SOJidbYeDyKXkkbY*3Q2cifK8kal1ThqBHyERJy88kwDshjCDhqIYwgHia3AcMDqQOQz0rvIzPaOGMA0*Abz5BwkjjH64E9vqeHAdjPPVvzX8EVxlIsYewlwQgAnATAOBA9rMBA2OjDxw7JAe8KQ722FD0U2paw1SuHfCXTYuluHb*NiRcSUBnwoNkQHLSufBejCKaxIaNDgxgcfO7F98t7*h7*NiBBYBTZPrZ9784#*V*mBCOHkOIoZBjkqrhfT6XRzywrhdDNb6sDxhr1lCo0LSu092EfCgDKbUYu7YglzGDUrhrac6yYqFHZVbYnVl44hiHKwEzVFVT9dTTVB0MrlorNORlzAuH8WJ2uX7kklpdvK9Boegc73RfaTlPooe3kPkX0x4L6KAMKOfX6btIBdv6uOO00ChWjiI8NWoKQuw0essVhdipjeKxFJ*L1Ka#8gWcyv3Qtcx6vuEkH9oHQcv0qdlEo2fIrqHrxB2aPUlVkc0kwiVkrhPf70DiDn4muexKZGXqrEtocLiJQ0x8bdrkyuKwsujHYD*oUVRZ9*Ozcb3uS1iQYCAUqk8UMq*RcZTByQ14ISkDMOkKb6udTRfv2vhCfLj3A2iuTz52rPd2QNRAk5n3C7WXvNOklgoA4DqivtGakQmufrW#fAC8l7o3lcE4KkBo2Tg3HjMCb1MpBRUI0KO2k7zskys1cg2PHaBe5vFVYHujw**oFLujxZwZCqqRTlkEX8nuxlpEWriaLlSlySDVghzmsXnLVfx4FaOlWGSze9hWFHHz6BHAKW1J0ixRg9O26O7B2#zL7*N3E7Tho3YoCyR*KeabUDCzaZ8Ndn4iZBGwrMKiE38UGwXK2*54*u7*NxT58jBPNGvP3GvODoZEmTd*2hGts*ilAb4qzg1Bcx9HT2wbOoQts5zg*yctuYj1baL1AYzkK#OxHDCs#LpnNaUiOD7DFVmfjJ5#q*V#KsDNI*xV*V17RATUpqKvy*mNlGwrPNdCIXOuRBWLw0lvzOw9HjBqSWAccrhRwSBBw2DjfIs3D6ojMoOKZCiUG5xjXHUPk4BFUKgxDjBG0eA9k9IeQb6mY46A4URw1Bi3Yn8k0HFdfZm7J3mabDoUgQcElP9RL6oFfGAOJhei8HNLBx3iOfTW0uCt5E6jg60HCPJNrvn7tMi12D9yr10rlPs65YwnFPZL*Nm0fDm8wyOg5lcyV6FZuCx5w3jfc3eO9W514uTvuhXTVsqE*68SjrrDzudA1zxUd1YaVOlPyxRdpYaQgZfRJiC01K7zWlxhVbaTEUBvUJpOZ6Qke#coLSzk0b4Jgrnum8HNGm8CWVFb4C*X8JX*Ws";
			//sceneData = "EnRTxvUp3eGv*I9#NS7wVCP5G2gbjCLULaqfGsll0#2zADjJJ*QstbjfwHbiBbAHfqGqkbgWqUZYaSKtclhKZ2qM2x9bLs*Ts5D77j5U252uvSQ2Y#vY#zYVZQ3oQxLKEF7b0pESY5A1yX0gS4N8#CJAhWxbEgjD*TeJA#GpVbpRmTIXFpDi9xV1749px*Xu9J4ybZn*8f1VEha4dtV0VEfO6b8KluIaTphw4Bb*1*CMCLcOMU#7O9hT4wb6kk#PVb7if94CJKBjWZbUM1*B4vnYnSh9Bd8BZPVtr1xxAhBxG6e*Zx2iVwpjFWvbDmD6ee77OxWeuK4F78W7Qufp4UzL3zc2MXO824VOxHL2UHmriJDboQE0PB4SjvfcB3CqFKv0#B4*Ikz7giW8ny4CCN8C#npDCtcz3jAdk34EUvnVphtLB#V08Z98*EXZzJ3ESFBC*T2YBTBJZbEWkLocid8NTnK58uPZqVK5KxroJYlo4yGNeyRcqukGhEzGn03bk9tLG2nppqj3RnK4MTGMVLbu#Kks#0j7e0sxi42d4cIhuJsF3oMVVJZ7XCU5plIwECpt56***dTOZyva9T5F**7MYyUZzY#zLvSdK#IZRoL45SK7YzOiYAk*X5BC40VUICD3WV*K7nW9kqkNT9Y9usJ9PUPhnj#b6X9mdMFdfdbuaEkbGGKgAVrCy*GRBRurZJzkiU4f44e3tOzk7Wn7*Ld4E0MR9Q0Rtewbjp0MGNGYejKpng8uIkxZ4hHjO3PCGCuDdgEsFUQLe#*GYpoNizQtruvKE4kWdYmqxBScaqMx0wdSsMAmR4#dWAW*vEWy#VVbb9#sNsacwpjVF6JMNNr0vkVZVw*ErlECJ67UVO#bFEL4mjx9bU7u*xyWLM9sVpDovfUW92oVpW1hO7y1X7ctF6St33e8p1P9BN86VoDLids5gVtVzQ8*ILIBnnWBEVFXih#n1pw#o5QOHUnGmPWoa199yeHUfpnnKeG*2eqXvs68QzVPf*vbpoQJoKZ6BOrAnuRe5eHxYxThWCaB7qAJybW#gv7E0a2ydHCtsji87OaOGDK#C1heBzsYLckPiWBESBPbkfuu#Edad8BEr#f4kseI2ALO2S8kNnk1lqwITezMNHypgmaud6QxO5QC71YhgiiFWMO4icsdG8YRMGEblxaEaYeQYKbasxmGGjYvGadIdaHaIGg8nGZqXYeiJIoUjeOOHKapGrqbrv7N#yX5YUD4UzDYogfqDryNt8X5NdXX5b54Apd9g1DLMZUzEnpjE2hBE8n#4dTkTXX7*QvJ*0aNfaJiSKByOHqnpBS#gQqjcHMgkWSgo2CBGXitkVqceLIO3#Fa4TjECilQYiCChgbLoiGudMRvT4#fH67KWlaecGajKpneslLKGki#fIdJHfdovHuqGLycaWiBramTOeeaMQiHnViC2EGWae4qHoceCLbnsEcmSBaBJBq59rbFf7vdyStnFDgli2cbJ5i6wJNpCKYemguIPtOMjKUGTQIx853TXrO4gQ0G8qNumhxK7u8Dfs5W5g2h2VYeq34cwtxMiPOY9#Xpt7*#*zEvEzSkHWVQFMQdsXhPbvq*hIRk2Mx8RCBDCYGj7qWLqWRkTEBi1TOeHfBwvD005qyp5bUg*G3VEot2VDIbumY*pNl9U07OB84M0#aO425E2732iqbSKE5fEL6a3evXYHHgvCrPtMzHWfoMhlR#yoq5SS1XBsIWa2XCeDlTCYsEpfQKEq*nWC4OJ0YBnzkEaiHTyfCI*z0C8qNNs2ul5#hsGfJuec6Su8ifncDDUfA6Rebci16mEfLrVicwPuTEVVbS*cQrl7lrirsCQggRg6qeTg6qPRhgMmR04U7POPDP23QlLnbSMb7BM7fiwrwlnfZ4bA6o1CrITqgyq0HDTDebM9rU3cjLguPgfaYvbLUbGezPgkvrq2KGsgo0q4X4P7qgHxbrVSHgYqnWWLeDPzfzfmShAJAYqrUiBebyeTRa2DcgPej7Kq2S4FoEo7KR*YFVoAIMv54jwz19#SNRF*6JttNO2b3ql4HM7k#ySKRbYpBA1dx6XEIxgVOfePl4jb1ZsNOivD0ZisHNLl75#CUZx*7L7nNlhlLtYBw*p*kw7QsStV0fSkVP*oYp8#MCO2haKP20vFzvjFq5LYBeQRSNED3uc3FwDoPjPnOjBNBVre4Pa4T#enZ1XS5HeaWCDCFz*ChThMkID72I4yeZHSD5yZxRXalerCrzsTzOF6XL111qNj9AARuio7pXlJ3VZkAAwkFvKGEfsBH4rXiUCV4h0UY4YCzWg7wE*0e1*OD2OizLagZcaEfv9LBBDedKz2FS4#cE5ZUQYBLY#YzIWlKcCbDn4WiZCziukwkxaQ7pZGk1tvVemXq9dM310ohGonWgSCuQ3TZP858uJA42VlNQdGEmtv8oWpQzuSVTkjQ#UllPY7Bu9f0qBL2ZFxM57CVASx3xghdJNqY4quaAuhJsLdirnXnXmXe3e3eZeBE82ueQMX1IA80o0MMZO6cCUHbYOXdRZi4Oo6sE2whRZa7Dqa2Bhui0yhyqwIfJPfwZG4jfrG*g7N1VRfGu5tRW1CYoj1#DVVIKA2Bh3p#leRoASdSyYLukkTkgDGDdTCLR7a5JD9tjjee4HNUpGI4Ln1o4roRa#SScDeRSHnmPKtSmgRLJ5i6roY3jhBre7KtlaTmAYWj2s#7aCRKJxAdg5a4UKtU4pOgn3dfYzZVLtJhoqQVgwsJy2JHlWAFUwPWL743N4IW5H7Y5oeSpSCQWGnUA8iy6hx0tNDVZ6YfEgrqlwzcAdFKUGKiWuJN81OAOGdLq8bqtua8jIJAncveze5KeX9oNZYuFZJ797m0xV371VY9E**Dzz4rgEyAgTexIvlI5Xcb2L8bbaC3oR8FuIvmXpSOcU5bTgb92zxYqRBuV7g7V49bYvDkoEugP5Hab2EJyDBnhQc5DuJTqQ3w*4vBF2GT*ist6BrY7IEYrsNw*UV267eK0KEU9BsFrenlcstryE1zeFqkA2iwjxDq6kMjE9TV#stsf4awUFliH3D7CvfTu1IsRhhP64BOSuMPC2m34QwXJXrIuD7myO2bDQbQD9rSxNlryI1hfUiaSw2O1uqTQnhYOJJUwn1tDNpGgnnuyPHRJBARgWjupB6xIlDf4Y6rBgWQpK7ydS0wfzW59FYCpFC*LXtjDxIXZrf2tHWfDxQXUOhznhRabK0EYvg*YIm7euWa65XW15odvk3kAcAz0UXWhzTptSGES1AESIBsyseUDAPYUhVKl0FiG7GORa3rh6oIYyNKBr40JBydxIb0JDJyB4o2s3cM6U5xp3wlWBxf3qAFC3yjnNhn3rtVUBG9xRG1L#c1bXBkdO9TarF7i6tzsfHDrutMtLzeTZu6RC5X4b1drFhPAerrmfXDHMxagXLxJiPPee*1adCDfyplhlnD6nT8IB1N893T1b#2vHuCWBRHQggNQ92Bh09NyJ30vbb1U16V1en1XvCssNyP5*r7gMZ6VjcnOy#jg55xq2Rq1ROPXvwQ4kTGwsr0nbP0Q4nUe4oL2ydyrpjGAWwmeJXe8dCzi5mGJ915YjRbAjyZTmf6mNvqU4wkz5lJtZ55Sx2wgnhLX0qIgRfo1grWvJTdUezcPZSbnvwEOpYUVuQwY4ke7Zc6cP3kPf#n68jZ#57DDaO#C16UVFLmroX0R#LRetSAZZKihNUD6nqkDYHvHljUIfieMbndPV*4Mru9NyJll5a6Zf#qo6fjiHHs99PZyiAczQJcMb08boqZPGJvOLwcn5Na3*uaTjBgKEaeCRd#rrBqCQ6MuYSkx7YRZ#HUFOV3kidZFs4mnEuvM39J4rk3Vg3Frjri7gQ#i6rlOzknd6UOyRKMu1a*uVO7bg9aXejuRgFiwkXLULiXrmKBjViTkPRc1ZhvBY#Nra9u1cDrTlESgALUt2gqdIGtbCKvID0ArihtEbG9YHnLzVUagdYVz4gg1AwV0JneZnFqmiz3DwD6a4de7Y0BWgmfJbm85fI7qXEpbcVf4JNsXKI7g4WxBHivRB0m8NP1twSOUfjdVOifRnX1emzwLrSM0xvNAkDT2*DhzBLU23arUJCGXGDU2I0OR*0vRHHysLmkdQ7CMquMDuj0*SLQOGVyojsGXg5EEwu1Oy#LjeIp*b8ZmsDKa";
			createRoom(4050,2920,3000,200);fitScreen(false);
		}
		
		/*private function onRightClick(e:MouseEvent):void
		{
			trace("_____onRightClick");
		}*/
		
		private function initStage2():void
		{
			stage.addEventListener(KeyboardEvent.KEY_DOWN, on2DSceneKeyDown2);
			stage.addEventListener(KeyboardEvent.KEY_UP, on2DSceneKeyUp);
			//stage.addEventListener(MouseEvent.RIGHT_CLICK,onRightClick);
		}
		
		private var actionHistory:ActionHistory = ActionHistory.getInstance();
		
		private function on2DSceneKeyDown2(e:KeyboardEvent):void
		{
			//trace("on2DSceneKeyDown2:"+e.keyCode);
			switch(e.keyCode)
			{
				case Keyboard.V:
					cabinetCreator.switchCabinetTableVisible();
					break;
				
				/*case Keyboard.M:
					switchView();
					break;*/
				
				case Keyboard.Z:
//					if(e.shiftKey && e.altKey)
						actionHistory.undo();
					break;
				
				case Keyboard.Y:
//					if(e.shiftKey && e.altKey)
						actionHistory.redo();
					break;
				
				case Keyboard.U:
//					if(e.shiftKey && e.altKey)
						switchView2D();
					break;
				
				case Keyboard.DELETE:
					/*RoomControler.deleteRoom();
					WallControler.deleteWall();
					WinDoorControler.deleteWindoor();
					ModelControler.deleteModel();*/
					wallCtr.deleteCurrentWall();
					if(e.ctrlKey)
					{
						//cabinetCtr.deleteAllProduct();
						deleteAllProduct();
					}
					else
					{
						//cabinetCtr.deleteProduct();
						deleteSelectProduct();
					}
					break;
				
			}
		}
		
		private function switchView2D():void
		{
			//trace(container2d.x,container2d.y);
			wallFaceContainer.visible = wallFaceViewer.update();
			
			scene2d.visible = !wallFaceContainer.visible;
		}
		
		private function onStageResize(event:Event=null):void
		{
			var w:int = stage.stageWidth;
			var h:int = stage.stageHeight;
			updateView(w,h);
			fitScreen(false);
		}
		
		//=========================================================================================================================
		
		/**
		 * 使内容适应屏幕，并可纠正内容在屏幕中的位置
		 * @param isTween 指示内容适应屏幕时，是否使用缓动
		 * @param space 适应屏幕后空白区域大小，有效范围[0-1]
		 * @param dx 内容适应屏幕时,x位标的偏移量，负值向左偏移，正值向右偏移
		 * @param dy 内容适应屏幕时,y位标的偏移量，负值向上偏移，正值向下偏移
		 * 
		 */
		public function fitScreen(isTween:Boolean,space:Number=0.5,dx:int=0,dy:int=0):void
		{
			sceneCtr.fitScreen(isTween,space,dx,dy);
		}
		
		/**
		 * 设置背景网格的显示属性
		 */
		public function setBackGridVisible(value:Boolean):void
		{
			scene2d.backGrid.visible = value;
		}
		
		/**
		 * 设置背景透明度
		 */
		public function setBackGroundAlpha(value:Number):void
		{
			BackGrid2D.backgroundAlpha = value;
			sceneCtr.updateBackGridView();
		}
		
		/**
		 * 设置背景网格线的透明度
		 */
		public function setBackGridAlpha(value:Number):void
		{
			BackGrid2D.backGridAlpha = value;
			sceneCtr.updateBackGridView();
		}
		
		/**
		 * 设置标注线及文本的颜色
		 */
		public function setSizeMarkColor(value:uint):void
		{
			if(SizeMarking2D.lineColor != value)
			{
				SizeMarking2D.lineColor = value;
				scene2d.render();
			}
		}
		
		/**
		 * 设置背景网格的显示属性
		 */
		public function setSizeMarkingVisible(value:Boolean):void
		{
			scene2d.house.currFloor.sizeMarkingContainer.visible = value;
		}
		
		//=========================================================================================================================
		/**
		 * 更新视图尺寸
		 * @param w
		 * @param h
		 * 
		 */
		public function updateView(width:int,height:int):void
		{
			//trace("updateView:"+width+"x"+height);
			updateMask(width,height);
			
			ruler.y = height - ruler.height - 20;
			
			sceneCtr.updateView(width,height);
			scene3d.updateView(width,height);
			
			//this.fitScreen(false);
		}
		
		private function updateMask(w:int,h:int):void
		{
			//trace("masker:"+masker);
			var gra:Graphics = this.masker.graphics;
			gra.clear();
			gra.beginFill(0);
			gra.drawRect(0,0,w,h);
			gra.endFill();
		}
		
		//=========================================================================================================================
		/*public function setRoomGroundTexture(url:String):void
		{
			var rooms:Vector.<Room2D> = scene2d.house.currFloor.rooms;
			for each(var room:Room2D in rooms)
			{
				room.loadGroundImage(url);
			}
			
			if(scene3d.visible)
			{
				scene3d.house3d.updateRoomGroundTexture(url);
			}
		}*/
		
		/**
		 * 设置地板材质名称
		 * @param matName：材质名称
		 */
		public function setGroundMaterial(matName:String):void
		{
//			sceneCtr.setGroundMaterial(matName);
			currGroundMaterial = matName;
			if(house.currRoom)house.currRoom.groundMaterialName = matName;
		}
		
		/**
		 * 设置天花板材质名称
		 * @param matName：材质名称
		 */
		public function setCeilingMaterial(matName:String):void
		{
//			sceneCtr.setCeilingMaterial(matName);
			currCeilingMaterial = matName;
			if(house.currRoom)house.currRoom.ceilingMaterialName = matName;
		}
		
		private var currGroundMaterial:String;
		
		private var currCeilingMaterial:String;
		
		private var currWallMaterial:String;
		
		/**
		 * 设置墙面材质名称
		 * @param matName：材质名称
		 */
		public function setWallMaterial(matName:String):void
		{
			trace("---------setWallMaterial:"+currWallMaterial);
			
			currWallMaterial = matName;
			cabinetCtr.setRoomPillarMaterial(matName);
			
			if(!house.currRoom)return;
			
			var walls:Vector.<CrossWall> = house.currRoom.walls;
			for each(var cw:CrossWall in walls)
			{
				cw.materialName = matName;
			}
		}
		
		/**
		 * 设置厨柜门材质
		 * @param cabinet：当前要设置材质的厨柜
		 * @param matName：材质名称
		 * @param mode：设置模式["all","group","cabinet","own"]
		 * all模式为当前场景中所有的厨柜门设置同一材质
		 * group模式按组设置材质，场景中吊柜为一组，地柜为一组，此模式时为当前厨柜所在组的柜门设置为同一材质
		 * cabinet模式只为当前厨柜的所有门设置材质（一个厨柜可能有一个至三个门，包括抽屉）
		 * own模式只为当前点击的厨柜门设置材质
		 */
		public function setCabinetDoorMaterial(doorModel:ModelObject,matName:String,mode:String="all"):void
		{
			if(mode=="own")
			{
				//cabinetCreator.setCabinetDoorMaterial(cabinet,matName,true);
				cabinetCreator.setDoorMaterial(doorModel.parentProductObject,matName);
			}
			else if(mode=="all")
			{
				cabinetCreator.cabinetDoorDefaultMaterial = matName;
			}
			else
			{
				var cabinet:ProductObject = scene3d.engineManager.getRootProduct(doorModel);
				if(mode=="cabinet")
				{
					cabinetCreator.setCabinetDoorsMaterial(cabinet,matName);
				}
				else if(mode=="group")
				{
					if(cabinet.position.y<1000)//地柜
					{
						cabinetCreator.setGroundCabinetDoorMaterial(matName);
					}
					else//吊柜
					{
						cabinetCreator.setWallCabinetDoorMaterial(matName);
					}
				}
			}
			
			scene3d.engineManager.updateCubeReflection(3000);
		}
		
		/**
		 * 设置台面材质
		 * @param matName：材质名称
		 */
		public function setCabinetTableMaterial(matName:String):void
		{
			cabinetCreator.cabinetTableDefaultMaterial = matName;
		}
		
		/**
		 * 设置所有厨柜体的材质
		 * @param matName：材质名称
		 */
		public function setCabinetBodyMaterial(matName:String):void
		{
			cabinetCreator.cabinetBodyDefaultMaterial = matName;
		}
		
		/*public function setWallTexture(url:String):void
		{
			scene3d.house3d.updateWallTexture(url);
		}*/
		
		
		//=========================================================================================================================
		
		/**
		 * 在2D和3D视图之间切换，当前为2D视图时，返回true，为3D视图时，返回false
		 * @return 
		 * 
		 */
		public function switchView():Boolean
		{
			this.container2d.visible = !this.container2d.visible;
			this.scene3d.visible = !this.container2d.visible;
			//var house:House = this.scene2d.house.vo;
			
			//var house:House = House.getInstance();
			if(this.scene3d.visible)
			{
				house.updateBounds();
				
				this.scene3d.updateHouse(house);
				
				cabinetCreator.updateTableMeshsPos(house.x,house.z);
			}
			
			return this.container2d.visible;
		}
		
		//==========================================================================
		/**
		 * 是否锁定厨柜及水盆烟机灶台电器
		 * @param value
		 */
		public function lockCabinetObject(value:Boolean):void
		{
			cabinetCtr.lockCabinetObject(value);
		}
		
		/**
		 * 清除所有厨柜及水盆烟机灶台电器
		 */
		public function clearAllCabinetObject():void
		{
			trace("------------clearAllCabinetObject");
			cabinetCtr.clearAllCabinetObject();
			this.cabinetCreator.clear();
			
			ProductManager.own.clearRootProductObject();
		}
		
		/**
		 * 创建橱柜
		 * @param infoID
		 * @param fileURL
		 * @param yPos
		 * 
		 */
		public function createCabinet(infoID:int,fileURL:String,yPos:uint,name:String,width:int,depth:int=100):ProductObject
		{
			//CustomizeProduct2D.distToWall = yPos>0?0:50;
			scene3d.engineManager.autoDrag = scene3d.visible;//在3D场景时，可拖动产品
			var p2d:Product2D = cabinetCtr.createCabinet(infoID,fileURL,"text",null,-1,yPos,name,container2d.visible,width,depth);
			return p2d.vo;
		}
		
		/**
		 * 创建横向管道
		 * @param diameter：直径，单位mm
		 * @param length：管长度，单位mm
		 * @param color：颜色
		 * @param yPos：管下沿至地面高度
		 * @param zPos：管吸附到墙体时，与墙体的间距
		 */
		public function createHorizontalTube(diameter:uint,length:uint,color:uint,yPos:uint,zPos:uint):void
		{
			cabinetCtr.createHorizontalTube(diameter,length,color,yPos,zPos);
		}
		
		/**
		 * 创建与房间齐高的圆管（圆柱）
		 * @param diameter：直径，单位mm
		 * @param color：颜色
		 * @param zPos：管吸附到墙体时，与墙体的间距
		 */
		public function createRoomCircularColumn(diameter:uint,color:uint,zPos:uint=0):void
		{
			cabinetCtr.createRoomCircularColumn(diameter,color,zPos);
		}
		
		/**
		 * 创建竖管道
		 * @param pName：名称
		 * @param diameter：直径，单位mm
		 * @param height：管高度，单位mm
		 * @param color：颜色
		 * @param yPos：管底至地面高度
		 * @param zPos：管吸附到墙体时，与墙体的间距
		 */
		public function createCircularColumn(pName:String,diameter:uint,height:uint,color:uint,yPos:uint,zPos:uint):void
		{
			cabinetCtr.createCircularColumn(pName,diameter,height,color,yPos,zPos);
		}
		
		/**
		 * 创建水盆定位标志
		 */
		public function createDrainerFlag():void
		{
			cabinetCtr.createDrainerFlag();
		}
		
		/**
		 * 创建灶台定位标志
		 */
		public function createFlueFlag():void
		{
			cabinetCtr.createFlueFlag();
		}
		
		/**
		 * 创建与房间齐高的方柱（烟道）
		 * @param width：柱子宽度，单位mm
		 * @param depth：柱子进深，单位mm
		 * @param color：颜色
		 * @param zPos：柱子吸附到墙体时，与墙体的间距
		 */
		public function createRoomSquarePillar(width:uint,depth:uint,color:uint,zPos:uint=0):void
		{
			cabinetCtr.createRoomSquarePillar(width,depth,color,zPos);
		}
		
		/**
		 * 创建方形物体
		 * @param pName：名称
		 * @param width：物体宽度，单位mm
		 * @param height：物体高度，单位mm
		 * @param depth：物体进深，单位mm
		 * @param color：颜色
		 * @param yPos：物体底面至地面高度
		 * @param zPos：物体吸附到墙体时，与墙体的间距
		 */
		public function createSquareObject(pName:String,width:int,height:int,depth:int,color:uint,yPos:uint,zPos:uint):void
		{
			cabinetCtr.createSquareObject(pName,width,height,depth,color,yPos,zPos);
		}
		
		/**
		 * 清除所有障碍物
		 */
		public function clearAllObstacle():void
		{
			cabinetCtr.clearAllObstacle();
		}
		
		/**
		 * 是否锁定所有障碍物，锁定后将不能编辑障碍物
		 * @param value
		 */
		public function lockObstacle(value:Boolean):void
		{
			cabinetCtr.lockObstacle(value);
		}
		
		/**
		 * 是否锁定定位标志
		 * @param value
		 */
		public function lockLocationFlag(value:Boolean):void
		{
			cabinetCtr.lockLocationFlag(value);
		}
		
		/**
		 * 清除定位标志
		 */
		public function clearLocationFlag():void
		{
			cabinetCtr.clearLocationFlag();
			scene2d.house.currFloor.wallAreaSelector.clearCabinetFlag();
		}
		
		/**
		 * 创建450中高柜
		 */
		public function createMiddle450Flag():void
		{
			var po:ProductObject = cabinetCtr.createMiddle450Flag();
			this.cabinetCreator.addCabinet(po);
		}
		
		/**
		 * 创建600中高柜
		 */
		public function createMiddle600Flag():void
		{
			var po:ProductObject = cabinetCtr.createMiddle600Flag();
			this.cabinetCreator.addCabinet(po);
		}
		
		/**
		 * 创建600高柜
		 */
		public function createHeight600Flag():void
		{
			var po:ProductObject = cabinetCtr.createHeight600Flag();
			this.cabinetCreator.addCabinet(po);
		}
		
		/**
		 * 设置物体位置
		 * @param po：物体对象
		 * @param xPos：在墙面上新位置
		 * @param yPos：物体的新高度
		 * @param zPos：离墙的距离
		 */
		public function setObjectPosition(po:ProductObject,xPos:int,yPos:int,zPos:Number):void
		{
			cabinetCtr.setObjectPosition(po,xPos,yPos,zPos);
		}

		/**
		 * 创建窗户
		 * @param width：窗户宽度，单位mm
		 * @param height：窗户高度，单位mm
		 */
		public function createWindow(width:int,height:int):void
		{
			var f:Floor = scene2d.house.currFloor.vo;
			windCtr.createWindoor(201,width,height,f.windowSillHeight);
		}
		
		/**
		 * 创建门
		 * @param width：门宽度，单位mm
		 * @param height：门高度，单位mm
		 * @param isOpen：是否为开放式
		 * 
		 */
		public function createDoor(width:int,height:int,isOpen:Boolean=false):void
		{
			var f:Floor = scene2d.house.currFloor.vo;
			var type:int = isOpen?0:101;
			windCtr.createWindoor(type,width,height,f.doorSillHeight);
		}
		
		/**
		 * 设置门窗属性
		 * @param vo：门窗所在的墙洞对象
		 * @param width：新宽度，单位mm
		 * @param height：新宽度，单位mm
		 * @param xPox：门窗在墙体上的位置，单位mm，两墙交点为起点，按顺时针方向计算位置
		 * @return：设置成功返回true，失败返回false，失败的原因，是门窗的新位置或新尺寸超出可用空间的容许
		 * 
		 */
		public function setWindoor(vo:WallHole,width:uint,height:uint,xPos:uint):Boolean
		{
			return windCtr.setWindoor(vo,width,height,xPos);
		}
		
		/**
		 * 清除场景中的所有门窗
		 */
		public function clearAllWindoor():void
		{
			windCtr.clearAllWindoor();
		}
		
		/**
		 * 是否锁定门窗，锁定门窗后，将禁止编辑门窗
		 * @param value
		 */
		public function lockWindoor(value:Boolean):void
		{
			windCtr.dragEnable = !value;
		}
		
		/**
		 * 锁定墙体选择区域，锁定后将不能进行墙体选择区域的编辑操作
		 * @param value
		 * 
		 */
		public function lockWallArea(value:Boolean):void
		{
			if(scene2d.house.currFloor)scene2d.house.currFloor.wallAreaSelector.isLock = value;
		}
		
		/**
		 * 判断场景中是否存在墙体选择区域
		 * @return 
		 * 
		 */
		public function hasWallArea():Boolean
		{
			return scene2d.house.currFloor.wallAreaSelector.hasWallArea();
		}
		
		/**
		 * 清除墙体选择区域
		 * 
		 */
		public function clearWallArea():void
		{
			scene2d.house.currFloor.wallAreaSelector.clearWallArea();
		}
		
		
		/**
		 * 自动创建厨柜
		 * @param drainer：水盆数据
		 * @param flue：灶台数据
		 * @param cookerHood：烟机数据
		 * @param sterilizer：消毒柜数据
		 * @param oven：烤箱数据
		 * @param basket：拉篮数据
		 */
		public function autoCreateCabinet(drainer:Object,flue:Object,cookerHood:Object,sterilizer:Object=null,oven:Object=null,basket:Object=null):void
		{
			cabinetCreator.autoCreateCabinet(drainer,flue,cookerHood,sterilizer,oven);
		}
		
		public function switchCabinetTableVisible():void
		{
			cabinetCreator.switchCabinetTableVisible();
		}
		
/*		//检查产品是否加入订单
		private function getIsOrder(mo:ModelObject):Boolean
		{
			var po:ProductObject = mo.parentProductObject;
			var info:ProductInfo = po.productInfo;
			if(isCancleOrderEnable(info))
			{
				return po.isOrder;
			}
			return true;
		}
		
		//设置产品是否加入订单，设置成功返回true，设置不可取消的产品时，返回false
		private function setIsOrder(mo:ModelObject,value:Boolean):Boolean
		{
			var po:ProductObject = mo.parentProductObject;
			var info:ProductInfo = po.productInfo;
			if(isCancleOrderEnable(info))
			{
				po.isOrder = value;
				return true;
			}
			
			return false;
		}
		
		//判断产品是否可以不加入订单
		private function isCancleOrderEnable(info:ProductInfo):Boolean
		{
			switch(info.type)
			{
				case CabinetType.FLUE:
				case CabinetType.HOOD:
				case CabinetType.OVEN:
				case CabinetType.STERILIZER:
				case CabinetType.DRAINER:
					return true;
					break;
			}
			return false;
		}
*/		
		/**
		 * 替换产品
		 * @param model：要被替换产品模型
		 * @param srcs：要替换进来的产品数组（可以有1个或2个产品），为xml组成
		 * 
		 */
		public function replaceProductObject(model:ModelObject,srcs:Array):void
		{
			var xml:XML;
			var po:ProductObject = model.parentProductObject;
			var type:String = po.productInfo.type;
			//trace("type:"+type);
			
			if(type==CabinetType.OVEN || type==CabinetType.STERILIZER)//目标是烤箱或消毒柜时，替换子产品
			{
				xml = srcs[0];
				var id:int = xml.id;
				var file:String = xml.file;
				var name:String = type==CabinetType.OVEN?ProductObjectName.OVEN:ProductObjectName.STERILIZER;
				
				ProductManager.own.replaceSubProductObject(model,id,file,name);
			}
			else if(type==CabinetType.HANDLE)
			{
				var ps:Array = ProductManager.own.getProductsByType(CabinetType.HANDLE);
				xml = srcs[0];
				id = xml.id;
				file = xml.file;
				CabinetLib.lib.setDynamicProductData("handle",id,file);
				
				for each(var info:ProductInfo in ps)
				{
					var pos:Array = info.getProductObjects();
					var len:int = pos.length;
					for each(po in pos)
					{
						ProductManager.own.replaceSubProductObject(po.modelObject,id,file,ProductObjectName.HANDLE);
					}
				}
			}
			else
			{
				while(po.parentProductObject)
				{
					po = po.parentProductObject;//找到根产品
				}
				type = po.productInfo.type;
				
				len = srcs.length;
				
				if(len==1)
				{
					xml = srcs[0];
					id = xml.id;
					file = xml.file;
					var w:int = xml.width;
					var d:int = xml.depth;
					var h:int = xml.height;
					
					po = ProductManager.own.replaceProductObject(po,id,file,"",w,d,h);
					cabinetCreator.addSingleDoor(po);
					
					if(type==CabinetType.DRAINER)
					{
						po.name = ProductObjectName.DRAINER;
						this.cabinetCreator.drainerProduct = po;
						this.cabinetCreator.updateCabinetTable();
					}
					else if(type==CabinetType.FLUE)
					{
						po.name = ProductObjectName.FLUE;
						this.cabinetCreator.flueProduct = po;
					}
					else if(type==CabinetType.BODY)
					{
						this.cabinetCtr.addCabinetDict(po);
						this.cabinetCreator.addCabinet(po);
					}
					else if(type==CabinetType.HOOD)
					{
						this.cabinetCtr.addCabinetDict(po);
						this.cabinetCreator.hoodProduct = po.view2d;
						po.name = ProductObjectName.HOOD;
					}
				}
				else if(len==2)
				{
					//var xml2:XML = srcs[1];
					//var id2:int = xml2.id;
					//var file2:String = xml2.file;
					pos = ProductManager.own.replaceProductObject1_2(po,srcs);
					for(var i:int=0;i<pos.length;i++)
					{
						po = pos[i];
						this.cabinetCtr.addCabinetDict(po);
						this.cabinetCreator.addCabinet(po);
						
						//var doorData:XML = CabinetTool.tool.getDoorData(po);
						//ProductManager.own.addDynamicSubProduct(po,doorData);
						cabinetCreator.addSingleDoor(po);
					}
				}
			}
		}
		
		/**
		 * 替换产品，2个换1个或2个换2个
		 * @param target1：目标产品1
		 * @param target2：目标产品2
		 * @param srcs：源产品数据，有1个或2个
		 * 
		 */
		public function replaceProductObject2_n(target1:ProductObject,target2:ProductObject,srcs:Array):void
		{
			if(srcs.length==1)
			{
				var src1:XML = srcs[0];
				var po:ProductObject = ProductManager.own.replaceProductObject2_1(target1,target2,src1);
				this.cabinetCtr.addCabinetDict(po);
				this.cabinetCreator.addCabinet(po);
			}
			else if(srcs.length==2)
			{
				var pos:Array = ProductManager.own.replaceProductObject2_2(target1,target2,srcs);
				for(var i:int=0;i<pos.length;i++)
				{
					po = pos[i];
					this.cabinetCtr.addCabinetDict(po);
					this.cabinetCreator.addCabinet(po);
					
					var doorData:XML = CabinetTool.tool.getDoorData(po);
					ProductManager.own.addDynamicSubProduct(po,doorData);
				}
			}
		}
		
		private function testReplace():void
		{
			var xml:XML = 
				<item>
					<name>单开地柜</name>
					<price></price>
					<image>assets/icon/cabinet_1_door.png</image>
					<id>502</id>
					<file>cabinet_502_400x720x570.pdt</file>
					<width>400</width>
					<height>720</height>
					<depth>550</depth>
					<type>ground_cabinet</type>
				</item>;

			var xml2:XML =
				<item>
					<name>对开地柜</name>
					<price></price>
					<image>assets/icon/cabinet_2_door.png</image>
					<id>506</id>
					<file>cabinet_506_800x720x570.pdt</file>
					<width>800</width>
					<height>720</height>
					<depth>550</depth>
					<type>ground_cabinet</type>
				</item>;
			
			//if(scene3d.engineManager.mousedownObject)replaceProductObject(scene3d.engineManager.mousedownObject,[xml]);
			//if(GlobalVar.own.currProduct2)ProductManager.own.replaceProductObject2_1(GlobalVar.own.currProduct,GlobalVar.own.currProduct2,xml2);
			if(GlobalVar.own.currProduct2)replaceProductObject2_n(GlobalVar.own.currProduct,GlobalVar.own.currProduct2,[xml,xml]);
			else if(scene3d.engineManager.mousedownObject)replaceProductObject(scene3d.engineManager.mousedownObject,[xml,xml]);
			//if(GlobalVar.own.currProduct)ProductManager.own.replaceProductObject1_2(GlobalVar.own.currProduct,[xml,xml]);
		}
		
		//=========================================================================================================================
		/**
		 * 标注地柜
		 * @param value
		 * 
		 */
		public function setGroundObjectMarkingFlag(value:Boolean):void
		{
			cabinetCtr.setGroundCabinetView2D(value);
			SizeMarking2D.markingGroundObject = value;
			updateMarking();
		}
		
		/**
		 * 标注吊柜
		 * @param value
		 * 
		 */
		public function setWallObjectMarkingFlag(value:Boolean):void
		{
			cabinetCtr.setWallCabinetView2D(value);
			SizeMarking2D.markingWallObject = value;
			updateMarking();
		}
		
		/**
		 * 标注门窗
		 * @param value
		 * 
		 */
		public function setWindoorMarkingFlag(value:Boolean):void
		{
			SizeMarking2D.markingWindoor = value;
			updateMarking();
		}
		
		//=========================================================================================================================
		private function updateMarking():void
		{
			var walls:Vector.<Wall2D> = scene2d.currFloor.walls;
			for each(var w2d:Wall2D in walls)
			{
				w2d.vo.isChanged = true;
			}
			
			scene2d.render();
		}

		//=========================================================================================================================
		private var sceneParser:SceneParser = SceneParser.own;
		
		public function getSceneData():String
		{
			var s:String = scene3d.toJsonString();
			trace("data length:"+s.length);
			trace(s);
			
			s = sceneParser.encodeString(s);
			trace("data length:"+s.length);
			trace(s);
			
			//clearScene();
			
			//setSceneData(s);
			
			return s;
		}
		
		public function setSceneData(s:String):void
		{
			if(MaterialLibrary.instance.xmlLoaded)
			{
				_setSceneData(s);
			}
			else
			{
				sceneData = s;
			}
		}
		
		private function _setSceneData(s:String):void
		{
			var f:Floor = sceneParser.parseEncodeString(s);
			//return;
			
			scene2d.createFloor(f);
			sceneCtr.createRoom2(f.rooms[0]);
			ProductManager.own.loadProduct();
			
			this.fitScreen(true);
			
			GlobalEvent.event.dispatchSceneCompleteEvent();
		}
		
		public function clearScene():void
		{
			//删除所有产品（2d，3d）
//			cabinetCtr.deleteAllProduct();
			deleteAllProduct();
			
			//删除所有房间（数据层）
			scene2d.removeAllFloors();
			
			//删除地面（2d，3d）
			//删除天花板（3d）
			//删除所有墙体（2d，3d）
			//删除所有门窗（2d，3d）
		}
		
		//=========================================================================================================================
		/*private function saveScene(name:String=null):void
		{
			if(!user.isLogin)return;//未登陆时，不能保存场景
			
			var sceneData:String = this.getSceneData();
			var bm2d:BitmapData = this.get2DSnapshot();
			var bm3d:BitmapData = this.get3DSnapshot();
			
			if(projectManager.currProject)
			{
				projectManager.saveProject(sceneData,bm2d,bm3d);
			}
			else
			{
				projectManager.createProject(name,sceneData,bm2d,bm3d);
			}
		}*/
		
		private function testDraw():void
		{
			var bmp:Bitmap = new Bitmap();
			bmp.bitmapData = this.get3DSnapshot();
			this.addChild(bmp);
		}
		
		private function testTips():void
		{
			var s1:String = "测试测试";
			var s2:String = "测试测试测试测试";
			var s3:String = "测试测试测试测试测试测试";
			var s4:String = "TestTest";
			var s5:String = "TestTestTestTest";
			var s6:String = "TestTestTestTestTestTest";
			Tips.show(s1,100,100,3000);
			Tips.show(s2,100,150,4000);
			Tips.show(s3,100,200,5000);
			Tips.show(s4,100,250,6000);
			Tips.show(s5,100,300,7000);
			Tips.show(s6,100,350,8000);
		}
		
		//=========================================================================================================================
		private function test():void
		{
//			trace("hasDoor:"+hasDoor());
//			trace("hasWindow:"+hasWindow());
//			trace("hasHearth:"+hasHearth());
//			trace("hasBasin:"+hasBasin());
//			this.setBackGridVisible(false);
			//this.setBackGroundAlpha(0);
			//this.fitScreen();
			//uploadTest();
			//testLogin();
			//User.own.projectManager.getProjectList();
			//this.projectManager.loadProjectList();
			
			/*testDynamicSubProduct();
			
			if(windCtr.currWindoor)
			{
				windCtr.setWindoor(windCtr.currWindoor.vo,1500,2000,150);
			}
			
			cabinetCtr.lockObstacle(true);
			if(cabinetCtr.currCabinet)
			{
				cabinetCtr.setObjectPosition(cabinetCtr.currCabinet.vo,1000,1000,200);
			}*/
			//ProductManager.own.setAllCabinetDoorMaterial("assets/map/20066.png");
			
			/*
			var s:String = getOrderProductsData();
			trace(s);
			var o:Object = JSON.parse(s);
			SceneParser.traceObject(o);
			//*/
			
			//this.setCabinetDoorMaterial(scene3d.engineManager.mousedownObject,"37959-KW珠光钻石蓝","group");
			//trace("hasWallArea:"+hasWallArea());
			//this.clearWallArea();
			//scene2d.house.currFloor.wallAreaSelector.isLock = !scene2d.house.currFloor.wallAreaSelector.isLock;
			/*var mo:ModelObject = this.scene3d.engineManager.mousedownObject;
			if(mo)
			{
				ProductManager.own.replaceSubProductObject(mo,1602,"sterilizer_1602_1102A.pdt","");
			}*/
			//testDraw();
			//testReplace();
			//testTips();
			//getOrderProductsData();
			//trace(getERPData("userid","username","address","phone","starttime","endtime"));
			//trace("doorcolor:"+getDoorColor());
			//clearAllCabinetObject();
			//trace(this.getProductList());
			cabinetCreator.clearCabinetTalbes();
		}
		
		/**
		 * 获取订单列表的JSON格式数据
		 * @return 
		 * 
		 */
		public function getOrderProductsData():String
		{
			return cabinetCreator.getCabinetList();
		}
		
		/**
		 * 获取当前场景中所有产品列表的JSON格式数据
		 * 
		 */
		public function getProductList():String
		{
			//return cabinetCreator.getProductList();
			return cabinetCreator.getCabinetList();
		}
		
		/**
		 * 获取当前场景的门板色调
		 * @return 
		 * 
		 */
		public function getDoorColor():String
		{
			return "c4c4c4";
			//return cabinetCreator.getDoorColor();
		}
		
		public function getERPData(userID:String,userName:String,address:String,phone:String,startTime:String,endTime:String):String
		{
			return cabinetCreator.getERPData(userID,userName,address,phone,startTime,endTime);
		}
		
		/**
		 * 获取当前场景中所有产品的总价格
		 * 在获取总价格之前，须先调用getProductList()方法
		 */
		public function getTotalPrice():Number
		{
			return cabinetCreator.getTotalPrice();
		}
		
		private function testDynamicSubProduct():void
		{
			trace("testDynamicSubProduct");
			var xml:XML = <item>
								<infoID dscp="自身在数据库中的编号">402</infoID>
								<objectID dscp="">9</objectID>
								<name>门</name>
								<name_en/>
								<file>cabinet_right_door_402_397x717x16.pdt</file>
								<dataFormat>text</dataFormat>
								<position>9.5,81.5,559</position>
								<rotation>0,0,0</rotation>
								<scale>1,1,1</scale>
								<active>true</active>
							</item>;
			
			var xml2:XML = <item>
								<infoID dscp="自身在数据库中的编号">412</infoID>
								<objectID dscp="">10</objectID>
								<name>门</name>
								<name_en/>
								<file>cabinet_left_door_412_397x717x16.pdt</file>
								<dataFormat>text</dataFormat>
								<position>390.5,81.5,559</position>
								<rotation>0,0,0</rotation>
								<scale>1,1,1</scale>
								<active>true</active>
							</item>;

			if(GlobalVar.own.currProduct)
			{
				ProductManager.own.addDynamicSubProduct(GlobalVar.own.currProduct,xml2);
			}
		}
		
		private function testLogin():void
		{
			var user:User = User.own;
			//user.addEventListener("login",onUserLogin);//用户登陆成功事件
			//user.addEventListener("logout",onUserLogout);//用户注销事件（调用user.isLogin = false即触发此事件）
			//user.addEventListener("error",onUserLoginError);//登陆失败或调用接口失败都会触发此事件，user.errorMsg属性描述了此事件的原因
			user.login("yuqiang@enet360.com","111111");
		}
		
		private var getOtherPics:Function;
		private var otherPicType:String;
		
		/**
		 * 获取当前二维平面图数据
		 * @param getPics：获取其它图片的回调函数，参数为Array，数据格式为位图编码后的ByteArray，图片顺序为：地柜平面图，吊柜平面图，立面图1，[立面图2，立面图3]
		 * @param picType：获取其它图片时位图的编码格式
		 * @param w：指定截图的宽度
		 * @param h：指定截图的高度
		 * @return 返回当前平面图的位图数据
		 * 
		 */
		public function get2DSnapshot(getPics:Function=null,picType:String="jpg",w:int=1000,h:int=1000):BitmapData
		{
			scene2d.visible = true;
			wallFaceContainer.visible = false;
			
			this.setSizeMarkingVisible(true);
			this.setGroundObjectMarkingFlag(true);
			this.setWallObjectMarkingFlag(true);
			this.setWindoorMarkingFlag(true);
			
			var bmd:BitmapData = getSnapshot(w,h);
			
			if(getPics!=null)
			{
				getOtherSnapshot(getPics,picType);
			}
			
			return bmd;
		}
		
		/**
		 * 返回其它截图图片二进制数据
		 * @param getPics：图片数据准备完成后的回调函数
		 * @param picType：图片的编码类型
		 * 
		 */
		public function getOtherSnapshot(getPics:Function,picType:String="jpg"):void
		{
			getOtherPics = getPics;
			otherPicType = picType;
			
			pics.length = 0;//清空当前截图
			picIndex = 0;
			get2DSnapshots();//开始创建其它截图
		}
		
		private function getSnapshot(w:int=1000,h:int=1000):BitmapData
		{
			sceneCtr.fitScreen(false,0.5);
			
			var vw:Number = sceneCtr.viewWidth;
			var vh:Number = sceneCtr.viewHeight;
			var sx:Number = 1,sy:Number = 1;
			var dw:int,dh:int;
			
			if(vw>w || vh>h)
			{
				if(vw/vh > w/h)//截图宽高比，比指定尺寸的宽高比要大
				{
					sx = sy = w/vw;
				}
				else
				{
					sx = sy = h/vh;
				}
			}
			else//截图尺寸不超过指定尺寸，使用截图尺寸
			{
				sx = sy = 1;
			}
			
			dw = Math.ceil(vw*sx);
			dh = Math.ceil(vh*sy);
			
			var m:Matrix = new Matrix();
			m.scale(sx,sy);
			
			this.ruler.visible = false;
			
			var bmd:BitmapData  = new BitmapData(dw,dh,true,0);
			bmd.draw(this.container2d,m,null,null,null,true);
			
			this.ruler.visible = true;
			
			return bmd;
		}
		
		public function get3DSnapshot(w:int=800,h:int=600):BitmapData
		{
			return this.scene3d.engine3d.getSnapshot(w,h);
		}
		
		private var pics:Array = [];
		private var picIndex:int = 0;
		
		private function get2DSnapshots():void
		{
			this.addEventListener(Event.ENTER_FRAME,_get2DSnapshots);
		}
		
		private function _get2DSnapshots(e:Event):void
		{
			this.removeEventListener(Event.ENTER_FRAME,_get2DSnapshots);
			//scene2d.visible = !wallFaceContainer.visible;
			picIndex++;
			
			if(picIndex==1)
			{
				this.setWallObjectMarkingFlag(false);
				
				getImageData();
			}
			else if(picIndex==2)
			{
				this.setGroundObjectMarkingFlag(false);
				this.setWallObjectMarkingFlag(true);
				
				getImageData();
				
				wallFaceViewer.reset();
			}
			else if(wallFaceViewer.update())
			{
				scene2d.visible = false;
				wallFaceContainer.visible = true;
				
				getImageData();
			}
			else
			{
				this.setGroundObjectMarkingFlag(true);
				
				scene2d.visible = true;
				wallFaceContainer.visible = false;
				
				if(getOtherPics)
				{
					getOtherPics(pics);
				}
			}
		}
		
		private function getImageData():void
		{
			var bmd:BitmapData  = getSnapshot();
			var data:ByteArray = BMP.encodeBitmap(bmd,otherPicType);
			pics.push(data);
			get2DSnapshots();
		}
		
		private function uploadTest():void
		{
			var bmd:BitmapData  = get2DSnapshot();
			var data:ByteArray = BMP.encodeBitmap(bmd,"png");
			var o:Object = {type:"png"};
			URLTool.CallRemote("upload",o,onUploaded,null,data);
		}
		
		private function onUploaded(result:*):void
		{
			trace("onUploaded:"+result);
		}
		
		//=========================================================================================================================
		/**
		 * 房间中是否已经布置了门
		 * @return 
		 * 
		 */
		public function hasDoor():Boolean
		{
			return house.currRoom.hasDoor();
		}
		
		/**
		 * 房间中是否已经布置了窗
		 * @return 
		 * 
		 */
		public function hasWindow():Boolean
		{
			return house.currRoom.hasWindow();
		}
		
		/**
		 * 是否已经指定的灶台位置
		 */
		public function hasHearth():Boolean
		{
			return cabinetCtr.hasHearth();
		}
		
		/**
		 * 是否已经指定了水盆位置
		 */
		public function hasBasin():Boolean
		{
			return cabinetCtr.hasBasin();
		}
		
		//=========================================================================================================================
		/**
		 * 删除场景中所有产品
		 */
		public function deleteAllProduct():void
		{
			cabinetCtr.deleteAllProduct();
			cabinetCreator.clear();
			
			ProductManager.own.clearRootProductObject();
		}
		
		/**
		 * 删除当前选中的产品
		 */
		public function deleteSelectProduct():void
		{
			if(GlobalVar.own.currProduct)
			{
				deleteProduct(GlobalVar.own.currProduct);
			}
		}
		
		/**
		 * 删除指定产品
		 * 
		 */
		public function deleteProduct(po:ProductObject):void
		{
			cabinetCtr.deleteProduct(po);
		}
		
		public function undo():void
		{
			actionHistory.undo();
		}
		
		public function redo():void
		{
			actionHistory.redo();
		}
		
		//=========================================================================================================================
		
		/*		private function onKeyUp(e:KeyboardEvent):void
		{
		switch(e.keyCode)
		{
		case Keyboard.SPACE:
		break;
		}
		}
		cabinetCtr.deleteAllProduct();
		}
		else
		{
		cabinetCtr.deleteCurrProduct();
		*/		
		protected function on2DSceneKeyDown(e:KeyboardEvent):void
		{
			//trace("on2DSceneKeyDown:"+e.keyCode);
			switch(e.keyCode)
			{
				case Keyboard.NUMBER_1:
					sceneCtr.action = sceneCtr.ACTION_DRAG_SCENE;
					break;
				
				case Keyboard.NUMBER_2:
					sceneCtr.action = sceneCtr.ACTION_DRAW_WALL;
					break;
				
				case Keyboard.NUMBER_3:
					sceneCtr.action = sceneCtr.ACTION_DRAW_ROOM;
					break;
				
				case Keyboard.NUMBER_4:
					//var f:Floor = scene2d.house.currFloor.vo;
					//windCtr.createWindoor(101,900,f.doorHeight,f.doorSillHeight);
					createDoor(900,2100,true);
					break;
				
				case Keyboard.NUMBER_5:
					var f:Floor = scene2d.house.currFloor.vo;
					windCtr.createWindoor(201,1500,f.windowHeight,f.windowSillHeight);
					break;
				
				case Keyboard.NUMBER_6:
					cabinetCtr.createCabinet(502,"cabinet_502_400x720x570.pdt","text",null,-1,CrossWall.IGNORE_OBJECT_HEIGHT,"",true,400,550);
					break;
				
				case Keyboard.NUMBER_7:
					cabinetCtr.createCabinet(606,"cabinet_606_800x720x330.pdt","text",null,-1,CrossWall.WALL_OBJECT_HEIGHT,"",true,800,550);
					break;
				
				case Keyboard.NUMBER_8:
					cabinetCtr.createDrainerFlag();
					break;
				
				case Keyboard.NUMBER_9:
					cabinetCtr.createFlueFlag();
					break;
				
				case Keyboard.J:
					cabinetCtr.createMiddle450Flag();
					break;
				
				case Keyboard.K:
					cabinetCtr.createMiddle600Flag();
					break;
				
				case Keyboard.L:
					cabinetCtr.createHeight600Flag();
					break;
				
				case Keyboard.Q:
					this.createRoomSquarePillar(300,200,0xcccccc);
					break;
				
				case Keyboard.W:
					cabinetCtr.createHorizontalTube(50,1000,0xff8080,200,10);
					break;
				
				case Keyboard.NUMBER_0:
					var xPos:int;
					var yPos:int = CrossWall.IGNORE_OBJECT_HEIGHT;
					var wall2d:Wall2D = scene2d.currFloor.walls[0];
					var cw:CrossWall = scene2d.currFloor.rooms[0].walls[wall2d];
					/*xPos = 120+300;
					cabinetCtr.createCabinet(501,"cabinet_501_300x720x570.pdt","text",cw,xPos,yPos);
					xPos+=400;
					cabinetCtr.createCabinet(502,"cabinet_502_400x720x570.pdt","text",cw,xPos,yPos);
					xPos+=450;
					cabinetCtr.createCabinet(503,"cabinet_503_450x720x570.pdt","text",cw,xPos,yPos);
					xPos+=500;
					cabinetCtr.createCabinet(504,"cabinet_504_500x720x570.pdt","text",cw,xPos,yPos);
					xPos+=600;
					cabinetCtr.createCabinet(505,"cabinet_505_600x720x570.pdt","text",cw,xPos,yPos);
					xPos+=800;
					cabinetCtr.createCabinet(506,"cabinet_506_800x720x570.pdt","text",cw,xPos,yPos);
					xPos+=900;
					cabinetCtr.createCabinet(507,"cabinet_507_900x720x570.pdt","text",cw,xPos,yPos);
					xPos+=200;
					cabinetCtr.createCabinet(510,"cabinet_510_200x720x570.pdt","text",cw,xPos,yPos);
					xPos+=300;
					cabinetCtr.createCabinet(511,"cabinet_511_300x720x570.pdt","text",cw,xPos,yPos);
					xPos+=400;
					cabinetCtr.createCabinet(512,"cabinet_512_400x720x570.pdt","text",cw,xPos,yPos);*/
					
					/*wall2d = scene2d.currFloor.walls[1];
					cw = scene2d.currFloor.rooms[0].walls[wall2d];
					xPos = 120+50+570;
					xPos+=450;
					cabinetCtr.createCabinet(513,"cabinet_513_450x720x570.pdt","text",cw,xPos,yPos);
					xPos+=600;
					cabinetCtr.createCabinet(515,"cabinet_515_600x720x570.pdt","text",cw,xPos,yPos);
					xPos+=800;
					cabinetCtr.createCabinet(516,"cabinet_516_800x720x570.pdt","text",cw,xPos,yPos);
					xPos+=900;
					cabinetCtr.createCabinet(517,"cabinet_517_900x720x570.pdt","text",cw,xPos,yPos);
					xPos+=600;
					cabinetCtr.createCabinet(525,"cabinet_525_600x720x570.pdt","text",cw,xPos,yPos);
					xPos+=800;
					cabinetCtr.createCabinet(526,"cabinet_526_800x720x570.pdt","text",cw,xPos,yPos);*/
					
					/*wall2d = scene2d.currFloor.walls[2];
					cw = scene2d.currFloor.rooms[0].walls[wall2d];
					xPos = 220+50+570;
					xPos+=900;
					cabinetCtr.createCabinet(527,"cabinet_527_900x720x570.pdt","text",cw,xPos,yPos);
					xPos+=800;
					cabinetCtr.createCabinet(536,"cabinet_536_800x720x570.pdt","text",cw,xPos,yPos);
					xPos+=900;
					cabinetCtr.createCabinet(537,"cabinet_537_900x720x570.pdt","text",cw,xPos,yPos);
					xPos+=800;
					cabinetCtr.createCabinet(546,"cabinet_546_800x720x570.pdt","text",cw,xPos,yPos);
					xPos+=900;
					cabinetCtr.createCabinet(547,"cabinet_547_900x720x570.pdt","text",cw,xPos,yPos);*/
					
					/*wall2d = scene2d.currFloor.walls[3];
					cw = scene2d.currFloor.rooms[0].walls[wall2d];*/
					//xPos = 120+50;
					xPos = 125;
					//xPos+=900;
					//cabinetCtr.createCabinet(557,"cabinet_557_900x720x570.pdt","text",cw,xPos,yPos);
					xPos+=450;
					cabinetCtr.createCabinet(703,"cabinet_703_450x1390x570.pdt","text",cw,xPos,yPos);
					xPos+=600;
					cabinetCtr.createCabinet(705,"cabinet_705_600x1390x570.pdt","text",cw,xPos,yPos);
					xPos+=600;
					cabinetCtr.createCabinet(715,"cabinet_715_600x1390x570.pdt","text",cw,xPos,yPos);
					xPos+=600;
					cabinetCtr.createCabinet(805,"cabinet_805_600x2110x570.pdt","text",cw,xPos,yPos);
					xPos+=600;
					cabinetCtr.createCabinet(815,"cabinet_815_600x2110x570.pdt","text",cw,xPos,yPos);
					xPos+=600;
					cabinetCtr.createCabinet(825,"cabinet_825_600x2110x570.pdt","text",cw,xPos,yPos);
					
					/*wall2d = scene2d.currFloor.walls[0];
					cw = scene2d.currFloor.rooms[0].walls[wall2d];
					yPos = CrossWall.WALL_OBJECT_HEIGHT;
					xPos = 120;
					xPos+=300;
					cabinetCtr.createCabinet(601,"cabinet_601_300x720x330.pdt","text",cw,xPos,yPos);
					xPos+=400;
					cabinetCtr.createCabinet(602,"cabinet_602_400x720x330.pdt","text",cw,xPos,yPos);
					xPos+=450;
					cabinetCtr.createCabinet(603,"cabinet_603_450x720x330.pdt","text",cw,xPos,yPos);
					xPos+=500;
					cabinetCtr.createCabinet(604,"cabinet_604_500x720x330.pdt","text",cw,xPos,yPos);
					xPos+=600;
					cabinetCtr.createCabinet(605,"cabinet_605_600x720x330.pdt","text",cw,xPos,yPos);
					xPos+=800;
					cabinetCtr.createCabinet(606,"cabinet_606_800x720x330.pdt","text",cw,xPos,yPos);
					xPos+=900;
					cabinetCtr.createCabinet(607,"cabinet_607_900x720x330.pdt","text",cw,xPos,yPos);
					xPos+=600;
					cabinetCtr.createCabinet(615,"cabinet_615_600x720x330.pdt","text",cw,xPos,yPos);*/
					
					/*wall2d = scene2d.currFloor.walls[1];
					cw = scene2d.currFloor.rooms[0].walls[wall2d];
					xPos = 120+50+570;
					xPos+=800;
					cabinetCtr.createCabinet(616,"cabinet_616_800x720x330.pdt","text",cw,xPos,yPos);
					xPos+=900;
					cabinetCtr.createCabinet(617,"cabinet_617_900x720x330.pdt","text",cw,xPos,yPos);
					xPos+=800;
					cabinetCtr.createCabinet(626,"cabinet_626_800x720x330.pdt","text",cw,xPos,yPos);*/
					break;
				
				case Keyboard.U:
//					if(e.shiftKey && e.altKey)
						switchView2D();
					break;
				
				case Keyboard.R:
					cabinetCtr.replaceCurrCabinet();
					break;
				
				case Keyboard.P:
					testAutoCreate();
					break;
				
				case Keyboard.V:
					cabinetCreator.switchCabinetTableVisible();
					break;
				
				case Keyboard.M:
					switchView();
					break;
				
				case Keyboard.F:
					this.fitScreen(true);
					break;
				
				case Keyboard.T:
					this.test();
					break;
				
				case Keyboard.S:
					this.getSceneData();
					break;
				
				case Keyboard.N:
					if(e.ctrlKey)
					{
						this.clearScene();
						//this.createRoom();
						_setSceneData(sceneData);
						//createRoom(3000,3000,3000,150);fitScreen(false);
					}
					break;
				
				/*case Keyboard.S:
					this.splitWall();
					break;*/
				
				case Keyboard.DELETE:
					/*RoomControler.deleteRoom();
					WallControler.deleteWall();
					WinDoorControler.deleteWindoor();
					ModelControler.deleteModel();*/
					wallCtr.deleteCurrentWall();
					if(e.ctrlKey)
					{
						//cabinetCtr.deleteAllProduct();
						deleteAllProduct();
					}
					else
					{
						//cabinetCtr.deleteProduct();
						deleteSelectProduct();
					}
					break;
				
				case Keyboard.EQUAL://+
					//this.setSceneScale(0.5);
					break;
				
				case Keyboard.MINUS://-
					//this.setSceneScale(-0.5);
					break;
				
				case Keyboard.Z:
//					if(e.shiftKey && e.altKey)
						actionHistory.undo();
					break;
				
				case Keyboard.Y:
//					if(e.shiftKey && e.altKey)
					actionHistory.redo();
					break;
				
				case Keyboard.G:
					this.scene3d.engine3d.updateCubeReflection();
					break;
			}
			
			sceneCtr.isCatchGridPoint = !e.ctrlKey;
			nodeCtr.isCatchGridPoint = !e.ctrlKey;
		}
		
		private function testAutoCreate():void
		{
			var xml11:XML = 		<item>
					<name>单盆-SC7247-1A</name>
					<cate></cate>
					<spce>720*470*230(mm)</spce>
					<dscp></dscp>
					<price>1</price>
					<image>assets/icon/drainer_1201_JBS1T_OLCE105.png</image>
					<id>1201</id>
					<file>drainer_1201_JBS1T_OLCE105.pdt</file>
					<width>573</width>
					<height>492</height>
					<depth>467</depth>
				</item>;
			var xml12:XML = 		<item>
					<name>单盆-SC7247-1A</name>
					<cate></cate>
					<spce>720*470*230(mm)</spce>
					<dscp></dscp>
					<price>1</price>
					<image>assets/icon/drainer_1202_JBS1T_OLCE207.png</image>
					<id>1202</id>
					<file>drainer_1202_JBS1T_OLCE207.pdt</file>
					<width>745</width>
					<height>530</height>
					<depth>447</depth>
				</item>;
			var xml13:XML = 		<item>
					<name>单盆-SC7247-1A</name>
					<cate></cate>
					<spce>720*470*230(mm)</spce>
					<dscp></dscp>
					<price>1</price>
					<image>assets/icon/drainer_1203_JBS2T_OLCE309.png</image>
					<id>1203</id>
					<file>drainer_1203_JBS2T_OLCE309.pdt</file>
					<width>792</width>
					<height>526</height>
					<depth>455</depth>
				</item>;
			var xml14:XML = 		<item>
					<name>单盆-SC7247-1A</name>
					<cate></cate>
					<spce>720*470*230(mm)</spce>
					<dscp></dscp>
					<price>1</price>
					<image>assets/icon/drainer_1204_JBS2T_OLCE407.png</image>
					<id>1204</id>
					<file>drainer_1204_JBS2T_OLCE407.pdt</file>
					<width>806</width>
					<height>481</height>
					<depth>438</depth>
				</item>;
			
			var xml2:XML = 		<item>
					<name>灶台-GP1311Z</name>
					<cate></cate>
					<spce>750*430(mm)</spce>
					<dscp>热效率：大于58%</dscp>
					<price>1</price>
					<image>assets/icon/flue_1304_GP1311Z.png</image>
					<id>1304</id>
					<file>flue_1304_GP1311Z.pdt</file>
					<width>713</width>
					<height>50</height>
					<depth>435</depth>
				</item>;
			var xml3:XML = 		<item>
					<name>烟机-CXW-268-K6</name>
					<cate></cate>
					<spce>900×355×845(mm)</spce>
					<dscp>风量:14.5±10%m3/min</dscp>
					<price>1</price>
					<image>assets/icon/cooker_hood_1103_CXW-268-K6.png</image>
					<id>1103</id>
					<file>cooker_hood_1103_CXW-268-K6.pdt</file>
					<width>867</width>
					<height>832</height>
					<depth>250</depth>
				</item>;
			
			var xml41:XML = 		<item>
					<name>消毒柜-1108A1</name>
					<cate></cate>
					<spce>650X530X715(mm)</spce>
					<dscp>开孔尺寸：570X585X450</dscp>
					<price>1</price>
					<image>assets/icon/sterilizer_1601_1108A1.jpg</image>
					<id>1601</id>
					<file>sterilizer_1601_1108A1.pdt</file>
					<width>652</width>
					<height>676</height>
					<depth>555</depth>
				</item>;
			
			var xml42:XML = 		<item>
					<name>消毒柜-1102A</name>
					<cate></cate>
					<spce>650X530X715(mm)</spce>
					<dscp>开孔尺寸：570X585X450</dscp>
					<price>1</price>
					<image>assets/icon/sterilizer_1602_1102A.jpg</image>
					<id>1602</id>
					<file>sterilizer_1602_1102A.pdt</file>
					<width>643</width>
					<height>676</height>
					<depth>533</depth>
				</item>;
			
			var xml51:XML = 		<item>
					<name>烤箱-ZQL-T-6A</name>
					<cate></cate>
					<spce>595x450x410(mm)</spce>
					<dscp>开孔尺寸：565x445x550</dscp>
					<price>1</price>
					<image>assets/icon/oven_1501_KWS260_K01.png</image>
					<id>1501</id>
					<file>oven_1501_KWS260_K01.pdt</file>
					<width>778</width>
					<height>49</height>
					<depth>445</depth>
				</item>;
			
			var xml52:XML = 		<item>
					<name>烤箱-JK-E01</name>
					<cate></cate>
					<spce>595x595x550(mm)</spce>
					<dscp>开孔尺寸：565x585x550</dscp>
					<price>1</price>
					<image>assets/icon/oven_1502_KWS260_K02.png</image>
					<id>1502</id>
					<file>oven_1502_KWS260_K02.pdt</file>
					<width>778</width>
					<height>49</height>
					<depth>445</depth>
				</item>;
			
			var xml53:XML = 		<item>
					<name>烤箱-JK-M02</name>
					<cate></cate>
					<spce>595x595x550(mm)</spce>
					<dscp>开孔尺寸：565x585x550</dscp>
					<price>1</price>
					<image>assets/icon/oven_1503_KWS260_K03.png</image>
					<id>1503</id>
					<file>oven_1503_KWS260_K03.pdt</file>
					<width>778</width>
					<height>49</height>
					<depth>445</depth>
				</item>;
			//xml42 = null;
			//xml53 = null;
			cabinetCreator.autoCreateCabinet(xml14,xml2,xml3,xml42,xml53);
		}
		
		private var author:String = "jell3d.com";
		
		protected function on2DSceneKeyUp(e:KeyboardEvent):void
		{
			//trace("on2DSceneKeyUp:"+e.keyCode);
			sceneCtr.isCatchGridPoint = !e.ctrlKey;
			nodeCtr.isCatchGridPoint = !e.ctrlKey;
		}
		//=========================================================================================================================
	}
}

















