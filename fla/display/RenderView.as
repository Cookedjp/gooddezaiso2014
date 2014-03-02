package display
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.ui.Keyboard;
	
	public class RenderView extends Sprite
	{
		private var source:Sprite;
		private var canvas:Bitmap;
		
		
		private var divideLevel:int = 1;
		private var shiftX:Number = 100;
		
		private var mode:int = 0;
		
		
		public function RenderView(src:Sprite, cnvs:Bitmap)
		{
			super();
			source = src;
			// 字幕が更新されると呼ばれる
			source.addEventListener( "UPDATE_JIMAKU", onUpdateJimaku );
			canvas = cnvs;
//			addChild( canvas );
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
			if(!e.shiftKey) return;
			mode += 1;
			
			if(mode==2){
				mode = 0
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
			if(shiftX>canvas.width){
				shiftX = canvas.width
			}else if(shiftX<-canvas.width){
				shiftX = -canvas.width
			}
			capture();
		}
		
		
		private function onUpdateJimaku(e:Event):void
		{
			trace("字幕が更新されました")
			
			capture();
		}
		
		
		private function capture():void
		{
			
			canvas.bitmapData.lock();
			canvas.bitmapData.draw( source );
			canvas.bitmapData.unlock();

			
			
			var matShiftX:Matrix = new Matrix();
			matShiftX.translate( shiftX, 0);
			var matrix:Matrix = new Matrix()
			matrix.scale( 1/divideLevel, 1/divideLevel);
			matrix.concat(matShiftX);
			graphics.clear();
			graphics.beginBitmapFill( canvas.bitmapData, matrix, true);
			graphics.drawRect( 0, 0, canvas.width, canvas.height);
			
			
			
		}
	}
}