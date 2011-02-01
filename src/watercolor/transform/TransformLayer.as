package watercolor.transform
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import spark.components.supportClasses.SkinnableComponent;
	import spark.primitives.supportClasses.GraphicElement;
	
	import watercolor.elements.Element;
	import watercolor.events.TransformLayerEvent;
	import watercolor.utils.CoordinateUtils;
	import watercolor.utils.VisualElementUtil;


	/**
	 * Transformation layer. This handles rotation, skew and scale at the same time.
	 * Type of operation depends on where mouse down event occures, active areas are ilustrated below
	 *
	 * <pre>
	 * (  r  )  skX       skX   (  r  )
	 *  -- [sc]-----[sc]------[sc] --
	 *  skY  |                  |  skY
	 *       |                  |
	 *     [sc]     [pv]      [sc]
	 *       |                  |
	 *  skY  |                  |  skY
	 *  -- [sc]-----[sc]------[sc] --
	 * (  r  )  skX       skX   (  r  )
	 *
	 * (r) - rotation
	 * (sc) - scale
	 * (sk) - skew X/Y
	 * (pv) - pivot point
	 * 	</pre>
	 *
	 */
	public class TransformLayer extends SkinnableComponent
	{		
		/**
		 * Dictionary list of selected elements with their original matrices
		 */
		private var matrices:Dictionary;


		/**
		 * Objects total transformation matrix
		 */
		private var totalMatrix:Matrix;


		/**
		 * Invertion of the total transformation matrix
		 */
		private var totalMatrixInversion:Matrix;


		/**
		 * Current transformation matrix. This is transformation
		 * matrix is calculated when user moves mouse
		 */
		private var currentMatrix:Matrix;


		/**
		 * transformation center points
		 */
		private var ctrp1:Point;


		private var ctrp2:Point;


		/**
		 * global center of transformed elements
		 */
		private var pcenter:Point;


		/**
		 * mouse down coordinates in
		 * transform coordinate space
		 */
		private var mdt:Point;


		/**
		 * global mouse down coordinates
		 */
		private var globalMdt:Point;


		private var _topLeft:Point = new Point();
		private var _topRight:Point = new Point();	
		private var _bottomRight:Point = new Point();	
		private var _bottomLeft:Point = new Point();			
		private var _center:Point = new Point();
		
		[Bindable] /**
		[Bindable]  * 
		[Bindable]  * @return 
		[Bindable]  */
		[Bindable] /**
		[Bindable]  * 
		[Bindable]  * @return 
		[Bindable]  */
		[Bindable] public function get topLeft():Point { return _topLeft; }
		[Bindable] /**
		[Bindable]  * 
		[Bindable]  * @return 
		[Bindable]  */
		[Bindable] /**
		[Bindable]  * 
		[Bindable]  * @return 
		[Bindable]  */
		[Bindable] public function get topRight():Point { return _topRight; }
		[Bindable] /**
		[Bindable]  * 
		[Bindable]  * @return 
		[Bindable]  */
		[Bindable] /**
		[Bindable]  * 
		[Bindable]  * @return 
		[Bindable]  */
		[Bindable] public function get bottomRight():Point { return _bottomRight; }
		[Bindable] /**
		[Bindable]  * 
		[Bindable]  * @return 
		[Bindable]  */
		[Bindable] /**
		[Bindable]  * 
		[Bindable]  * @return 
		[Bindable]  */
		[Bindable] public function get bottomLeft():Point { return _bottomLeft; }
		[Bindable] /**
		[Bindable]  * 
		[Bindable]  * @return 
		[Bindable]  */
		[Bindable] /**
		[Bindable]  * 
		[Bindable]  * @return 
		[Bindable]  */
		[Bindable] public function get center():Point { return _center; }		
		
		/**
		 * 
		 * @param value
		 */
		public function set bottomLeft(value:Point):void { _bottomLeft = value; }
		/**
		 * 
		 * @param value
		 */
		public function set bottomRight(value:Point):void { _bottomRight = value; }
		/**
		 * 
		 * @param value
		 */
		public function set topRight(value:Point):void { _topRight = value; }
		/**
		 * 
		 * @param value
		 */
		public function set topLeft(value:Point):void { _topLeft = value; }
		/**
		 * 
		 * @param value
		 */
		public function set center(value:Point):void { _center = value; }

		
		/**
		 *
		 */
		private var cMode:String;


		/**
		 * level where all transformed objects are placed
		 */
		private var _parentContainer:DisplayObjectContainer;


		/**
		 * containers for keeping track of mouse move and mouse up listeners
		 */
		private var listenerArray:Array;


		private var uplistenerArray:Array;


		private var xPadding:Number = 0;


		private var yPadding:Number = 0;
		
		private var _elements:Vector.<Element>;	
		private var _rect:Rectangle;

		public function get rect():Rectangle
		{
			return _rect;
		}

		private var _identityBounds:Boolean;
		
		private var dict:Dictionary;
		private var transformMatrix:Matrix;

		[SkinPart(type="spark.primitives.supportClasses.GraphicElement",required="false")]
		/**
		 * 
		 * @default 
		 */
		public var selectionBounds:GraphicElement;

		/**
		 * The top right button
		 */
		[SkinPart(required="false")]
		/**
		 *
		 * @default
		 */
		public var topRightBtn:Sprite = new Sprite();


		/**
		 * The top left button
		 */
		[SkinPart(required="false")]
		/**
		 *
		 * @default
		 */
		public var topLeftBtn:Sprite = new Sprite();


		/**
		 * The bottom right button
		 */
		[SkinPart(required="false")]
		/**
		 *
		 * @default
		 */
		public var bottomRightBtn:Sprite = new Sprite();


		/**
		 * The bottom left button
		 */
		[SkinPart(required="false")]
		/**
		 *
		 * @default
		 */
		public var bottomLeftBtn:Sprite = new Sprite();


		/**
		 * The top right rotation button
		 */
		[SkinPart(required="false")]
		/**
		 *
		 * @default
		 */
		public var topRightRotateBtn:Sprite = new Sprite();


		/**
		 * The top left rotation button
		 */
		[SkinPart(required="false")]
		/**
		 *
		 * @default
		 */
		public var topLeftRotateBtn:Sprite = new Sprite();


		/**
		 * The bottom right rotation button
		 */
		[SkinPart(required="false")]
		/**
		 *
		 * @default
		 */
		public var bottomRightRotateBtn:Sprite = new Sprite();


		/**
		 * The bottom left rotation button
		 */
		[SkinPart(required="false")]
		/**
		 *
		 * @default
		 */
		public var bottomLeftRotateBtn:Sprite = new Sprite();


		/**
		 * The top middle button
		 */
		[SkinPart(required="false")]
		/**
		 *
		 * @default
		 */
		public var topMiddleBtn:Sprite = new Sprite();


		/**
		 * The right middle button
		 */
		[SkinPart(required="false")]
		/**
		 *
		 * @default
		 */
		public var rightMiddleBtn:Sprite = new Sprite();


		/**
		 * The bottom middle button
		 */
		[SkinPart(required="false")]
		/**
		 *
		 * @default
		 */
		public var bottomMiddleBtn:Sprite = new Sprite();


		/**
		 * The left middle button
		 */
		[SkinPart(required="false")]
		/**
		 *
		 * @default
		 */
		public var leftMiddleBtn:Sprite = new Sprite();


		/**
		 * The center button
		 */
		[SkinPart(required="false")]
		/**
		 *
		 * @default
		 */
		public var centerBtn:Sprite = new Sprite();


		/**
		 * The skew X Top button
		 */
		[SkinPart(required="false")]
		/**
		 *
		 * @default
		 */
		public var skewTopBtn:Sprite = new Sprite();


		/**
		 * The skew X Bottom button
		 */
		[SkinPart(required="false")]
		/**
		 *
		 * @default
		 */
		public var skewBottomBtn:Sprite = new Sprite();


		/**
		 * The skew Y Left button
		 */
		[SkinPart(required="false")]
		/**
		 *
		 * @default
		 */
		public var skewLeftBtn:Sprite = new Sprite();


		/**
		 * The skew Y Right button
		 */
		[SkinPart(required="false")]
		/**
		 *
		 * @default
		 */
		public var skewRightBtn:Sprite = new Sprite();


		[SkinState("selected", "nonselected")]

		
		private var _scaleProportional:Boolean = false;

		/**
		 *
		 * @return
		 */
		public function get scaleProportional():Boolean
		{
			return _scaleProportional;
		}


		/**
		 *
		 * @param value
		 */
		public function set scaleProportional(value:Boolean):void
		{
			_scaleProportional = value;
		}
		
		/**
		 * Sets the elements
		 * @param value A vector containing the selected elements
		 */
		public function set elements(value:Object):void
		{
			_elements = value as Vector.<Element>;
			
			// reset the dictionary list
			for (var key:* in dict)
			{
				delete dict[key];
			}
			
			// update the transformation matrix
			updateTransformMatrix();
		}		
		
		/**
		 * Used for obtaining the list of elements in the transformer
		 * @return
		 */
		public function get elements():Object
		{
			return _elements;
		}


		/**
		 * This is used for keeping track if we are in the selected or nonselected states
		 * @default
		 */
		protected var selected:Boolean;


		/**
		 * Constructor
		 */
		public function TransformLayer()
		{
			super();
		}


		override protected function getCurrentSkinState():String
		{
			return selected ? "selected" : "nonselected";
		}


		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);

			// go through each sprite and set the appropriate event listeners
			switch(instance)
			{
				case skewTopBtn:
				case skewBottomBtn:
				case skewRightBtn:
				case skewLeftBtn:
				case topLeftBtn:
				case topRightBtn:
				case bottomLeftBtn:
				case bottomRightBtn:
				case topLeftRotateBtn:
				case topRightRotateBtn:
				case bottomLeftRotateBtn:
				case bottomRightRotateBtn:
				case leftMiddleBtn:
				case rightMiddleBtn:
				case topMiddleBtn:
				case bottomMiddleBtn:
					instance.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
					break;
				case centerBtn:
					centerBtn.doubleClickEnabled = true;
					centerBtn.addEventListener(MouseEvent.DOUBLE_CLICK, centerDblClickHandler, false, 0, true);
					centerBtn.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
					break;
			}
		}


		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);

			// go through each sprite and remove the appropriate event listeners
			switch(instance)
			{
				case skewTopBtn:
				case skewBottomBtn:
				case skewRightBtn:
				case skewLeftBtn:
				case topLeftBtn:
				case topRightBtn:
				case bottomLeftBtn:
				case bottomRightBtn:
				case topLeftRotateBtn:
				case topRightRotateBtn:
				case bottomLeftRotateBtn:
				case bottomRightRotateBtn:
				case leftMiddleBtn:
				case rightMiddleBtn:
				case topMiddleBtn:
				case bottomMiddleBtn:
					instance.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
					break;
				case centerBtn:
					centerBtn.doubleClickEnabled = false;
					centerBtn.removeEventListener(MouseEvent.DOUBLE_CLICK, centerDblClickHandler);
					centerBtn.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
					break;
			}
		}

		/**
		 * Function for activating the selection box after a selection has been made in the work area
		 * @param oparent The parent to the elements
		 */
		public function select(parentContainer:DisplayObjectContainer, objects:Vector.<Element>, identityBounds:Boolean, listenForMove:Boolean = true):void
		{
			_identityBounds = identityBounds;
			_parentContainer = parentContainer;
			
			// the elements that are to be transformed
			_elements = new Vector.<Element>();
			
			// a dictionary list of elements and their original matrix
			dict = new Dictionary(true);
			
			// the transformed matrix
			transformMatrix = new Matrix();
			
			// sets the elements
			elements = objects;
		
			begin(listenForMove);
			
			// dispatch an event to inidicate that a selection has been made
			dispatchEvent(new TransformLayerEvent(TransformLayerEvent.TRANSFORM_INIT, matrices, _elements, getCurrentRect()));
		}
		
		/**
		 * 
		 * @param listenForMove
		 */
		public function begin(listenForMove:Boolean = true):void
		{
			if (_elements && _elements.length > 0 && _parentContainer)
			{
				// initialize global variables
				currentMatrix = new Matrix();
				topLeft = new Point();
				topRight = new Point();
				bottomRight = new Point();
				bottomLeft = new Point();
				pcenter = new Point();
				
				listenerArray = new Array();
				uplistenerArray = new Array();
				
				// set the selected state to 'selected'
				selected = true;
				invalidateSkinState();
				
				// listen for the mouse move event
				// this is for moving an element in the workarea
				if(listenForMove)
				{
					addMouseMoveGlobalListener(mouseDownHandler, mouseMoveUp);
				}
				
				// display the selection box with the center button in the right place
				redrawSelectionBox();
				
				// initialize the global matrix variables
				totalMatrix = transformMatrix;
				currentMatrix = totalMatrix.clone();
				totalMatrixInversion = totalMatrix.clone();
				totalMatrixInversion.invert();
				
				center = globalToLocal(pcenter);
				adjustBtnByRotation(center, centerBtn);
				
				// get the current elements and their new and old matrices
				matrices = getTransformations();
			}
		}


		/**
		 * Function for deactivating the selection box or turning it off
		 *
		 */
		public function unSelect(clearItems:Boolean = true):void
		{
			// remove any mouse move listeners
			removeMouseMoveGlobalListener();
			totalMatrix = null;
			totalMatrixInversion = null;

			// clear any graphics on the transformation later
			graphics.clear();

			if(clearItems && elements)
			{
				_elements.splice(0, _elements.length);
			}

			// set the selected state to 'nonselected'
			selected = false;
			invalidateSkinState();

			dispatchEvent(new TransformLayerEvent(TransformLayerEvent.TRANSFORM_DEACTIVATED, null, null, null));
		}


		/**
		 * Public function that can be called to update the selection box.
		 * This is useful for when applying transformations outside of the selection box.
		 * Call this after making a transformation so that the selection box stays current
		 * @param identityBounds If the selection box should display the identity bounds
		 */
		public function update(updateCenter:Boolean = true, identityBounds:Boolean = false):void
		{
			if (_elements && _elements.length > 0 && _parentContainer)
			{
				// set the selected state to 'selected'
				selected = true;
				invalidateSkinState();
	
				// update the display of the selection box
				redrawSelectionBox(updateCenter, identityBounds);
	
				// update the global matrices from the selected elements 
				totalMatrix = transformMatrix;
				totalMatrixInversion = totalMatrix.clone();
				totalMatrixInversion.invert();
				currentMatrix = totalMatrix.clone();
			}
		}
		
		/**
		 * The function for grabbing the four corners of a rectangle around the selected elements
		 * @param topLeft 
		 * @param topRight
		 * @param bottomRight
		 * @param bottomLeft
		 * @param resetBounds
		 */
		protected function findCorners(updateBounds:Boolean = false):void
		{			
			// if we want to update the selection box
			if (updateBounds)
			{
				updateTransformMatrix();
			}
			
			var topLeftTemp:Point;
			var topRightTemp:Point;
			var bottomRightTemp:Point;
			var bottomLeftTemp:Point;
			
			if (_elements.length > 1 || _identityBounds)
			{
				// find all of the corners
				topLeftTemp = transformMatrix.transformPoint(new Point(0, 0));
				topRightTemp = transformMatrix.transformPoint(new Point(dict[this].width, 0));
				bottomRightTemp = transformMatrix.transformPoint(new Point(dict[this].width, dict[this].height));
				bottomLeftTemp = transformMatrix.transformPoint(new Point(0, dict[this].height));
			}
			else
			{
				// find the four corners around the element
				topLeftTemp = transformMatrix.transformPoint(_rect.topLeft);
				topRightTemp = transformMatrix.transformPoint(new Point(_rect.bottomRight.x, _rect.topLeft.y));
				bottomRightTemp = transformMatrix.transformPoint(_rect.bottomRight);
				bottomLeftTemp = transformMatrix.transformPoint(new Point(_rect.topLeft.x, _rect.bottomRight.y));
			}
			
			topLeft.x = topLeftTemp.x;
			topLeft.y = topLeftTemp.y;
			topRight.x = topRightTemp.x;
			topRight.y = topRightTemp.y;
			bottomRight.x = bottomRightTemp.x;
			bottomRight.y = bottomRightTemp.y;
			bottomLeft.x = bottomLeftTemp.x;
			bottomLeft.y = bottomLeftTemp.y;
		}
		
		/**
		 * 
		 * @return 
		 */
		protected function getCurrentRect():Rectangle
		{
			return VisualElementUtil.getElementsRectangle(_elements, _parentContainer, false);
		}
		
		/**
		 * Function for appending a matrix to all of the selected elements
		 * @param mtx The matrix to be used for appending to the selected elements
		 */
		protected function addTransformation(mtx:Matrix):void
		{
			var element:Element;
			var matrix:Matrix;
			
			if (_elements.length > 1 || _identityBounds)
			{
				// go through each element and append the transformation for each element
				for each (element in _elements)
				{
					matrix = dict[element].clone();
					matrix.concat(mtx);
					element.transform.matrix = matrix;
				}
			}
			else if (_elements.length == 1)
			{
				_elements[0].transform.matrix = mtx;
			}
			
			transformMatrix = mtx.clone();
		}
		
		/**
		 *
		 * @return
		 */
		public function currentTransformation():Matrix
		{
			
			// find the updated rectangle and return the transformation matrix
			return transformMatrix;
		}
		
		/**
		 * Function for creating a dictionary list of elements
		 * Also used for setting the transformation matrix 
		 * 
		 */ 
		protected function updateTransformMatrix():void
		{
			
			// make sure that we have elements
			if (_elements && _elements.length > 0)
			{
				
				// find the bounding rectangle
				updateRect();
				
				// go through each element and set it in the dictionary list
				for each (var element:Element in _elements)
				{
					// the original matrix adjusted to the bounding rectangle
					dict[element] = element.transform.matrix.clone();
					dict[element].tx -= _rect.x;
					dict[element].ty -= _rect.y;
				}
				
				// record the bounding rectangle
				dict[this] = _rect.clone();
				
				// get the identity bounding box and set its position to the rectangle
				
				if (_elements.length > 1 || _identityBounds)
				{
					transformMatrix.identity();
					transformMatrix.tx = _rect.x;
					transformMatrix.ty = _rect.y;
				}
				else if (_elements.length == 1)
				{
					transformMatrix = _elements[0].transform.matrix;
				}
			}
		}
		
		/** 
		 * Function used for refreshing the bounding rectangle over the elements
		 * 
		 */ 
		protected function updateRect():void
		{
			_rect = (_elements.length > 1 || _identityBounds) ? VisualElementUtil.getElementsRectangle(_elements, _parentContainer) : VisualElementUtil.getElementRectangle(_elements[0], _parentContainer, false);
		}

		/**
		 * This function returns a boolean value to indicate if a point is located within a selection box or an element
		 * @param point The point to test. This point must already have been converted to a local point within the work area or transform layer.
		 * @return A boolean value to indicate if the point is within the selection box.
		 */
		public function isPointInsideOfElement(point:Point):Boolean
		{

			var isInside:Boolean = false;

			if (_elements && _elements.length > 0 && _parentContainer)
			{
				// get the corners for the selection box
				findCorners(false);
	
				topLeft = CoordinateUtils.localToLocal(_parentContainer, this, topLeft);
				topRight = CoordinateUtils.localToLocal(_parentContainer, this, topRight);
				bottomLeft = CoordinateUtils.localToLocal(_parentContainer, this, bottomLeft);
				bottomRight = CoordinateUtils.localToLocal(_parentContainer, this, bottomRight);
	
				// put all x-values in an array
				var xArray:Array = new Array();
				xArray.push(topLeft.x, topRight.x, bottomRight.x, bottomLeft.x);
	
				// put all y-values in an array
				var yArray:Array = new Array();
				yArray.push(topLeft.y, topRight.y, bottomRight.y, bottomLeft.y);
	
				// loop through the coordinates and check each side of the selection box to see if the mouse click was inside
				var j:int = 3;
				for(var i:int = 0; i < 4; i++)
				{
					if(yArray[ i ] < point.y && yArray[ j ] >= point.y || yArray[ j ] < point.y && yArray[ i ] >= point.y)
					{
						if(xArray[ i ] + (point.y - yArray[ i ]) / (yArray[ j ] - yArray[ i ]) * (xArray[ j ] - xArray[ i ]) < point.x)
						{
							isInside = !isInside;
						}
					}
					j = i;
				}
			}
			
			return isInside;
		}
		
		/**
		 * Returns the current matrix of the selected elements
		 * @return 
		 */
		public function getCurrentRotation():Number
		{
			var um:Matrix = transformMatrix.clone();
			
			var scaleX:Number = Math.sqrt(Math.pow(um.a, 2) + Math.pow(um.b, 2));
			var r:Number = Math.acos(um.a / scaleX);				
			if(Math.asin(um.b / scaleX) < 0)
			{
				r *= -1;
			}
			
			return r;
		}
		
		public function getSkewX():Number
		{
			var um:Matrix = removeRotation(transformMatrix);			
			var vSkewX:Number = Math.atan(-um.c / um.d);
			
			if (um.d < 0)
			{
				vSkewX *= -1;
			}
			
			return vSkewX;
		}
		
		public function getSkewY():Number
		{		
			// This doesn't quite work yet
			
			/*var crt:Point = totalMatrixInversion.transformPoint(_parentContainer.globalToLocal(localToGlobal(center)));
			var um:Matrix = transformMatrix.clone();
			
			if (um.a < 0)
			{
				um.translate(-crt.x, -crt.y);			
				um.scale(-1, 1);
				um.translate(crt.x, crt.y);
			}
			
			if (um.d < 0)
			{
				um.translate(-crt.x, -crt.y);			
				um.scale(1, -1);
				um.translate(crt.x, crt.y);
			}
			
			var offSet:Number = getSkewX();
			var rot:Number = getCurrentRotation();
			
			var r:Number = rot + offSet;
			
			// remove the rotation from the matrix
			um.translate(-crt.x, -crt.y);	
			um.rotate(-r);
			um.translate(crt.x, crt.y);
			
			var vSkewY:Number = Math.atan(-um.b / um.a);
			
			if (um.a < 0)
			{
				vSkewY *= -1;
			}
			
			return vSkewY;*/
			
			return 0;
		}
		
		private function removeRotation(m:Matrix):Matrix
		{
			var crt:Point = totalMatrixInversion.transformPoint(_parentContainer.globalToLocal(localToGlobal(center)));
			var um:Matrix = m.clone();
			
			if (um.a < 0)
			{
				um.translate(-crt.x, -crt.y);			
				um.scale(-1, 1);
				um.translate(crt.x, crt.y);
			}
			
			if (um.d < 0)
			{
				um.translate(-crt.x, -crt.y);			
				um.scale(1, -1);
				um.translate(crt.x, crt.y);
			}
			
			// remove the rotation from the matrix
			var scalerX:Number = Math.sqrt(Math.pow(um.a, 2) + Math.pow(um.b, 2));
			var r:Number = Math.acos(um.a / scalerX);				
			if(Math.asin(um.b / scalerX) < 0)
			{
				r *= -1;
			}			
			
			// remove the rotation from the matrix
			um.translate(-crt.x, -crt.y);					
			um.rotate(-r);
			um.translate(crt.x, crt.y);
			
			return um;
		}

		/**
		 * This function is used for updating the display of the selection box
		 * @param updateRefPoint If the center button should go back to the center
		 * @param isSkew If the transformation was a skew
		 * @param identityBounds If the selection box should display the identity bounds
		 */
		protected function redrawSelectionBox(updateRefPoint:Boolean = true, identityBounds:Boolean = false):void
		{
			var tmp:Point;

			// get the four corners of the selected elements
			findCorners(identityBounds);

			// find these points globally
			topLeft = _parentContainer.localToGlobal(topLeft);
			topRight = _parentContainer.localToGlobal(topRight);
			bottomRight = _parentContainer.localToGlobal(bottomRight);
			bottomLeft = _parentContainer.localToGlobal(bottomLeft);

			// find the global center point
			tmp = new Point(0.25 * (topLeft.x + topRight.x + bottomRight.x + bottomLeft.x), 0.25 * (topLeft.y + topRight.y + bottomRight.y + bottomLeft.y));

			pcenter.x = tmp.x;
			pcenter.y = tmp.y;

			// if we want the center point to stay in the center
			if(updateRefPoint)
			{
				// update the center point's location
				tmp = new Point(pcenter.x, pcenter.y);
				tmp = globalToLocal(tmp);
				center.x = tmp.x;
				center.y = tmp.y;
			}

			// convert these points back to local coordinates
			topLeft = globalToLocal(topLeft);
			topRight = globalToLocal(topRight);
			bottomRight = globalToLocal(bottomRight);
			bottomLeft = globalToLocal(bottomLeft);

			if (selectionBounds)
			{
				selectionBounds.width = _rect.width;
				selectionBounds.height = _rect.height;
				
				var sm:Matrix = transformMatrix.clone();				
				sm.concat(_parentContainer.transform.concatenatedMatrix);				
				sm.tx = topLeft.x;
				sm.ty = topLeft.y;
				
				selectionBounds.transform.matrix = sm;
			}
			
			// some fancy math to make sure the corner buttons are rotated properly
			// This is so that if the buttons have graphics, then the graphics will 
			// always display according to the transformation.
			var tmp2:Point = new Point();
			tmp.x = topLeft.x - topRight.x;
			tmp.y = topLeft.y - topRight.y;
			tmp2.x = topLeft.x - bottomLeft.x;
			tmp2.y = topLeft.y - bottomLeft.y;
			tmp.normalize(1);
			tmp2.normalize(1);
			tmp.x += tmp2.x;
			tmp.y += tmp2.y;
			tmp2.x = Math.atan2(tmp.y, tmp.x) * 180 / Math.PI;
			topLeftBtn.rotation = topLeftRotateBtn.rotation = (tmp2.x + 135);
			bottomRightBtn.rotation = bottomRightRotateBtn.rotation = (tmp2.x + 135);

			// top left
			adjustBtnByRotation(topLeft, topLeftBtn);			
			adjustBtnByRotation(topLeft, topLeftRotateBtn);
			adjustBtnByRotation(bottomRight, bottomRightBtn);
			adjustBtnByRotation(bottomRight, bottomRightRotateBtn);
			
			tmp.x = topRight.x - topLeft.x;
			tmp.y = topRight.y - topLeft.y;
			tmp2.x = topRight.x - bottomRight.x;
			tmp2.y = topRight.y - bottomRight.y;
			tmp.normalize(1);
			tmp2.normalize(1);
			tmp.x += tmp2.x;
			tmp.y += tmp2.y;
			tmp2.x = Math.atan2(tmp.y, tmp.x) * 180 / Math.PI;
			topRightBtn.rotation = topRightRotateBtn.rotation = (tmp2.x + 45);
			bottomLeftBtn.rotation = bottomLeftRotateBtn.rotation = (tmp2.x + 45);

			adjustBtnByRotation(topRight, topRightBtn);			
			adjustBtnByRotation(topRight, topRightRotateBtn);
			adjustBtnByRotation(bottomLeft, bottomLeftBtn);
			adjustBtnByRotation(bottomLeft, bottomLeftRotateBtn);
			
			// calculate the rotation between topLeft and topRight
			var btnRotation:Number = Math.atan2(topRight.y - topLeft.y, topRight.x - topLeft.x) * 180 / Math.PI;

			// calculate the rotation between topLeft and bottomLeft
			var btnRotation2:Number = (Math.atan2(bottomLeft.y - topLeft.y, bottomLeft.x - topLeft.x) * 180 / Math.PI) - 90;

			// use the rotations calculated above to determine the rotation of the middle and skew buttons
			rightMiddleBtn.rotation = btnRotation;
			topMiddleBtn.rotation = btnRotation;
			bottomMiddleBtn.rotation = btnRotation2;
			leftMiddleBtn.rotation = btnRotation2;

			skewRightBtn.rotation = btnRotation;
			skewTopBtn.rotation = btnRotation;
			skewBottomBtn.rotation = btnRotation2;
			skewLeftBtn.rotation = btnRotation2;
			
			adjustBtnByRotation(Point.interpolate(topRight, bottomRight, 0.5), rightMiddleBtn);
			adjustBtnByRotation(Point.interpolate(topRight, bottomRight, 0.5), skewRightBtn);			
			adjustBtnByRotation(Point.interpolate(topLeft, topRight, 0.5), topMiddleBtn);
			adjustBtnByRotation(Point.interpolate(topLeft, topRight, 0.5), skewTopBtn);			
			adjustBtnByRotation(Point.interpolate(bottomRight, bottomLeft, 0.5), bottomMiddleBtn);
			adjustBtnByRotation(Point.interpolate(bottomRight, bottomLeft, 0.5), skewBottomBtn);		
			adjustBtnByRotation(Point.interpolate(bottomLeft, topLeft, 0.5), leftMiddleBtn);
			adjustBtnByRotation(Point.interpolate(bottomLeft, topLeft, 0.5), skewLeftBtn);

			// also rotate the center button
			centerBtn.rotation = btnRotation;
			adjustBtnByRotation(center, centerBtn);
		}
		
		private function adjustBtnByRotation(btnp:Point, btn:Sprite, width:Boolean = true, height:Boolean = true):void
		{
			var tempM:Matrix = new Matrix();
			tempM.translate(-btnp.x, -btnp.y);
			tempM.rotate(btn.rotation * (Math.PI / 180));
			tempM.translate(btnp.x, btnp.y);	
			
			var tempP:Point = tempM.transformPoint(new Point((width) ? (btnp.x - (btn.width / 2)) : btnp.x, (height) ? (btnp.y - (btn.height / 2)) : btnp.y));			
			btn.x = tempP.x;
			btn.y = tempP.y;
		}


		/**
		 * Handler function for when the mouse is pressed down on one of the selection box handlers
		 * @param event The mouse down event
		 */
		private function mouseDownHandler(event:MouseEvent):void
		{
			if (event.currentTarget.visible && totalMatrixInversion)
			{			
				// remove any mouse move listeners
				removeMouseMoveGlobalListener();
	
				ctrp1 = new Point();
				ctrp2 = center.clone();
				ctrp2 = localToGlobal(ctrp2);
	
				// grab the global mouse down location
				globalMdt = new Point(event.stageX, event.stageY);
	
				// determine the local mouse down location
				mdt = totalMatrixInversion.transformPoint(_parentContainer.globalToLocal(globalMdt));
	
				cMode = TransformMode.MODE_IDLE;
	
				// check which button was clicked on
				var btn:Sprite = event.currentTarget as Sprite;
				switch(btn)
				{
					case skewTopBtn:
						with (Point.interpolate(topLeft, topRight, 0.5)) { ctrp1.x = x; ctrp1.y = y; }
						cMode = TransformMode.MODE_SKEWX;
						break;
					case skewBottomBtn:
						with (Point.interpolate(bottomRight, bottomLeft, 0.5)) { ctrp1.x = x; ctrp1.y = y; }
						cMode = TransformMode.MODE_SKEWX;
						break;
					case skewRightBtn:
						with (Point.interpolate(topRight, bottomRight, 0.5)) { ctrp1.x = x; ctrp1.y = y; }
						cMode = TransformMode.MODE_SKEWY;
						break;
					case skewLeftBtn:
						with (Point.interpolate(bottomLeft, topLeft, 0.5)) { ctrp1.x = x; ctrp1.y = y; }
						cMode = TransformMode.MODE_SKEWY;
						break;
					case topLeftRotateBtn:
						ctrp1.x = bottomRight.x;
						ctrp1.y = bottomRight.y;
						cMode = TransformMode.MODE_ROTATE;
						break;
					case topLeftBtn:
						ctrp1.x = bottomRight.x;
						ctrp1.y = bottomRight.y;
						cMode = TransformMode.MODE_SCALE;
						break;
					case topRightRotateBtn:
						ctrp1.x = bottomLeft.x;
						ctrp1.y = bottomLeft.y;
						cMode = TransformMode.MODE_ROTATE;
						break;
					case topRightBtn:
						ctrp1.x = bottomLeft.x;
						ctrp1.y = bottomLeft.y;
						cMode = TransformMode.MODE_SCALE;
						break;
					case bottomLeftRotateBtn:
						ctrp1.x = topRight.x;
						ctrp1.y = topRight.y;
						cMode = TransformMode.MODE_ROTATE;
						break;
					case bottomLeftBtn:
						ctrp1.x = topRight.x;
						ctrp1.y = topRight.y;
						cMode = TransformMode.MODE_SCALE;
						break;
					case bottomRightRotateBtn:
						ctrp1.x = topLeft.x;
						ctrp1.y = topLeft.y;
						cMode = TransformMode.MODE_ROTATE;
						break;
					case bottomRightBtn:
						ctrp1.x = topLeft.x;
						ctrp1.y = topLeft.y;
						cMode = TransformMode.MODE_SCALE;
						break;
					case topMiddleBtn:						
						with (Point.interpolate(bottomRight, bottomLeft, 0.5)) { ctrp1.x = x; ctrp1.y = y; }						
						cMode = TransformMode.MODE_SCALEY;
						break;
					case bottomMiddleBtn:
						with (Point.interpolate(topLeft, topRight, 0.5)) { ctrp1.x = x; ctrp1.y = y; }
						cMode = TransformMode.MODE_SCALEY;
						break;
					case rightMiddleBtn:
						with (Point.interpolate(bottomLeft, topLeft, 0.5)) { ctrp1.x = x; ctrp1.y = y; }
						cMode = TransformMode.MODE_SCALEX;
						break;
					case leftMiddleBtn:
						with (Point.interpolate(topRight, bottomRight, 0.5)) { ctrp1.x = x; ctrp1.y = y; }
						cMode = TransformMode.MODE_SCALEX;
						break;
					case centerBtn:
						cMode = TransformMode.MODE_CENTER_POINT;
						break;
					default:
						ctrp1.x = mouseX;
						ctrp1.y = mouseY;
						cMode = TransformMode.MODE_MOVE;
				}
	
				ctrp1 = localToGlobal(ctrp1);
	
				// set the appropriate listeners depending on what type of transformation is being performed
				switch(cMode)
				{
					case TransformMode.MODE_SCALE:
						addMouseMoveGlobalListener(onMouseScale, deactivateHandler);
						break;
					case TransformMode.MODE_SCALEX:
						addMouseMoveGlobalListener(onMouseScaleX, deactivateHandler);
						break;
					case TransformMode.MODE_SCALEY:
						addMouseMoveGlobalListener(onMouseScaleY, deactivateHandler);
						break;
					case TransformMode.MODE_ROTATE:
						addMouseMoveGlobalListener(onMouseRotate, deactivateHandler);
						break;
					case TransformMode.MODE_SKEWY:
						addMouseMoveGlobalListener(onMouseSkewY, deactivateHandler);
						break;
					case TransformMode.MODE_SKEWX:
						addMouseMoveGlobalListener(onMouseSkewX, deactivateHandler);
						break;
					case TransformMode.MODE_MOVE:
						addMouseMoveGlobalListener(onMouseMove, deactivateHandler);
						break;
					case TransformMode.MODE_CENTER_POINT:
						addMouseMoveGlobalListener(centerPointMouseMove, mouseMoveUp);
						break;
				}
	
				if(cMode != TransformMode.MODE_ROTATE)
				{
					ctrp1 = totalMatrixInversion.transformPoint(_parentContainer.globalToLocal(ctrp1));
					ctrp2 = totalMatrixInversion.transformPoint(_parentContainer.globalToLocal(ctrp2));
				}
	
				event.stopImmediatePropagation();
	
				// grab the matrices for the elements
				matrices = getTransformations();
				dispatchEvent(new TransformLayerEvent(TransformLayerEvent.TRANSFORM_BEGIN, matrices, _elements, getCurrentRect(), cMode));
			}
		}


		/**
		 * Function called when the mouse button is let go after clicking on a handler
		 * @param event The mouse up event
		 */
		private function deactivateHandler(event:MouseEvent):void
		{
			// remove any mouse move listeners
			removeMouseMoveGlobalListener();

			// grab the transformation and identity transformation matrices for the element(s)
			totalMatrix = transformMatrix;
			totalMatrixInversion = totalMatrix.clone();
			totalMatrixInversion.invert();
			ctrp1 = null;
			ctrp2 = null;
			mdt = null;
			currentMatrix.identity();

			// dispatch an event to indicate that the transformation is finished
			dispatchEvent(new TransformLayerEvent(TransformLayerEvent.TRANSFORM_FINISH, matrices, _elements, getCurrentRect()));
		}


		/**
		 * Function for adding a global mouse move and mouse up listener
		 * @param listener The function to call when the mouse is pressed down on a handler
		 * @param uplistener The function to call when the mouse is let go
		 */
		private function addMouseMoveGlobalListener(listener:Function, uplistener:Function = null):void
		{
			// if the global collection does not contain the listener then add it
			if(listenerArray.indexOf(listener) == -1)
			{
				listenerArray.push(listener);
			}

			// add the listener to the stage
			stage.addEventListener(MouseEvent.MOUSE_MOVE, listener, false, 0, false);

			// an up listener was specified
			if(uplistener != null)
			{
				// if the global collection does not contain the listener then add it
				if(uplistenerArray.indexOf(listener) == -1)
				{
					uplistenerArray.push(uplistener);
				}

				// add the listener to the stage
				stage.addEventListener(MouseEvent.MOUSE_UP, uplistener, false, 0, false);
			}
		}


		/**
		 * Method removes all global mouse move listeners
		 *
		 */
		private function removeMouseMoveGlobalListener():void
		{
			var func:Function;

			// if the array isn't null
			if(listenerArray != null)
			{
				// go through each function in the array and remove it
				for each(func in listenerArray)
				{
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, func);
				}

				// empty the array
				listenerArray.splice(0, listenerArray.length);
			}

			// if the array isn't null
			if(uplistenerArray != null)
			{
				// go through each function in the array and remove it
				for each(func in uplistenerArray)
				{
					stage.removeEventListener(MouseEvent.MOUSE_UP, func);
				}

				// empty the array
				uplistenerArray.splice(0, uplistenerArray.length);
			}
		}


		/**
		 * Function for creating the dictionary list of elements and their original matrices
		 *
		 */
		private function getTransformations():Dictionary
		{
			// create a new dictionary
			var dict:Dictionary = new Dictionary();

			// go through each element and add it to the dictionary
			for each(var element:Element in elements)
			{
				dict[ element ] = { matrix:element.transform.matrix.clone(), concatenatedMatrix:element.transform.concatenatedMatrix.clone()};
			}
			
			return dict;
		}


		/**
		 * General function for when a mouse button is let go
		 *
		 */
		private function mouseMoveUp(event:Event):void
		{
			// remove any mouse move listeners
			removeMouseMoveGlobalListener();
		}


		/**
		 * Function that is called when the center button is double clicked.
		 */
		private function centerDblClickHandler(event:MouseEvent):void
		{
			// grab the center point on the stage and convert it locally for setting the center button
			center = new Point(pcenter.x, pcenter.y);
			center = globalToLocal(center);
			adjustBtnByRotation(center, centerBtn);
		}


		/**
		 * Function to call when moving the center button
		 * @param The mouse click event
		 *
		 */
		private function centerPointMouseMove(event:MouseEvent):void
		{
			// move the center button to where ever the mouse is
			center = globalToLocal(new Point(event.stageX, event.stageY));
			adjustBtnByRotation(center, centerBtn);
		}


		/**
		 * Mouse move handler function
		 * @param The mouse click event
		 */
		private function onMouseMove(event:MouseEvent):void
		{
			// get the center point
			var gp:Point = (event.altKey) ? ctrp2 : ctrp1;

			// calculate the new location
			var p:Point = totalMatrixInversion.transformPoint(new Point(_parentContainer.mouseX, _parentContainer.mouseY));
			currentMatrix.identity();
			p.x = (gp.x - p.x);
			p.y = (gp.y - p.y);

			// alter the element's location
			currentMatrix.translate(-p.x, -p.y);
			currentMatrix.concat(totalMatrix);
			addTransformation(currentMatrix);

			// update the selection box and dispatch an event
			redrawSelectionBox();
			dispatchEvent(new TransformLayerEvent(TransformLayerEvent.TRANSFORM_COMMIT, matrices, _elements, getCurrentRect(), cMode));
		}
		
		/**
		 * Moves the elements the amount specified from the current position
		 * @param moveX
		 * @param moveY
		 */
		public function nudge(moveX:Number, moveY:Number):void
		{
			if(elements)
			{
				matrices = getTransformations();
				
				// alter the element's location
				currentMatrix.identity();
				currentMatrix.translate(moveX, moveY);
				currentMatrix.concat(totalMatrix);
				addTransformation(currentMatrix);
				
				// update the selection box and dispatch an event
				redrawSelectionBox();
				dispatchEvent(new TransformLayerEvent(TransformLayerEvent.TRANSFORM_FINISH, matrices, _elements, getCurrentRect(), TransformMode.MODE_NUDGE));
			}
		}
		
		/**
		 * Moves the elements to the specified point
		 * @param p
		 */
		public function moveTo(p:Point):void
		{
			if(elements)
			{
				matrices = getTransformations();
				
				// alter the element's location
				currentMatrix.identity();
				currentMatrix.tx = p.x;
				currentMatrix.ty = p.y;
				addTransformation(currentMatrix);
				
				// update the selection box and dispatch an event
				redrawSelectionBox();
				dispatchEvent(new TransformLayerEvent(TransformLayerEvent.TRANSFORM_FINISH, matrices, _elements, getCurrentRect(), TransformMode.MODE_MOVETO));
			}
		}

		/**
		 * 
		 * @param axis
		 */
		public function flip(axis:String):void
		{
			if(elements)
			{
				matrices = getTransformations();
				
				var gp:Point = totalMatrixInversion.transformPoint(_parentContainer.globalToLocal(localToGlobal(center)));
				
				currentMatrix.identity();
				currentMatrix.translate(-gp.x, -gp.y);			
				currentMatrix.scale((axis == TransformFlip.HORIZONTAL || axis == TransformFlip.BOTH) ? -1 : 1, (axis == TransformFlip.VERTICAL || axis == TransformFlip.BOTH) ? -1 : 1);
				currentMatrix.translate(gp.x, gp.y);
				currentMatrix.concat(totalMatrix);
				addTransformation(currentMatrix);
				
				redrawSelectionBox();
				dispatchEvent(new TransformLayerEvent(TransformLayerEvent.TRANSFORM_FINISH, matrices, _elements, getCurrentRect(), TransformMode.MODE_FLIP));
			}
		}

		/**
		 * Rotate handling function
		 * @param The mouse click event
		 */
		private function onMouseRotate(event:MouseEvent):void
		{
			var gp:Point = (event.altKey) ? ctrp1.clone() : ctrp2.clone();
			var ms:Point = new Point(event.stageX - gp.x, event.stageY - gp.y);
			var md:Point = new Point(globalMdt.x - gp.x, globalMdt.y - gp.y);

			var alfa:Number = Math.atan2(md.x * ms.y - md.y * ms.x, md.x * ms.x + md.y * ms.y);

			if(event.shiftKey)
			{
				alfa = -(Math.PI * (-(int(Math.floor(4 * (alfa) / Math.PI))) + 3)) / 4;
			}

			rotate(alfa, gp);

			redrawSelectionBox(event.altKey);
			dispatchEvent(new TransformLayerEvent(TransformLayerEvent.TRANSFORM_COMMIT, matrices, _elements, getCurrentRect(), cMode));
		}	

		/**
		 * Public function to rotate the elements
		 * @param angle The angle by which to rotate the elements
		 */
		public function rotateElements(angle:Number, fromOrigin:Boolean = false):void
		{
			if(elements)
			{
				matrices = getTransformations();
				rotate(angle * (Math.PI / 180), localToGlobal(center), fromOrigin);

				redrawSelectionBox(false);
				dispatchEvent(new TransformLayerEvent(TransformLayerEvent.TRANSFORM_FINISH, matrices, _elements, getCurrentRect(), TransformMode.MODE_ROTATE));
			}
		}
		
		private function rotate(angle:Number, anchor:Point, fromOrigin:Boolean = false):void
		{
			var m:Matrix = _parentContainer.transform.concatenatedMatrix.clone();
			m.tx = _parentContainer.transform.matrix.tx;
			m.ty = _parentContainer.transform.matrix.ty;

			anchor = m.transformPoint(_parentContainer.globalToLocal(anchor));

			var localMatrix:Matrix = new Matrix();			
			localMatrix.translate(-anchor.x, -anchor.y);
			
			if (fromOrigin)
			{
				if (localMatrix.a < 0)
				{			
					localMatrix.scale(-1, 1);
				}
				
				if (localMatrix.d < 0)
				{			
					localMatrix.scale(1, -1);
				}
				
				localMatrix.rotate(-(getCurrentRotation()));			
			}
			
			localMatrix.rotate(angle);
			localMatrix.translate(anchor.x, anchor.y);

			currentMatrix = totalMatrix.clone();
			currentMatrix.concat(m);
			currentMatrix.concat(localMatrix);
			m.invert();
			currentMatrix.concat(m);

			addTransformation(currentMatrix);
		}


		/**
		 * Y scale handling function
		 * @param The mouse click event
		 */
		private function onMouseScaleY(event:MouseEvent):void
		{
			var gp:Point = (event.altKey) ? ctrp2 : ctrp1;
			var p:Point = totalMatrixInversion.transformPoint(new Point(_parentContainer.mouseX, _parentContainer.mouseY));

			currentMatrix.identity();
			p.y = (gp.y - p.y) / (gp.y - mdt.y);

			currentMatrix.translate(0, -gp.y);
			currentMatrix.scale(1, p.y);
			currentMatrix.translate(0, gp.y);
			currentMatrix.concat(totalMatrix);
			addTransformation(currentMatrix);

			redrawSelectionBox(!event.altKey);
			dispatchEvent(new TransformLayerEvent(TransformLayerEvent.TRANSFORM_COMMIT, matrices, _elements, getCurrentRect(), cMode));
		}


		/**
		 * X scale handling function
		 * @param The mouse click event
		 */
		private function onMouseScaleX(event:MouseEvent):void
		{
			var gp:Point = (event.altKey) ? ctrp2 : ctrp1;
			var p:Point = totalMatrixInversion.transformPoint(new Point(_parentContainer.mouseX, _parentContainer.mouseY));

			currentMatrix.identity();
			p.x = (gp.x - p.x) / (gp.x - mdt.x);

			currentMatrix.translate(-gp.x, 0);
			currentMatrix.scale(p.x, 1);
			currentMatrix.translate(gp.x, 0);
			currentMatrix.concat(totalMatrix);

			addTransformation(currentMatrix);

			redrawSelectionBox(!event.altKey);
			dispatchEvent(new TransformLayerEvent(TransformLayerEvent.TRANSFORM_COMMIT, matrices, _elements, getCurrentRect(), cMode));
		}


		/**
		 * X and Y scale handling function
		 * @param The mouse click event
		 */
		private function onMouseScale(event:MouseEvent):void
		{
			var gp:Point = (event.altKey) ? ctrp2 : ctrp1;
			var p:Point = totalMatrixInversion.transformPoint(new Point(_parentContainer.mouseX, _parentContainer.mouseY));

			currentMatrix.identity();
			p.x = (gp.x - p.x) / (gp.x - mdt.x);
			p.y = (gp.y - p.y) / (gp.y - mdt.y);

			if((scaleProportional && !event.shiftKey) || (!scaleProportional && event.shiftKey))
			{
				p.x = Math.min(p.x, p.y);
				p.y = p.x;
			}

			currentMatrix.translate(-gp.x, -gp.y);
			currentMatrix.scale(p.x, p.y);
			currentMatrix.translate(gp.x, gp.y);
			currentMatrix.concat(totalMatrix);
			addTransformation(currentMatrix);

			redrawSelectionBox(!event.altKey);
			dispatchEvent(new TransformLayerEvent(TransformLayerEvent.TRANSFORM_COMMIT, matrices, _elements, getCurrentRect(), cMode));
		}

		/**
		 * Public function to scale the elements
		 * @param x The scale along the x axis
		 * @param y The scale along the y axis
		 */
		public function scale(x:Number = 1, y:Number = 1, byBoundingBox:Boolean = false):void
		{
			if(elements)
			{				
				var changed:Boolean = false;
				if (byBoundingBox && !_identityBounds)
				{
					_identityBounds = true;
					changed = true;
					updateTransformMatrix();
				}
				
				matrices = getTransformations();
				
				currentMatrix.identity();
				currentMatrix.scale(x, y);
				currentMatrix.concat(totalMatrix);
				addTransformation(currentMatrix);
				
				if (byBoundingBox && changed)
				{
					_identityBounds = false;
					updateTransformMatrix();
				}
				
				redrawSelectionBox();
				dispatchEvent(new TransformLayerEvent(TransformLayerEvent.TRANSFORM_FINISH, matrices, _elements, getCurrentRect(), TransformMode.MODE_SCALE));
			}
		}


		/**
		 * X skew handling function
		 * @param The mouse click event
		 */
		private function onMouseSkewX(event:MouseEvent):void
		{
			var gp:Point = (event.altKey) ? ctrp1 : ctrp2;
			var p:Point = totalMatrixInversion.transformPoint(new Point(_parentContainer.mouseX, _parentContainer.mouseY));

			currentMatrix.a = currentMatrix.d = 1;
			currentMatrix.b = currentMatrix.c = 0;
			currentMatrix.tx = -gp.x;
			currentMatrix.ty = -gp.y;
			currentMatrix.concat(new Matrix(1, 0, -(p.x - mdt.x) / (gp.y - mdt.y), 1));
			currentMatrix.translate(gp.x, gp.y);
			currentMatrix.concat(totalMatrix);

			addTransformation(currentMatrix);

			redrawSelectionBox(event.altKey);
			dispatchEvent(new TransformLayerEvent(TransformLayerEvent.TRANSFORM_COMMIT, matrices, _elements, getCurrentRect(), cMode));
		}


		/**
		 * Y skew handling function
		 * @param The mouse click event
		 */
		private function onMouseSkewY(event:MouseEvent):void
		{
			var gp:Point = (event.altKey) ? ctrp1 : ctrp2;
			var p:Point = totalMatrixInversion.transformPoint(new Point(_parentContainer.mouseX, _parentContainer.mouseY));

			currentMatrix.a = currentMatrix.d = 1;
			currentMatrix.b = currentMatrix.c = 0;
			currentMatrix.tx = -gp.x;
			currentMatrix.ty = -gp.y;
			currentMatrix.concat(new Matrix(1, (mdt.y - p.y) / (gp.x - mdt.x)));
			currentMatrix.translate(gp.x, gp.y);
			currentMatrix.concat(totalMatrix);

			addTransformation(currentMatrix);

			redrawSelectionBox(event.altKey);
			dispatchEvent(new TransformLayerEvent(TransformLayerEvent.TRANSFORM_COMMIT, matrices, _elements, getCurrentRect(), cMode));
		}


		/**
		 * public function to skew the elements
		 * @param skewX The skew value along the x axis
		 * @param skewY The skew value along the y axis
		 */
		public function skew(skewX:Number = 0, skewY:Number = 0, fromOrigin:Boolean = false):void
		{
			if(elements)
			{
				matrices = getTransformations();

				var px:Point = new Point(Point.interpolate(bottomRight, bottomLeft, 0.5).x, Point.interpolate(bottomRight, bottomLeft, 0.5).y);
				px = localToGlobal(px);
				px = totalMatrixInversion.transformPoint(_parentContainer.globalToLocal(px));
				
				var py:Point = new Point(Point.interpolate(topLeft, bottomLeft, 0.5).x, Point.interpolate(topLeft, bottomLeft, 0.5).y);
				py = localToGlobal(py);
				py = totalMatrixInversion.transformPoint(_parentContainer.globalToLocal(py));
				
				currentMatrix.identity();

				if (fromOrigin)
				{
					var tm:Matrix = removeRotation(totalMatrix);
					var d:Number = tm.d;
					var sd:Number = (-(Math.tan(skewX) * ((d < 0) ? d *= -1 : d)) - tm.c) / tm.a;
					
					//var a:Number = tm.a;
					//var sa:Number = (-(Math.tan(skewY) * ((a < 0) ? a *= -1 : a)) - tm.b) / tm.d;
					
					currentMatrix.translate(-px.x, -px.y);
					currentMatrix.concat(new Matrix(1, 0, sd, 1));
					currentMatrix.translate(px.x, px.y);
					//currentMatrix.translate(-py.x, -py.y);
					//currentMatrix.concat(new Matrix(1, sa));
					//currentMatrix.translate(py.x, py.y);
				}
				else
				{
					currentMatrix.translate(-px.x, -px.y);
					currentMatrix.concat(new Matrix(1, 0, -skewX, 1));
					currentMatrix.translate(px.x, px.y);
					currentMatrix.translate(-py.x, -py.y);
					currentMatrix.concat(new Matrix(1, -skewY));
					currentMatrix.translate(py.x, py.y);
				}
							
				currentMatrix.concat(totalMatrix);			
				addTransformation(currentMatrix);
				
				redrawSelectionBox();
				dispatchEvent(new TransformLayerEvent(TransformLayerEvent.TRANSFORM_FINISH, matrices, _elements, getCurrentRect(), TransformMode.MODE_SKEW));
			}
		}
	}
}