package model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.URLRequest;
	import flash.text.Font;
	
	import item.ItemNode;
	
	import org.libspark.thread.Thread;
	import org.libspark.thread.threads.display.LoaderThread;
	import org.libspark.thread.threads.net.URLLoaderThread;
	import org.libspark.thread.utils.EventDispatcherThread;
	import org.libspark.thread.utils.ParallelExecutor;
	
	public class ConfigModel extends Thread
	{
		private var parallelLoader:ParallelExecutor
		
		private var _fontName:String;
		private var _csvObjList:Vector.<ItemNode>;
		private var _settingXML:XML;

		private var _dispacher:EventDispatcher;
		
		public function get dispacher():EventDispatcher
		{
			return _dispacher;
		}

		public function get settingXML():XML
		{
			return _settingXML;
		}

		public function get csvObjList():Vector.<ItemNode>
		{
			return _csvObjList;
		}

		public function get fontName():String
		{
			return _fontName;
		}

		
		
		
		public function ConfigModel():void
		{
			
			parallelLoader = new ParallelExecutor();
			_dispacher = new EventDispatcher();
			
		}
		//最初に実行される実行関数です
		override protected function run():void 
		{
			// loader for fonts
			parallelLoader.addThread( new LoaderThread( new URLRequest("data/fonts/Ryobi.swf") ) );
			
			// loader for だじゃれ			
			parallelLoader.addThread( new URLLoaderThread( new URLRequest( './data/result2013.csv')  ) );
			
			// settings 			
			parallelLoader.addThread( new URLLoaderThread( new URLRequest("./data/settings.xml")  ) );

			parallelLoader.start();
			parallelLoader.join();
			next(completeLoading);
		}
		

		/**
		 * ローディングのスレッドが終了
		 * @return 
		 * 
		 */		
		public function completeLoading(){
			
			// font を登録
			var fontLoader:LoaderThread = parallelLoader.getThreadAt(0) as LoaderThread
			var FontClass:Class = fontLoader.loader.contentLoaderInfo.applicationDomain.getDefinition("Ryobi") as Class;
			Font.registerFont( FontClass );
			
			var font:Font = new FontClass();
			_fontName = font.fontName;

			
			// ダジャレリスト を登録
			var csvLoader:URLLoaderThread = parallelLoader.getThreadAt(1) as URLLoaderThread
			var csvParseList:Array = String(csvLoader.loader.data).split("\n");
			_csvObjList = new Vector.<ItemNode>();
			for(var i:int=0; i<csvParseList.length; i+=1){
				var n:ItemNode = new ItemNode(csvParseList[i]);
				_csvObjList.push( n );
			}
			
			var settingThread:URLLoaderThread = parallelLoader.getThreadAt(2) as URLLoaderThread
			var settingXML:XML = XML(settingThread.loader.data);

			this.dispacher.dispatchEvent( new Event(Event.COMPLETE) );
		}
		
		
		
	}
}