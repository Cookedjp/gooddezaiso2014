package item
{
	public class ItemNode
	{
		private var _level:String = "";
		
		public function get level():String
		{
			return _level;
		}
		
		private var _text:String = "";
		
		public function get text():String
		{
			return _text;
		}
		
		private var _id:String = "";
		
		public function get id():String
		{
			return _id;
		}
		
		private var _datestr:String = "";
		
		public function get datestr():String
		{
			return _datestr;
		}
		
		public function ItemNode(str:String){
			var arr:Array = str.split(',');
			_level = arr[0];
			_text = arr[1];
			_id = arr[2];
			_datestr = arr[3];
		}
	}
}