package
{
	import flash.display.Loader;
	import flash.display.NativeWindow;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import display.DezaisoUIKit;
	
	import item.ItemNode;
	
	import model.ConfigModel;
	
	import org.libspark.thread.EnterFrameThreadExecutor;
	import org.libspark.thread.Thread;
	
	public class gooddezair3 extends Sprite
	{
		private const DUMMY_MAX_WIDTH:Number = 200;
		
		private var d_textfield: TextField;
		private var t_meta: TextField;
		private var d_wrapper: Sprite;
		private var _currentTargetNumber: int = 0;
		
		
		
		public function get currentTargetNumber():int
		{
			return _currentTargetNumber;
		}
		
		private var _slideTimer:Timer = null;
		private var _viewAreaRectangle:Rectangle;
		
		private var ui:DezaisoUIKit;
		
		private var _random:Boolean;

		public function get jimakuLength():int{
			return configModel.csvObjList.length;
		}

		public function get random():Boolean
		{
			return _random;
		}
		
		public function set random(value:Boolean):void
		{
			_random = value;
		}
		
		
		
		
		/**
		 * 
		 * 
		 */
		public function gooddezair3()
		{
			addEventListener( Event.ADDED_TO_STAGE, init );
		}
		
		
		
		/**
		 * 
		 * @param e
		 * 
		 */
		private function init(e:Event):void
		{
			// ステージ設定
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			
			_viewAreaRectangle = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			var win:NativeWindow = stage.nativeWindow;
			win.alwaysInFront = true;
			var screenWidth:int =  Capabilities.screenResolutionX;
			var screenHeight:int =  Capabilities.screenResolutionY;
			win.width = screenWidth;
			win.height = screenHeight;
			win.x = (screenWidth - win.width) / 2;
			win.y = (screenHeight - win.height) / 2;
			
			Thread.initialize( new EnterFrameThreadExecutor() );
			configModel = new ConfigModel();
			configModel.start();
			configModel.dispacher.addEventListener(Event.COMPLETE, startContent);
		}
		
		var configModel:ConfigModel;
		
		/**
		 * コンフィグを読み込みおわったらコンテンツを開始 
		 * @return 
		 * 
		 */		
		private function startContent(e:Event){
			trace("COMPLETE LOADING")
			creatingTextField();
			
			appStart(configModel.settingXML);

		}
		
			
		
		
		
		private function creatingTextField():void
		{
			trace('creatingTextField : '+configModel.fontName);
			var format:TextFormat = new TextFormat( configModel.fontName, 24, 0xffffff, true );
			format.align = TextFormatAlign.CENTER;
			format.leading = 5;
			
			
			d_textfield = new TextField();
			d_textfield.embedFonts = true;
			d_textfield.defaultTextFormat = format;
			d_wrapper = new Sprite();
			addChild( d_wrapper );
			d_wrapper.addChild(d_textfield);
			d_textfield.wordWrap = false;
			d_textfield.selectable = false;
			d_textfield.width=DUMMY_MAX_WIDTH;
			d_textfield.filters = [new DropShadowFilter(0, 0, 0x0, 0.75, 8, 8)];
			d_textfield.mouseEnabled = false;
			
			
			// meta
			var formatMeta:TextFormat = new TextFormat( configModel.fontName, 18, 0xffffff, true );
			t_meta = new TextField();
			t_meta.embedFonts = true;
			t_meta.multiline = false;
			t_meta.width = stage.stageWidth;
			t_meta.wordWrap = false;
			t_meta.defaultTextFormat = formatMeta;
			addChild( t_meta );
			t_meta.x = 0;
			t_meta.y = stage.stageHeight-75;
			t_meta.selectable = false;
			t_meta.filters = [new DropShadowFilter(0, 0, 0x0, 0.75, 8, 8)];
		}
		
		
		
		
		private var APP_SETTINGS:XML;
		
		
		/**
		 * アプリを起動する 
		 * @return 
		 * 
		 */		
		private function appStart(settings:XML=null):void{
			
			APP_SETTINGS = settings;
			_slideTimer = new Timer(15000);
			_slideTimer.start();
			_slideTimer.addEventListener( TimerEvent.TIMER, showTextAsTimerEvent );
			
			ui = new DezaisoUIKit(this);
			showJimaku(0);
			addChild( ui );
			if(settings){
				if(settings.transparent=="1"){
					ui.transparentSlider.value = Number(settings.transparent);	
					ui.onChangeTransparent(null);
				}
				if(settings.showui && String(settings.showui) == "0"){
					ui.doClose(null);
					Mouse.hide();
					
				}
				if(settings.interval){
					ui.intervalSlider.value = Number(settings.interval);
					ui.onChangeInterval(null);
				}
				if(settings.fullscreen=="1"){
					stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				}
				return;
			}
		}
		
		
		/**
		 * 
		 * @param e
		 * 
		 */
		
		private function showTextAsTimerEvent(e:TimerEvent):void
		{
			if(_currentBlankTime>0){
				d_textfield.visible = false;
				t_meta.visible = false;
				_slideTimer.stop();
				setTimeout(doResume, _currentBlankTime);
				return;
			}
			
			if(_random){
				_currentTargetNumber = Math.random()*configModel.csvObjList.length;
				
			}else{
				_currentTargetNumber = (_currentTargetNumber<configModel.csvObjList.length-1)? _currentTargetNumber+1:0;
			}
			
			showJimaku(_currentTargetNumber);
			dispatchEvent( new Event("JIMAKU_COUNT_UP"));
			
		}
		
		private function doResume():void
		{
			d_textfield.visible = true;
			t_meta.visible = true;
			
			
			if(_random){
				_currentTargetNumber = Math.random()*configModel.csvObjList.length;
				
			}else{
				_currentTargetNumber = (_currentTargetNumber<configModel.csvObjList.length-1)? _currentTargetNumber+1:0;
			}
			showJimaku( _currentTargetNumber );
			dispatchEvent( new Event("JIMAKU_COUNT_UP"));
			
			
			_slideTimer.start();
		}
		
		
		private function convSentence(theStc, oldKey, convKey) {
			var sentence_array:Array = new Array();
			sentence_array = theStc.split(oldKey);
			return sentence_array.join(convKey);
		};
		
		
		/* API */
		public function showJimaku(count:int):void
		{	
			_viewAreaRectangle = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
			
			_currentTargetNumber = count;
			var n:ItemNode = configModel.csvObjList[_currentTargetNumber];	
			
			var sw = _viewAreaRectangle.width * 0.9;
			var sh = _viewAreaRectangle.height* 0.9;
			
			d_wrapper.scaleX = d_wrapper.scaleY = 1;
			d_textfield.text = convSentence(n.text, "\\n", "\n");;
			d_textfield.width = d_textfield.textWidth+10;
			d_textfield.multiline=false;
			d_textfield.scaleX = 1;
			d_textfield.scaleY = 1;
			d_textfield.height = d_textfield.textHeight+10;
			
			
			var percent:Number = (sw/d_textfield.textWidth);
			d_wrapper.scaleX = percent;
			d_wrapper.scaleY = percent;
			
			if(d_wrapper.height>sh){
				percent = (sh/d_textfield.textHeight);
				d_wrapper.scaleY = percent;
				d_wrapper.scaleX = percent;
			}
			
			if(d_wrapper.width>sw){
				percent = (sw/d_textfield.textWidth);
				d_wrapper.scaleY = percent;
				d_wrapper.scaleX = percent;
			}
			
			
			d_wrapper.x = int((stage.stageWidth-d_wrapper.width)/2);
			d_wrapper.y = int((stage.stageHeight-(d_textfield.textHeight*percent))/2);
			
			var date:Date = new Date(n.datestr);
			var current:Number = new Date().time;
			var diff:Number = (current - date.time);
			var relativeDay:int = diff/(1000*60*60*24);
			var relativeDayHour:int = (diff/(1000*60*60))-(relativeDay*24);			
			var relativeDayHourMin:int =  ((diff-((relativeDay*24*60*60*1000)+(relativeDayHour*60*60*1000)))/1000)/60;
			
			var awardName:String = n.level;
			if(awardName){
				awardName += "\n";
			}
			t_meta.text = awardName + n.id+"（"+relativeDay+"日"+relativeDayHour+"時間"+relativeDayHourMin+"分前に投稿） ";
			t_meta.x = _viewAreaRectangle.x + 20;
			t_meta.y = _viewAreaRectangle.y + _viewAreaRectangle.height - t_meta.textHeight - 20;
			
		}
		
		
		/**
		 * 表示領域を変更
		 * @param rectangle
		 * 
		 */		
		public function playJimaku():void
		{
			if(_slideTimer.running){
				return;
			}else{
				_slideTimer.start();
			}
		}
		
		public function stopJimaku():void
		{
			if(_slideTimer.running){
				_slideTimer.stop();
			}else{
				return;
			}
		}
		
		public function bgTranspartent(t:Boolean, v:Number, c:uint):void
		{
			if(t){
				graphics.clear();
				graphics.beginFill(c, v);
				graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
				graphics.endFill();
			}else{
				graphics.clear();			
			}
		}
		
		public function changeInterval(v:Number):void
		{
			var current = _slideTimer.currentCount;
			_slideTimer.delay = v;
		}
		
		public function textShadow(c:uint, b:Boolean){
			
			d_textfield.textColor = c;
			t_meta.textColor = c;
			
			var shadowCol:uint = (c===0x0)? 0xffffff:0x0;
			
			if(b){
				var f:Array =  [new DropShadowFilter(0, 0, shadowCol, 0.75, 8, 8)];
				d_textfield.filters = f;
				t_meta.filters = f;
			}else{
				d_textfield.filters = null;
				t_meta.filters = null;
			}
		}
		
		private var _currentBlankTime:Number = 0;
		
		public function setBlankInterval(n:Number):void
		{
			trace('setBlankInterval', n);
			_currentBlankTime = n;
		}
		
	}
}
