package
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.media.SoundTransform;
	import flash.media.StageVideo;
	import flash.media.StageVideoAvailability;
	import flash.media.Video;
	import flash.system.Security;
	import flash.utils.Timer;
	
	import fl.motion.ColorMatrix;
	
	import org.mangui.hls.HLS;
	import org.mangui.hls.event.HLSEvent;
	
	import ui.ctrl_bar;
	import ui.settingpad;
	
	public class hlsPlayer extends Sprite
	{
		/**
		 * HLS流控制类
		 */		
		private var _hls:HLS;
		private var _stageVideo:StageVideo = null;
		private var _video:Video = null;
		private var _media_position:Number;
		private var _duration:Number;
		private var _autoLoad:Boolean = true;
		private var W:int;
		private var H:int;
		private var fullscreen:Boolean = true;
		private var autoplay:Boolean = false;
		public var playStatus:String = ""//播放状态
		private var playing:Boolean = false;
		/**
		 * 视频地址 
		 */		
		private var videoUrl:String="";
		/**
		 *视频标题 
		 */		
		private var vTitle:String="";
		/**
		 * 码率等级 
		 */		
		private var defaultLevel=-1;
		/**
		 * 隐藏控制栏的计时器 
		 */		
		private var ctrlHideTimer:Timer=new Timer(1000,5);
		/**
		 * 公共计时器 
		 */		
		private var uniTimer:Timer=new Timer(500,0);
		/**
		 * 默认音量 
		 */		
		private var defaultVol:int=50;
		private var st:SoundTransform = new SoundTransform();
		/**
		 *是否宽屏 
		 */		
		private var _wild:Boolean=true;
		/**
		 *舞台初始大小 
		 */		
		private var initW:int=550;
		private var initH:int=400;
		/**
		 * 亮度 
		 */		
		private var _bright:Number=0;
		/**
		 * 对比度 
		 */		
		private var _contrast:Number=128;
		
		//view
		private var ctrl_bar_v:ctrl_bar;
		private var buffing_logo_v=new buffing_logo();
		private var logo_v=new logo();
		private var buffing_ico_v=new buffing_ico();
		private var settingPad_v:settingpad;
		private var liveLogo_v=new liveLogo();
		//butten
		private var playBtn:SimpleButton;
		private var stopBtn:SimpleButton;
		private var pauseBtn:SimpleButton;
		private var setBtn:SimpleButton;
		private var playbigBtn:SimpleButton;
		public function hlsPlayer()
		{
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			_init_events();
		}

		/**
		 *初始化监听 
		 * 
		 */		
		private function _init_events():void
		{
			stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, _onStageVideoState);
			stage.addEventListener(Event.RESIZE, resizeEvent);
		}
		
		/**
		 * 初始化
		 * @param event
		 * 
		 */		
		private function _onStageVideoState(event : StageVideoAvailabilityEvent):void
		{
			var available : Boolean = (event.availability == StageVideoAvailability.AVAILABLE);
			//获得页面参数
			videoUrl = root.loaderInfo.parameters.vurl as String;
			autoplay=root.loaderInfo.parameters.autoplay == "1" ? (true) : (false);
			vTitle=root.loaderInfo.parameters.title;
			_hls = new HLS();
			_hls.stage = stage;
			_hls.addEventListener(HLSEvent.MANIFEST_LOADED, _manifestHandler);
			_hls.addEventListener(HLSEvent.MEDIA_TIME, _mediaTimeHandler);//当前播放回调
			_hls.addEventListener(HLSEvent.FRAGMENT_PLAYING, _fragmentPlayingHandler);//片段播放回调
			_hls.addEventListener(HLSEvent.PLAYBACK_STATE, _stateHandler);//当前状态回调
			stage.removeEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, _onStageVideoState);
			//是否以stage模式播放视频
//			if (available && stage.stageVideos.length > 0)
//			{
//				_stageVideo = stage.stageVideos[0];
//				_stageVideo.attachNetStream(_hls.stream);
//			}
//			else
//			{
				//初始化Video
				_video = new Video();
				addChild(_video);
				_video.smoothing = true;
				_video.attachNetStream(_hls.stream);
				changeVideoSize();
//			}
			if(videoUrl!="" && videoUrl!=null){
				loadVideo(videoUrl);
			}
			ctrl_bar_v=new ctrl_bar(this,stage);
			settingPad_v=new settingpad(this);
			addChild(buffing_logo_v);
			addChild(logo_v);
			addChild(ctrl_bar_v);
			addChild(buffing_ico_v);
			addChild(settingPad_v);
			addChild(liveLogo_v);
			//初始化按钮
			playBtn=ctrl_bar_v.play_b;
			pauseBtn=ctrl_bar_v.pause_b;
			stopBtn=ctrl_bar_v.stop_b;
			setBtn=ctrl_bar_v.setting_b;
			playbigBtn=ctrl_bar_v.playbig_b;
			
			settingPad_v.visible=false;
			pauseBtn.visible=false;
			stopBtn.visible=false;
			buffing_ico_v.visible=false;
			playBtn.visible=false;
			playbigBtn.visible=false;
			ctrl_bar_v.time_t.text="";
			ctrl_bar_v.stream_t.text="等待……";
			if(vTitle){
				ctrl_bar_v.title_t.text=vTitle;
			}
			
			playBtn.addEventListener(MouseEvent.CLICK,btnClick);
			playbigBtn.addEventListener(MouseEvent.CLICK,btnClick);
			pauseBtn.addEventListener(MouseEvent.CLICK,btnClick);
			stopBtn.addEventListener(MouseEvent.CLICK,btnClick);
			setBtn.addEventListener(MouseEvent.CLICK,btnClick);
			
			showOrHideCtrl(true);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseMoving);
			setVideoVolume(defaultVol);
			ctrl_bar_v.setProgress(defaultVol);
			initW=stage.stageWidth;
			initH=stage.stageHeight;
			_init_ui(stage.stageWidth,stage.stageHeight);
		}
		
		/**
		 *设置音量 
		 * @param percent
		 * 
		 */		
		public function setVideoVolume(percent:int):void
		{
			defaultVol=percent;
			st.volume = percent / 100;
			_hls.stream.soundTransform = st;
		}
		
		/**
		 * 设置静音 
		 * @return 
		 * 
		 */		
		public function _mute(m:Boolean):void
		{
			if(m){
				st.volume = 0;
			}else{
				st.volume = defaultVol / 100;
			}
			_hls.stream.soundTransform = st;
		}
		
		/**
		 * 初始化界面尺寸 
		 * @param W
		 * @param H
		 * @return 
		 * 
		 */		
		private function _init_ui(W,H)
		{
			this.W = W;
			this.H = H;
			buffing_logo_v.x=W/2;
			buffing_logo_v.y=H/2;
			buffing_ico_v.x=(W-buffing_ico_v.width)/2;
			buffing_ico_v.y=(H-buffing_ico_v.height)/2;
			settingPad_v.x=(W-settingPad_v.width)/2;
			settingPad_v.y=(H-settingPad_v.height)/2;
			var logoScale:Number=W/initW;
			logo_v.scaleX=logoScale;
			logo_v.scaleY=logoScale;
			logo_v.x=W-logo_v.width-4;
			logo_v.y=4;
			ctrl_bar_v.resizeUi(W,H);
			ctrl_bar_v.y=H-42;
		}
		
		/**
		 * 界面尺寸变化 
		 * @param e
		 * 
		 */		
		private function resizeEvent(e:Event):void
		{
			ctrl_bar_v.screenchanged();
			resizeUi();
		}
		private function resizeUi(){
			_init_ui(stage.stageWidth, stage.stageHeight);
			changeVideoSize();
		}
		
		
		/**
		 *播放视频(加载)
		 * @param url
		 * 
		 */		
		private function loadVideo(url:String):void{
			if (_autoLoad)
			{
				_hls.load(url);
				changeLevel(defaultLevel);
			}
		}
		
		/**
		 * 播放 
		 * @param position
		 * 
		 */		
		private function _play(position : Number = -1):void
		{
			playing=true;
			buffing_logo_v.visible=false;
			pauseBtn.visible=true;
			stopBtn.visible=true;
			playBtn.visible=false;
			playbigBtn.visible=false;
			_hls.stream.play(null, position);
		}
		
		/**
		 *暂停 
		 * 
		 */		
		private function _pause():void
		{
			playBtn.visible=true;
			playbigBtn.visible=true;
			pauseBtn.visible=false;
			_hls.stream.pause();
		}
		
		/**
		 *继续 
		 * 
		 */		
		protected function _resume():void//回放
		{
			playBtn.visible=false;
			playbigBtn.visible=false;
			pauseBtn.visible=true;
			_hls.stream.resume();
		}
		
		/**
		 * 快进 
		 * @param position
		 * 
		 */		
		private function _seek(position : Number):void
		{
			_hls.stream.seek(position);
		}
		
		/**
		 * 停止 
		 * 
		 */		
		private function _stop():void
		{
			playing=false;
			playBtn.visible=true;
			playbigBtn.visible=true;
			pauseBtn.visible=false;
			stopBtn.visible=false;
			buffing_logo_v.visible=true;
			_hls.stream.close();
			_video.clear();
		}
		
		/**
		 * load流 
		 * @param url
		 * 
		 */		
		private function _load(url : String):void
		{
			_hls.load(url);
		}
		
		/**
		 * 切换码率 
		 * @param _level 值设为-1则为自动切换
		 * 
		 */		
		public function changeLevel(_level:int):void{
			if(_hls.levels.length>_level){
				defaultLevel=_level;
			}else{
				defaultLevel=_hls.levels.length-1;
			}
			_hls.level=defaultLevel;
		}
		
		/**
		 * 加载监听 
		 * @param event
		 * 
		 */		
		private function _manifestHandler(event : HLSEvent):void
		{
			_duration = event.levels[_hls.startlevel].duration;
			playBtn.visible=true;
			playbigBtn.visible=true;
			if (playStatus == "play")
			{
				if (this.autoplay){
				   _play(-1);
				}
			}
		}
		
		/**
		 * 状态监听 
		 * @param event
		 * 
		 */		
		private function _stateHandler(event : HLSEvent):void
		{
			trace("event.state:"+event.state);
			switch(event.state){
				case "PLAYING_BUFFERING":
					buffing_ico_v.visible=true;
					ctrl_bar_v.stream_t.text="缓冲……";
					uniTimer.start();
					uniTimer.addEventListener(TimerEvent.TIMER,_uniTimerEvent);
					break;
				case "PLAYING":
					buffing_ico_v.visible=false;
					if(uniTimer.running){
						uniTimer.stop();
						uniTimer.removeEventListener(TimerEvent.TIMER,_uniTimerEvent);
					}
					ctrl_bar_v.stream_t.text="直播";
				
					break;
				case "PAUSED":
					ctrl_bar_v.stream_t.text="暂停";
					
					
					break;
				default:
					break;
			}
		}
		
		/**
		 * 公共计时器事件 
		 * @param e
		 * 
		 */		
		private function _uniTimerEvent(e:TimerEvent):void{
			if(buffing_ico_v.visible){
				if(_hls._netRat>0){
					buffing_ico_v.buffing_t.text=_hls._netRat+"kb";
				}
			}
		}
		/**
		 * 片段播放监听
		 * @param event
		 * 
		 */		
		private function _fragmentPlayingHandler(event : HLSEvent):void
		{
//			trace("_fragmentPlayingHandler:"+"-"+event.playMetrics.video_width+"-"+stage.stageWidth);
//			trace("level:"+_hls.level);
//			trace("bufferLength:"+_hls.bufferLength+"/s");
		}
		
		/**
		 * 时间监听 
		 * @param event
		 * 
		 */		
		private function _mediaTimeHandler(event : HLSEvent):void
		{
//			trace(formatTime(event.mediatime.live_sliding_main));
//			trace("duration:"+formatTime(event.mediatime.duration));
//			trace(_hls.levels[_hls.level].bitrate / 1000);
			_duration = event.mediatime.duration;
			_media_position = event.mediatime.position;
//			ctrl_bar_v.time_t.text = formatTime(_media_position);//这个时间只是本次加载的m3u8内的时间
		}
		
		/**
		 * 格式化时间 
		 * @param time 毫秒
		 * @return 
		 * 
		 */		
		private function formatTime(time:Number):String
		{
			if (time > 0)
			{
				var integer:String = String((time / 60) >> 0);
				var decimal:String = String((time % 60) >> 0);
				return ((integer.length < 2) ? "0" + integer : integer) + ":" + ((decimal.length < 2) ? "0" + decimal : decimal);
			}
			else
			{
				return String("00:00");
			}
		}
		
		/**
		 * 按钮点击事件 
		 * @param e
		 * @return 
		 * 
		 */		
		private function btnClick(e:MouseEvent){
			switch(e.target){
				case playBtn:
					if(playing){
						_resume();
					}else{
						_play(-1);
					}
					break;
				case playbigBtn:
					if(playing){
						_resume();
					}else{
						_play(-1);
					}
					break;
				case stopBtn:
					_stop();
					break;
				case pauseBtn:
					_pause();
					break;
				case setBtn:
					if(settingPad_v.visible){
						settingPad_v.visible=false;
					}else{
						settingPad_v.visible=true;
					}
					break;
				default:
					break;
			}
		}
		
		/**
		 *显示或隐藏控制栏 
		 * @param _show
		 * 
		 */		
		private function showOrHideCtrl(_show:Boolean):void{
			if(_show){
				ctrlHideTimer.start();
				ctrlHideTimer.addEventListener(TimerEvent.TIMER_COMPLETE,ctrlTimeOut);
				ctrl_bar_v.visible=true;
			}else{
				ctrl_bar_v.visible=false;
				ctrlHideTimer.reset();
				ctrlHideTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,ctrlTimeOut);
			}
		}
		
		private function ctrlTimeOut(e:TimerEvent){
			showOrHideCtrl(false);
		}
		
		/**
		 * 鼠标移动监听 
		 * @param e
		 * 
		 */		
		private function mouseMoving(e:MouseEvent):void{
			if(ctrlHideTimer.running){
				ctrlHideTimer.reset();
				ctrlHideTimer.start();
			}else{
				showOrHideCtrl(true);
			}
		}
		
		/**
		 *改变画面比例 
		 * @param wild
		 * 
		 */		
		public function changeScreen(wild:Boolean):void{
			_wild=wild;
			changeVideoSize();
		}
		
		/**
		 * 设置视频大小 
		 * 
		 */		
		private function changeVideoSize():void{
			if(_wild){
				if(stage.stageWidth/stage.stageHeight>2){
					_video.height=stage.stageHeight;
					_video.width=stage.stageHeight*16/9;
					_video.x=(stage.stageWidth-_video.width)/2;
					_video.y=0;
				}else{
					_video.width=stage.stageWidth;
					_video.height=stage.stageHeight;
					_video.x=0;
					_video.y=0;
				}
			}else{
				_video.height=stage.stageHeight;
				_video.width=stage.stageHeight*4/3;
				_video.x=(stage.stageWidth-_video.width)/2;
				_video.y=0;
			}
		}
		/**
		 * 亮度滤镜 
		 * @param param1
		 * 
		 */
		public function set_brightness(param1:Number) : void
		{
			this._bright = param1;
			var fAr:Array=new Array();
			if(this._bright!=0){
				var _loc_2:ColorMatrix = new ColorMatrix();
				_loc_2.SetBrightnessMatrix(this._bright);
				fAr.push(new ColorMatrixFilter(_loc_2.GetFlatArray()));
			}
			if(this._contrast!=128){
				var _loc_3:ColorMatrix = new ColorMatrix();
				_loc_3.SetContrastMatrix(this._contrast);
				fAr.push(new ColorMatrixFilter(_loc_3.GetFlatArray()));
			}
			if(fAr.length==0){
				_video.filters = null;
			}else{
				_video.filters = fAr;
			}
		}
		
		/**
		 * 对比度滤镜 
		 * @param param1
		 * 
		 */
		public function set_contrast(param1:Number) : void
		{
			this._contrast = param1;
			var fAr:Array=new Array();
			if(this._bright!=0){
				var _loc_2:ColorMatrix = new ColorMatrix();
				_loc_2.SetBrightnessMatrix(this._bright);
				fAr.push(new ColorMatrixFilter(_loc_2.GetFlatArray()));
			}
			if(this._contrast!=128){
				var _loc_3:ColorMatrix = new ColorMatrix();
				_loc_3.SetContrastMatrix(this._contrast);
				fAr.push(new ColorMatrixFilter(_loc_3.GetFlatArray()));
			}
			if(fAr.length==0){
				_video.filters = null;
			}else{
				_video.filters = fAr;
			}
		}
	}
}