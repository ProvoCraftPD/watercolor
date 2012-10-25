package watercolor.factories.svg2.text
{
	import flashx.textLayout.compose.TextFlowLine;
	import flashx.textLayout.elements.FlowElement;
	import flashx.textLayout.elements.LinkElement;
	
	import watercolor.elements.Text;
	import watercolor.factories.svg2.ElementFactory;
	import watercolor.factories.svg2.util.SVGAttributes;
	import watercolor.factories.svg2.util.URIManager;
	
	/**
	 * 
	 */ 
	public class LinkElementFactory
	{
		
		public static function createSparkFromSVG(node:XML, uriManager:URIManager):LinkElement
		{
			var link:LinkElement = new LinkElement();
			
			for each (var child:XML in node.children()) {	
				
				var elm:Object = ElementFactory.createSparkFromSVG(child, uriManager);
				
				if (elm is FlowElement) {
					
					link.addChild(FlowElement(elm));
					
				}
				
			}
			
			SVGAttributes.parseXMLAttributes(node, link);
			
			return link;
		}
		
		public static function createSVGFromSpark(xml:XML, link:LinkElement, line:TextFlowLine, start:int, element:Text):Object
		{
			var href:XML = new XML("<a/>");
			href.@target = "_blank";
			href.@["xlink:href"] = link.href;
			
			for (var x:int = 0; x < link.numChildren; x++) {
				
				var child:FlowElement = link.getChildAt(x);
				
				var result:Object = TextElementFactory.createSVGFromSpark(xml, child, line, start, element);
				
				if (result is XML) {
					href.appendChild(result);
				}
			}
			
			if (href.children().length() > 0) {
				return href;
			} else {
				return null;
			}
		}
	}
}