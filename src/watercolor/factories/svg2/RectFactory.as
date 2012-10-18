package watercolor.factories.svg2
{
	import watercolor.elements.Rect;
	import watercolor.elements.components.Workarea;
	import watercolor.factories.svg2.util.SVGAttributes;
	import watercolor.factories.svg2.util.URIManager;
	
	/**
	 * Spark Rect Factory
	 * 
	 * SVG Documentation: 
	 * Spark Documentation: http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/spark/primitives/Rect.html
	 */ 
	public class RectFactory
	{
		public function RectFactory()
		{
		}
		
		public static function createSparkFromSVG(node:XML, uriManager:URIManager, element:Rect = null):Rect
		{
			if (!element)
			{
				element = new Rect();
			}
			
			// look for any children such as fills, strokes, or filters
			GraphicsFactory.createSparkFromSVG(node, uriManager, element);	
			
			// set any attributes
			SVGAttributes.parseXMLAttributes(node, element);
			
			return element;
		}
		
		public static function createSVGFromSpark(element:Rect, workarea:Workarea):XML
		{
			// TODO: Generate SVG
			return null;
		}
	}
}