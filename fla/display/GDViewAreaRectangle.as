package display
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class GDViewAreaRectangle extends Sprite
	{
		
		private var point_t_l:Sprite;
		private var point_t_r:Sprite;
		private var point_b_l:Sprite;
		private var point_b_r:Sprite;
		
		private var points:Vector.<Sprite>;
		
		public function GDViewAreaRectangle(rect:Rectangle = null)
		{
			super();
			
			points = new Vector.<Sprite>(  );
			
			point_t_l = new Sprite();
			point_t_r = new Sprite();
			point_b_l = new Sprite();
			point_b_r = new Sprite();
			points.push( point_t_l );
			points.push( point_t_r );
			points.push( point_b_l );
			points.push( point_b_r );

			
			for(var i=0; i<points.length; i+=1){
				points[i].graphics.beginFill( 0xff0000 );
				points[i].graphics.drawCircle( 0, 0, 30 );
				points[i].graphics.endFill();
				points[i].alpha = 0.5;
				
				points[i].addEventListener( MouseEvent.MOUSE_DOWN, startDragAPoint );
				addChild( points[i] );
			}
			
			
			
			if(!rect){
			
				rect = new Rectangle(10, 10, 1024, 768);
			}
			
			this.setViewAreaRectangle( rect );
			
			
		}
		
		private var current_drag_point:Sprite;		
		
		private function startDragAPoint(e:MouseEvent){
			
			var point:Sprite = (e.target) as Sprite;
			point.startDrag();
			point.stage.addEventListener( MouseEvent.MOUSE_UP, stopDragAPoint );
			point.stage.addEventListener( MouseEvent.MOUSE_MOVE, moveDragAPoint );
			point.alpha = 0.8;
			current_drag_point = point;
		}
		
		private function stopDragAPoint(e:MouseEvent){
			for(var i=0; i<points.length; i+=1){
				points[i].stage.removeEventListener( MouseEvent.MOUSE_MOVE, moveDragAPoint );
				points[i].stage.removeEventListener( MouseEvent.MOUSE_UP, stopDragAPoint );
				points[i].stopDrag();
				current_drag_point = null;
				this.graphics.clear();
				points[i].alpha = 0.5;
			}
			
			
			this.dispatchEvent( new Event("POINT_UPDATE") ); 
		}
		
		
		
		private function moveDragAPoint(e:MouseEvent):void{
			switch(current_drag_point){
				
				case point_t_l:
					point_t_r.y = point_t_l.y;
					point_b_l.x = point_t_l.x;
					break;
				
				case point_t_r:
					point_t_l.y = point_t_r.y;
					point_b_r.x = point_t_r.x;
					break;
				
				case point_b_l:
					point_b_r.y = point_b_l.y;
					point_t_l.x = point_b_l.x;
					break;
				
				case point_b_r:
					point_b_l.y = point_b_r.y;
					point_t_r.x = point_b_r.x;
					break;
				
				default:
			}
			
			this.graphics.clear();
			this.graphics.beginFill( 0xff0000, 0.3);
			this.graphics.lineStyle( 1, 0xff0000, 0.7);
			this.graphics.drawRect( point_t_l.x, point_t_l.y, point_t_r.x - point_t_l.x, point_b_l.y-point_t_l.y );
			this.graphics.endFill();
		}
		
		
		public function getViewAreaRectangle():Rectangle{
			var r:Rectangle = new Rectangle( point_t_l.x, point_t_l.y, point_t_r.x - point_t_l.x, point_b_l.y-point_t_l.y );
			return r;
		}

		public function setViewAreaRectangle(rect:Rectangle):void{
			point_t_l.x = point_b_l.x = rect.x;			
			point_t_r.x = point_b_r.x = rect.x + rect.width;
			point_t_l.y = point_t_r.y = rect.y;
			point_b_l.y = point_b_r.y = rect.y + rect.height;			
		}
		
	}
}