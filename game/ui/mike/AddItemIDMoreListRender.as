package game.ui.mike
{
	import morn.core.components.Box;
	import morn.core.components.Clip;
	import morn.core.components.Label;
	
	public class AddItemIDMoreListRender extends Box
	{
		public var label:Label = new Label;
		public function AddItemIDMoreListRender()
		{
			super();
			
			this.setSize(370,30);
			
			addChild(label);
			label.height = 20;
			label.width = 370;
			label.font = MainUI.FontName;
			label.embedFonts = true;
			label.size = 16;
			label.color = "0xFFFFFF";
			label.text = "请等待…";
			label.name = "label";
			label.align = "center";
			label.buttonMode = true;
			label.y = 5;
			var clip:Clip = new Clip('png.comp.clip_selectBox',1,2);
			clip.width = 370;
			clip.height = 30;
			addChildAt(clip,0);
			clip.name = "selectBox"
		}
	}
}