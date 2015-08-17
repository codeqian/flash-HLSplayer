package ui
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import events.progressEvent;

	public class progress_v extends MovieClip
	{
		public function progress_v()
		{
			progressPoint.addEventListener(MouseEvent.MOUSE_DOWN,start_Drag);
			progressPoint.addEventListener(MouseEvent.MOUSE_MOVE,move_Drag);
			progressPoint.addEventListener(MouseEvent.MOUSE_UP,stop_Drag);
			this.addEventListener(MouseEvent.ROLL_OUT,stop_Drag);
		}
		
		/**
		 * 开始拖动 
		 * @param e
		 * 
		 */		
		private function start_Drag(e:MouseEvent):void{
			progressPoint.startDrag(false,new Rectangle(-1,0,0,100));
		}
		
		/**
		 * 结束拖动 
		 * @param e
		 * 
		 */		
		private function stop_Drag(e:MouseEvent):void{
			progressPoint.stopDrag();
		}
		
		/**
		 * 移动滑块 
		 * @param e
		 * 
		 */
		private function move_Drag(e:MouseEvent):void{
			progressMask.height=progressPoint.y;
			dispatchEvent(new progressEvent(progressEvent.PROGRESS_CHANGE,progressPoint.y));
		}
		
		/**
		 * 设置进度 
		 * @param prc
		 * 
		 */		
		public function setProgress(prc:int):void{
			progressMask.height=prc;
			progressPoint.y=prc;
		}
	}
}