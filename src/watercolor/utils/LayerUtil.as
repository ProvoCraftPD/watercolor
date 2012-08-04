package watercolor.utils
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.IVisualElement;
	
	import watercolor.commands.vo.CreateVO;
	import watercolor.commands.vo.DeleteVO;
	import watercolor.commands.vo.GroupCommandVO;
	import watercolor.commands.vo.Position;
	import watercolor.elements.Element;
	import watercolor.elements.Layer;
	import watercolor.elements.components.IsolationLayer;


	/**
	 * Utility to help with Layer(s)
	 *
	 * @author SeanT23
	 */
	public class LayerUtil
	{

		/**
		 * Create N(quanity) amount of elements on (L)layer.
		 *
		 * Figures out the best possible placement for the clones.
		 * If the image is too big to fit, then it will be scaled down.
		 * Then passes call to fillByDimension.
		 *
		 * @param source Element to clone and attach
		 * @param layer Layer to add clones to
		 * @param quanity Number of elements to create
		 * @param customCopyFunction Custom function to clone elements with.
		 * @param padding Padding between Elements
		 *
		 * @param A GroupCommand to execute the fill.
		 */
		public static function fillByQuanity( source:IVisualElement, layer:Layer, quanity:uint = 10, customCopyFunction:Function = null, padding:uint = 5, offSetLeft:uint = 0, offSetRight:uint = 0, offSetTop:uint = 0, offSetBottom:uint = 0 ):GroupCommandVO
		{
			// Find current grid size
			var maxColumnCount:uint = Math.floor( (layer.width - offSetLeft - offSetRight) / ( source.getLayoutBoundsWidth() + padding ));
			var maxRowCount:uint = Math.floor( (layer.height - offSetTop - offSetBottom) / ( source.getLayoutBoundsHeight() + padding ));
			var columnCount:uint = 0;
			var rowCount:uint = 0;

			while(( rowCount * columnCount ) < quanity )
			{
				if( rowCount < maxRowCount || columnCount < maxColumnCount )
				{
					// There is still free rows and/or cols we can use
					if( columnCount < maxColumnCount )
					{
						columnCount++;
					}
					else if( rowCount < maxRowCount )
					{
						rowCount++;
					}
				}
				else
				{
					// No more free rows, try to figure out best way to add cols/rows...
					var addRowArea:uint = getAreaUsed( source, layer, columnCount, rowCount + 1, padding );
					var addCollumnArea:uint = getAreaUsed( source, layer, columnCount + 1, rowCount, padding );

					if( addCollumnArea > addRowArea )
					{
						columnCount++;
					}
					else
					{
						rowCount++;
					}
				}
			}

			return fillByDimension( source, layer, columnCount, rowCount, customCopyFunction, quanity, padding, offSetLeft, offSetTop );
		}


		/**
		 * Creates and attaches clones in a row/col style.
		 *
		 * If the image is too big to fit, then it will be scaled down.
		 *
		 * @param source Element to clone and attach
		 * @param layer Layer to add clones to
		 * @param columns Column count
		 * @param rows Row count
		 * @param customCopyFunction Custom function to clone elements with.
		 * @param maxQuanity Max quanity of elements to add to layer. (0=infinite)
		 * @param padding Padding between Elements
		 *
		 * @param A GroupCommandVO to execute the fill
		 */
		public static function fillByDimension( source:IVisualElement, layer:Layer, columns:uint = 10, rows:uint = 2, customCopyFunction:Function = null, maxQuanity:uint = 0, padding:uint = 5, offSetLeft:uint = 0, offSetTop:uint = 0):GroupCommandVO
		{

			// Loop thru rows
			var groupCommandVO:GroupCommandVO = new GroupCommandVO();
			if(source.parent != null)
			{
				groupCommandVO.addCommand( new DeleteVO( Element( source ), Element( source ).getPosition()));
			}
			
			// Create copy of Element, this will make the history functionality work.
			source = customCopyFunction != null ? customCopyFunction( source ) : VisualElementUtil.clone( source );

			var vector:Vector.<Element> = new Vector.<Element>( 1 );
			vector[ 0 ] = Element( source );
			var width:uint = source.getLayoutBoundsWidth();
			var height:uint = source.getLayoutBoundsHeight();
			var sizeRatio:Number = 1;

			var columnCount:uint = Math.floor( layer.width / ( width + padding ));
			if( columnCount < columns )
			{
				//Need to resize the source...
				//sizeRatio = ( layer.width / columns ) / ( width + padding );
				ExecuteUtil.execute( TransformUtil.scale( vector, sizeRatio, sizeRatio ));

				width = width * sizeRatio;
				height = height * sizeRatio;
			}

			var rowCount:uint = Math.floor( layer.height / ( height + padding ));
			if( rowCount < rows )
			{
				//Need to resize the source...
				var perHeight:uint = ( layer.height / rows );
				var itemHeight:uint = ( height );

				//sizeRatio = ( layer.height / rows ) / ( height + padding );
				ExecuteUtil.execute( TransformUtil.scale( vector, sizeRatio, sizeRatio ));

				width = width * sizeRatio;
				height = height * sizeRatio;
			}

			var originalPosition:Point = new Point( source.x, source.y );

			// Position variables
			source.x = 0;
			source.y = 0;

			//Figure out starting offsets (including rotation offset)
			var leftRotationOffset:int = source.getLayoutBoundsX() * -1;
			var leftOffset:int = leftRotationOffset + offSetLeft;
			var topOffset:int = (source.getLayoutBoundsY() * -1) + offSetTop;
			var elementCount:uint = 0;

			for( var rowIndex:uint = 0; rowIndex < rows; rowIndex++ )
			{

				leftOffset = leftRotationOffset + offSetLeft;

				for( var columnIndex:uint = 0; columnIndex < columns; columnIndex++ )
				{

					var newElement:IVisualElement;


					// Create copy of Element
					if( customCopyFunction != null )
					{
						newElement = customCopyFunction( source );
					}
					else
					{
						newElement = VisualElementUtil.clone( source );
					}

					//Element(newElement).transform.matrix.tr

					newElement.x = leftOffset;
					newElement.y = topOffset;




					// Add elements to parent, and return array
					groupCommandVO.addCommand( new CreateVO( Element( newElement ), new Position( layer, 0 )));
					elementCount++;

					// If maxQuanity is set, make sure we don't exceed.
					if( maxQuanity > 0 && elementCount >= maxQuanity )
					{
						return groupCommandVO;
					}

					leftOffset += width + padding;
				}

				topOffset += height + padding;
			}


			return groupCommandVO;
		}


		/**
		 * Creates and attaches as many clones as can fit into a Layer
		 *
		 * @param source Element to clone and attach
		 * @param layer Layer to add clones to
		 * @param customCopyFunction Custom function to clone elements with.
		 * @param maxQuanity Max quanity of elements to add to layer. (0=infinite)
		 * @param padding Padding between Elements
		 *
		 * @param A GroupCommandVO to execute the fill
		 */
		public static function fillBySpace( source:IVisualElement, layer:Layer, customCopyFunction:Function = null, maxQuanity:uint = 0, padding:uint = 5, offSetLeft:uint = 0, offSetRight:uint = 0, offSetTop:uint = 0, offSetBottom:uint = 0 ):GroupCommandVO
		{
			var groupCommandVO:GroupCommandVO = new GroupCommandVO();
			groupCommandVO.addCommand( new DeleteVO( Element( source ), Element( source ).getPosition()));

			// get the rectangle area for the elements
			var vector:Vector.<Element> = new Vector.<Element>( 1 );
			vector[ 0 ] = Element( source );
			var rect:Rectangle = VisualElementUtil.getElementsRectangle(vector, source.parent as DisplayObject);
			
			// Figure out how many we can fit.
			var columnCount:uint = Math.floor( (layer.width - offSetLeft - offSetRight) / (rect.width + padding));
			var rowCount:uint = Math.floor( (layer.height - offSetTop - offSetBottom) / (rect.height + padding));	
			
			if(columnCount < 1 || rowCount < 1)
			{
				return null;
			}
			// Position variables
			var leftOffset:uint = offSetLeft;
			var topOffset:uint = offSetTop;

			// Loop thru rows
			var elementCount:uint = 0;

			for( var rowIndex:uint = 0; rowIndex < rowCount; rowIndex++ )
			{

				leftOffset = offSetLeft;

				// Loop thru columns
				for( var columnIndex:uint = 0; columnIndex < columnCount; columnIndex++ )
				{

					var newElement:IVisualElement;

					// Create copy of Element
					if( customCopyFunction != null )
					{
						newElement = customCopyFunction( source );
					}
					else
					{
						newElement = VisualElementUtil.clone( source );
					}


					newElement.setLayoutBoundsPosition( leftOffset, topOffset );

					// Add elements to parent					
					groupCommandVO.addCommand( new CreateVO( Element( newElement ), new Position( layer, 0 )));
					elementCount++;

					// If maxQuanity is set, make sure we don't exceed.
					if( maxQuanity > 0 && elementCount >= maxQuanity )
					{
						return groupCommandVO;
					}

					// Set new X position for next element
					leftOffset += rect.width + padding;
				}

				// Set new Y position for next element
				topOffset += rect.height + padding;
			}

			return groupCommandVO;
		}


		/**
		 * Helper function that determines how much area of the layer will be used
		 * by a have X(rows) and Y(columns) of E(source)
		 *
		 * @param source Element to calculate adding
		 * @param layer Layer to calculate adding to
		 * @param cols Column count to try and fit
		 * @param rows Row count to try and fit
		 * @param padding Padding between Elements
		 *
		 * @return Total area used by sources(elements)
		 */
		public static function getAreaUsed( source:IVisualElement, layer:Layer, cols:uint, rows:uint, padding:uint = 5 ):uint
		{
			var width:uint = source.width;
			var height:uint = source.height;
			var sizeRatio:Number = 1;

			var columnCount:uint = Math.floor( layer.width / ( width + padding ));
			if( columnCount < cols )
			{
				//Need to resize the source...
				sizeRatio = ( layer.width / cols ) / ( width + padding );
				width = width * sizeRatio;
				height = height * sizeRatio;
			}

			var rowCount:uint = Math.floor( layer.height / ( height + padding ));
			if( rowCount < rows )
			{
				sizeRatio = ( layer.height / rows ) / ( height + padding );
				width = width * sizeRatio;
				height = height * sizeRatio;
			}

			var itemArea:uint = ( height + padding ) * ( width + padding );
			var itemCount:uint = cols * rows;

			return itemArea * itemCount;
		}


		/**
		 * Helper function to return a element's Layer (if any)
		 *
		 * @param element Object to try to find Layer from
		 *
		 * @return Layer found(null if none)
		 */
		public static function getLayer( element:* ):Layer
		{
			while( true )
			{
				if( element is Layer )
					return element;
				if( element is IsolationLayer )
					return getLayer( IsolationLayer( element ).firstIsolatedElement );
				if( Object( element ).hasOwnProperty( 'parent' ))
					element = element.parent;
				else
					return null;
			}

			return null;
		}
		
		/**
		 * Helper function to return a element's Layer (if any)
		 *
		 * @param element Object to try to find Layer from
		 *
		 * @return Layer found(null if none)
		 */
		public static function getCurrentLayer( element:* ):*
		{
			while( true )
			{
				if( element is Layer || element is IsolationLayer)
					return element;
				if( Object( element ).hasOwnProperty( 'parent' ))
					element = element.parent;
				else
					return null;
			}
			
			return null;
		}
	}
}
