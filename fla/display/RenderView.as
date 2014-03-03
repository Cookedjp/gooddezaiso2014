package display
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.utils.flash_proxy;

	/**
	 * 
	 * @author hgw
	 *
	 * 0: reset
	 * F: Fullscreen
	 * shift: mode change 
	 * 	- mode 1: divide screen
	 * 	- mode 2: shift content
	 * 	- mode 3: toggle color mode
	 */	
	public class RenderView extends Sprite
	{
		private var source:Sprite;
		private var canvas:Bitmap;

		private var shiftTimer:Timer;
		
		private var divideLevel:int = 1;
		


		private function resetAll():void{
			shiftX = 0;
			divideLevel = 1;
			colorModeWhite = false;
			

			shiftTimer.removeEventListener(TimerEvent.TIMER, onUpdateShiftVector)
			shiftX = 0;
			shiftY = 0;
			vectorX = 0;
			vectorY = 0;
			capture();
		}
		
		
		public function RenderView(src:Sprite, cnvs:Bitmap)
		{
			super();
			source = src;
			// 字幕が更新されると呼ばれる
			source.addEventListener( "UPDATE_JIMAKU", onUpdateJimaku );
			canvas = cnvs;
			addEventListener( Event.ADDED_TO_STAGE, onStageDetected );
			
			shiftTimer = new Timer( 1000/24 );
			shiftTimer.start();
		}
		
		private function onStageDetected(e:Event):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, onStageDetected );
			stage.addEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyChange );
		}
		
		
		/**
		 * 
		 * @param e
		 * 
		 */		
		private function onKeyChange(e:KeyboardEvent):void
		{
			
			// 反転コマンドを判別
			if(e.keyCode==Keyboard.I && e.commandKey){
				colorToggle(0);
			}
			
			// xyシフトの速度
			var shiftVal = (e.shiftKey)? 10:1;
			if(e.keyCode==Keyboard.RIGHT){
				
				updateShiftX( 1*shiftVal );
			}else if(e.keyCode==Keyboard.LEFT){
				updateShiftX( -1*shiftVal );
			}else if(e.keyCode==Keyboard.UP){
				updateShiftY( -1*shiftVal );
			}else if(e.keyCode==Keyboard.DOWN){
				updateShiftY( 1*shiftVal );
			}
			
			
			if(e.keyCode == Keyboard.NUMBER_0){
				resetAll();
				return;
			}
			if(e.keyCode == Keyboard.F){
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				return;
			}
			
			if(!e.shiftKey) return;
			capture();
		}
		
		/**
		 * 
		 * @param e
		 * 
		 */		
		private function onMouseWheel(e:MouseEvent):void
		{
			trace("updatePosition")

			if( Math.abs( e.delta ) < 1){
				return;
			}

			updateDivide(e.delta);
		}
		
		
		private var colorModeWhite:Boolean = false;
		private function colorToggle(delta:Number):void{
			colorModeWhite = !colorModeWhite;
			capture();
		}

		
		private function updateDivide(delta:Number):void{
			var newVal:int = divideLevel;
			
			if( delta < 0){
				newVal = divideLevel-1;
			}
			if(delta>0){
				newVal = divideLevel+1;
			}
			
			if(newVal>=1&&newVal<=20){
				divideLevel = newVal;
				capture();
			}

		}
		
		// --------------------------------------------------
		//
		//
		// SHIFT X, SHIFT Y
		//
		//
		// --------------------------------------------------
		/**
		 * SHIFT X
		 * @param delta
		 * 
		 */
		private var vectorX:Number = 0;
		private var shiftX:Number = 0;
		private function updateShiftX(value:Number):void{
			vectorX += value;
			shiftTimer.removeEventListener(TimerEvent.TIMER, onUpdateShiftVector)
			shiftTimer.addEventListener(TimerEvent.TIMER, onUpdateShiftVector)
		}

		/**
		 * SHIFT Y
		 * @param delta
		 * 
		 */		
		private var vectorY:Number = 0;
		private var shiftY:Number = 0;
		private function updateShiftY(value:Number):void{
			vectorY += value;
			shiftTimer.removeEventListener(TimerEvent.TIMER, onUpdateShiftVector)
			shiftTimer.addEventListener(TimerEvent.TIMER, onUpdateShiftVector)
		}
		
		private function onUpdateShiftVector(e:Event):void{
			shiftY += vectorY;
			shiftX += vectorX;
			capture()
		}
		

		
		
		
		
		
		// --------------------------------------------------
		//
		//
		//
		//
		//
		// --------------------------------------------------
		private function onUpdateJimaku(e:Event):void
		{
			trace("字幕が更新されました")
			
			capture();
		}
		
		
		private function capture():void
		{
			var colorTransform:ColorTransform = new ColorTransform();
			if(colorModeWhite){
				colorTransform = new ColorTransform(-1, -1, -1, 1, 255, 255, 255, 0);
			}
			
			canvas.bitmapData.lock();
			canvas.bitmapData.draw( source, null, colorTransform );
			canvas.bitmapData.unlock();

			
			
			var matrix:Matrix = new Matrix()
			matrix.scale( 1/divideLevel, 1/divideLevel);

			
			var rangewidth:Number = canvas.width/divideLevel;
			var rangeheight:Number = canvas.height/divideLevel;
				
				
			var matShift:Matrix = new Matrix();
			matShift.translate( shiftX % rangewidth, shiftY % rangeheight);
			matrix.concat(matShift);
			
			
			
			graphics.clear();
			graphics.beginBitmapFill( canvas.bitmapData, matrix, true);
			graphics.drawRect( 0, 0, canvas.width, canvas.height);
			
			
			
		}
	}
}