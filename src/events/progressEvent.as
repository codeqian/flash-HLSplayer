package events
{
	import flash.events.Event;

	public class progressEvent extends Event
	{
		public static const PROGRESS_CHANGE:String = "progress_change";
		public var _pec:int;
		public function progressEvent(type:String, pec:int)
		{
			super(type);
			_pec = pec;
		}
	}
}