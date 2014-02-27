package display
{
	import flash.display.Sprite;
	import flash.events.ActivityEvent;
	import flash.events.Event;
	import flash.media.Camera;
	import flash.media.Video;
	
	public class CameraSprite extends Sprite
	{
		private var _cam:Camera;
		private var _vid:Video;
		
		public function CameraSprite()
		{
			_cam = Camera.getCamera();
			if (_cam!=null) {
				//イベントリスナーの指定
				_cam.addEventListener(ActivityEvent.ACTIVITY,activityHandler);
				_cam.setMode( 640, 480, 30);
				
				//ビデオの生成
				_vid = new Video(640,480);
				_vid.attachCamera(_cam);
			}
		}
	
		private function activityHandler(e:Event):void
		{
			
		}
		
		
		public function start():void
		{
			addChild(_vid);
			_vid.x=0;
			_vid.y=0;
			stage.addEventListener( Event.RESIZE, doResizeVideo );
			doResizeVideo();
		}
		
		
		public function stop():void
		{
			stage.removeEventListener( Event.RESIZE, doResizeVideo );
			removeChild(_vid);
		}
		
		private function doResizeVideo(e:Event=null):void
		{
			_vid.width = stage.stageWidth;
			_vid.scaleY = _vid.scaleX;
			if(_vid.height<stage.stageHeight)
			{
				_vid.height = stage.stageHeight;
				_vid.scaleX = _vid.scaleY;
			}
			_vid.x = (stage.stageWidth-_vid.width) / 2;
			_vid.y = (stage.stageHeight-_vid.height) / 2;
		}
		
	}
}