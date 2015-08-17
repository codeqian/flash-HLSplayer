package ui
{	
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import events.progressEvent;
	
	import ui.progress_v;

	public class ctrl_bar extends MovieClip
	{
		private var fs:Boolean = false;
		private var ParentMc:*;
		private var nameAr:Array=new Array("低清","标清","高清","自动");
		private var fmO:TextFormat = new TextFormat();
		private var fmW:TextFormat = new TextFormat();
		private var volProgress:progress_v=new progress_v();
		private var doubleclicktimer:Timer = new Timer(500, 1);
		public function ctrl_bar(_parent:*,_stage:Stage)
		{
			fmO.color = 0xf06000;
			fmW.color = 0xffffff;
			ParentMc=_parent;
			
			volPad.addChild(volProgress);
			volProgress.rotation=180;
			volProgress.x=10;
			volProgress.y=110;
			volProgress.addEventListener(progressEvent.PROGRESS_CHANGE,progressChange);
			
			volm_b.visible=false;
			nfull_b.visible=false;
			levelPad.levelA.addEventListener(MouseEvent.CLICK,btnClick);
			levelPad.level0.addEventListener(MouseEvent.CLICK,btnClick);
			levelPad.level1.addEventListener(MouseEvent.CLICK,btnClick);
			levelPad.level2.addEventListener(MouseEvent.CLICK,btnClick);
			vol_b.addEventListener(MouseEvent.CLICK,btnClick);
			volm_b.addEventListener(MouseEvent.CLICK,btnClick);
			full_b.addEventListener(MouseEvent.CLICK,btnClick);
			nfull_b.addEventListener(MouseEvent.CLICK,btnClick);
			level_b.addEventListener(MouseEvent.CLICK,btnClick);
			level_b.addEventListener(MouseEvent.ROLL_OVER,btnOver);
			vol_b.addEventListener(MouseEvent.ROLL_OVER,btnOver);
			volm_b.addEventListener(MouseEvent.ROLL_OVER,btnOver);
			levelPad.addEventListener(MouseEvent.ROLL_OUT,btnOut);
			volPad.addEventListener(MouseEvent.ROLL_OUT,btnOut);
			
			progress_bar.visible=false;
			levelPad.visible=false;
			volPad.visible=false;
			level_b.buttonMode=true;
			level_b.mouseChildren=false;
			levelPad.levelA.buttonMode=true;
			levelPad.level0.buttonMode=true;
			levelPad.level1.buttonMode=true;
			levelPad.level2.buttonMode=true;
			levelPad.levelA.mouseChildren=false;
			levelPad.level0.mouseChildren=false;
			levelPad.level1.mouseChildren=false;
			levelPad.level2.mouseChildren=false;
			
			_stage.addEventListener(MouseEvent.CLICK, this.OnForegroundClick);
			
			showLevel(-1);
		}
		
		/**
		 *显示目前的码率等级 
		 * @param index
		 * 
		 */		
		public function showLevel(index:int):void{
			levelPad.levelA.buttonName_t.setTextFormat(fmW);
			levelPad.level0.buttonName_t.setTextFormat(fmW);
			levelPad.level1.buttonName_t.setTextFormat(fmW);
			levelPad.level2.buttonName_t.setTextFormat(fmW);
			if(index==-1){
				level_b.level_t.text=nameAr[3];
				levelPad.levelA.buttonName_t.setTextFormat(fmO);
			}else{
				level_b.level_t.text=nameAr[index];
				levelPad["level"+index].buttonName_t.setTextFormat(fmO);
			}
		}
		
		/**
		 * 按钮移入事件 
		 * 
		 */
		private function btnOver(e:MouseEvent):void{
			switch(e.target.name){
				case "vol_b":
				case "volm_b":
					volPad.visible=true;
					levelPad.visible=false;
					break;
				case "level_b":
					levelPad.visible=true;
					volPad.visible=false;
					break;
				default:
					break;
			}
		}
			
		/**
		 * 按钮移出事件 
		 * 
		 */		
		private function btnOut(e:MouseEvent):void{
			switch(e.target.name){
				case "volPad":
					volPad.visible=false;
					break;
				case "levelPad":
					levelPad.visible=false;
					break;
				default:
					break;
			}
		}
		
		/**
		 * 按钮点击事件 
		 * @param e
		 * 
		 */		
		private function btnClick(e:MouseEvent):void{
			switch(e.target.name){
				case "full_b":
					fs = true;
					nfull_b.visible=true;
					full_b.visible=false;
					stage.displayState = StageDisplayState.FULL_SCREEN;
					break;
				case "nfull_b":
					fs = false;
					full_b.visible=true;
					nfull_b.visible=false;
					stage.displayState = StageDisplayState.NORMAL;
					break;
				case "vol_b":
					volm_b.visible=true;
					vol_b.visible=false;
					ParentMc._mute(true);
					break;
				case "volm_b":
					vol_b.visible=true;
					volm_b.visible=false;
					ParentMc._mute(false);
					break;
				case "level_b":
					if(levelPad.visible){
						levelPad.visible=false;
					}else{
						levelPad.visible=true;
					}
					break;
				case "levelA":
					levelPad.visible=false;
					changeL(-1);
					break;
				case "level0":
					levelPad.visible=false;
					changeL(0);
					break;
				case "level1":
					levelPad.visible=false;
					changeL(1);
					break;
				case "level2":
					levelPad.visible=false;
					changeL(2);
					break;
				default:
					break;
			}
		}
		
		/**
		 * 切换码率 
		 * @param index
		 * 
		 */		
		private function changeL(index:int):void{
			showLevel(index);
			levelPad.visible=false;
			ParentMc.changeLevel(index);
		}
		
		/**
		 * 设置音量 
		 * @param index
		 * 
		 */		
		private function changeVol(index:int):void{
			ParentMc.setVideoVolume(index);
		}
		
		/**
		 *重置界面 
		 * 
		 */		
		public function resizeUi(W:int,H:int):void{
			ctrl_bg.width=W;
			progress_bar.progressbg.width=W;
			levelPad.x=W-123;
			volPad.x=W-138;
			volm_b.x=W-140;
			vol_b.x=W-140;
			level_b.x=W-108;
			setting_b.x=W-60;
			nfull_b.x=W-30;
			full_b.x=W-30;
		}
		
		public function setProgress(index:int){
			volProgress.setProgress(index);
		}
		
		private function progressChange(e:progressEvent){
			changeVol(e._pec);
		}
		
		/**
		 * 全屏状态改变 
		 * @return 
		 * 
		 */		
		public function screenchanged(){
			if(stage.displayState == StageDisplayState.NORMAL){
				nfull_b.visible=false;
				full_b.visible=true;
			}else{
				nfull_b.visible=true;
				full_b.visible=false;
			}
		}
		
		/**
		 * 双击切换全屏 
		 * @param event
		 * 
		 */
		private function OnForegroundClick(e:MouseEvent) : void
		{
			if (this.doubleclicktimer.running)
			{
				this.doubleclicktimer.reset();
				this.doubleclicktimer.removeEventListener(TimerEvent.TIMER, this.OnClickTimer);
//				title_t.text=stage.displayState;
				if (stage && stage.displayState == StageDisplayState.NORMAL)
				{
					stage.displayState = StageDisplayState.FULL_SCREEN;
				}
				else
				{
					stage.displayState = StageDisplayState.NORMAL;
				}
			}
			else
			{
				this.doubleclicktimer.start();
				this.doubleclicktimer.addEventListener(TimerEvent.TIMER, this.OnClickTimer);
			}
		}
		
		/**
		 *单击 
		 * @param event
		 * 
		 */
		private function OnClickTimer(e:TimerEvent) : void
		{
			this.doubleclicktimer.reset();
			this.doubleclicktimer.removeEventListener(TimerEvent.TIMER, this.OnClickTimer);
		}
	}
}