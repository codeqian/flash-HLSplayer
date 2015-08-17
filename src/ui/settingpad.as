package ui
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import events.progressEvent;
	
	import ui.progress_v;
	
	public class settingpad extends MovieClip
	{
		private var ParentMc:*;
		private var GProgress:progress_v=new progress_v();
		private var BProgress:progress_v=new progress_v();
		public function settingpad(_parent:*)
		{
			ParentMc=_parent;
			closeBtn.addEventListener(MouseEvent.CLICK,btnClick);
			btn43.addEventListener(MouseEvent.CLICK,btnClick);
			btn169.addEventListener(MouseEvent.CLICK,btnClick);
			CDefault.addEventListener(MouseEvent.CLICK,btnClick);
			BDefault.addEventListener(MouseEvent.CLICK,btnClick);
			GProgress.addEventListener(progressEvent.PROGRESS_CHANGE,progressChangeC);
			BProgress.addEventListener(progressEvent.PROGRESS_CHANGE,progressChangeB);
			
			setCpre(50);
			setBpre(50);
			addChild(BProgress);
			BProgress.x=85;
			BProgress.y=100;
			BProgress.rotation=-90;
			addChild(GProgress);
			GProgress.x=85;
			GProgress.y=146;
			GProgress.rotation=-90;
		}
		
		/**
		 *按钮事件 
		 * @param e
		 * 
		 */		
		private function btnClick(e:MouseEvent):void{
			switch(e.target.name){
				case "closeBtn":
					this.visible=false;
					break;
				case "btn43":
					changeScreen(false);
					break;
				case "btn169":
					changeScreen(true);
					break;
				case "CDefault":
					setCpre(50);
					changeContrast(50);
					break;
				case "BDefault":
					setBpre(50);
					changeBrightness(50);
					break;
				default:
					break;
			}
		}
		
		/**
		 *改变画面比例 
		 * @param wild
		 * 
		 */		
		private function changeScreen(wild:Boolean):void{
			ParentMc.changeScreen(wild);
		}
		
		/**
		 *改变亮度
		 * @param wild
		 * 
		 */		
		private function changeBrightness(pec:int):void{
			ParentMc.set_brightness((pec-50)*255/50);
		}
		
		/**
		 *改变对比度 
		 * @param wild
		 * 
		 */		
		private function changeContrast(pec:int):void{
			ParentMc.set_contrast(pec*255/100);
		}
		
		/**
		 *设置进度条 
		 * @param pec
		 * @return 
		 * 
		 */		
		public function setBpre(pec:int){
			BProgress.setProgress(pec);
		}
		
		public function setCpre(pec:int){
			GProgress.setProgress(pec);
		}
		
		private function progressChangeB(e:progressEvent){
			changeBrightness(e._pec);
		}
		
		private function progressChangeC(e:progressEvent){
			changeContrast(e._pec);
		}
	}
}