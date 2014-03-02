package display
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.ui.Keyboard;
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
		
		
		private var divideLevel:int = 1;
		private var shiftX:Number = 0;
		
		private var mode:int = 0;


		private function resetAll():void{
			mode = 0;
			shiftX = 0;
			divideLevel = 1;
			colorModeWhite = false;
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
		}
		
		private function onStageDetected(e:Event):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, onStageDetected );
			stage.addEventListener( MouseEvent.MOUSE_WHEEL, onMouseWheel );
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyChange );
		}
		
		
		private function onKeyChange(e:KeyboardEvent):void
		{
			if(e.keyCode == Keyboard.NUMBER_0){
				resetAll();
				return;
			}
			if(e.keyCode == Keyboard.F){
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				return;
			}
			
			if(!e.shiftKey) return;
			mode += 1;
			
			if(mode==3){
				mode = 0;
			}
			capture();
		}
		private function onMouseWheel(e:MouseEvent):void
		{
			trace("updatePosition")

			if( Math.abs( e.delta ) < 1){
				return;
			}

			if(mode==0){
				updateDivide(e.delta);
			}
			if(mode==1){
				updateShiftX(e.delta);
			}
			if(mode==2){
				colorToggle(e.delta);
			}
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
		
		
		private function updateShiftX(delta:Number):void{
			shiftX += delta*10;
			capture();
		}
		
		
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
				
				
			var matShiftX:Matrix = new Matrix();
			matShiftX.translate( shiftX % rangewidth, 0);
			matrix.concat(matShiftX);
			
			
			
			graphics.clear();
			graphics.beginBitmapFill( canvas.bitmapData, matrix, true);
			graphics.drawRect( 0, 0, canvas.width, canvas.height);
			
			
			
		}
	}
}