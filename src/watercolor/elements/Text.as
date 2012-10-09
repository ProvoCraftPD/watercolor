package watercolor.elements
{
	import flashx.textLayout.elements.TextFlow;
	
	import spark.components.TextArea;
	
	import watercolor.components.WatercolorTextArea;
		
	[Style(name="skinClass", type="Class", inherit="no")]
	[Style(name="textFontSize", type="String", inherit="no")]
	
	/**
	 * Watercolor's Rect element encapsulates a Flex-based Rect, a filled
	 * graphic element that draws a rectangle.
	 * 
	 * @see spark.primitives.Rect
	 */
	public class Text extends Group
	{
		protected var _textInput:WatercolorTextArea;

		/**
		 * The Flex-based primitive wrapped by this Element.
		 */
		public function get textInput():WatercolorTextArea
		{
			return _textInput;
		}

		
		public function Text()
		{
			_textInput = new WatercolorTextArea();
			_textInput.prompt = "type";
			
			var skinClass:Class = getStyle("skinClass") as Class;
			
			if (skinClass)
				this.skinClass = skinClass;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			addElement(textInput);
		}
		
		/**
		 * @copy spark.primitives.supportClasses.GraphicElement#width;
		 */
		override public function get width():Number { return _textInput.width; }
		override public function set width(value:Number):void { super.width = value; _textInput.width = value; }
		
		/**
		 * @copy spark.primitives.supportClasses.GraphicElement#height;
		 */
		override public function get height():Number { return _textInput.height; }
		override public function set height(value:Number):void { super.height = value; _textInput.height = value; }
		
		// :: TextInput Properties :: //
	
		public function get prompt():String { return _textInput.prompt; }
		public function set prompt(value:String):void { _textInput.prompt = value; }
		
		public function get text():String { return _textInput.text; }
		public function set text(value:String):void { _textInput.text = value; }
		
		public function get textFlow():TextFlow { return _textInput.textFlow; }
		public function set textFlow(value:TextFlow):void { _textInput.textFlow = value; }
		
		public function get skinClass():Class { return _textInput.getStyle("skinClass"); }
		public function set skinClass(value:Class):void { _textInput.setStyle("skinClass", value); }
		
		public function get textFontSize():String { return _textInput.getStyle("fontSize"); }
		public function set textFontSize(value:String):void { _textInput.setStyle("fontSize", value); }
		
	}
}