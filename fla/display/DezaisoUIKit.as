package display
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.ColorChooser;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.Slider;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	
	public class DezaisoUIKit extends Sprite
	{
		
		public var buttonSave:PushButton;
		public var autoPlayCheckBox:CheckBox;
		public var skipTargetTextInput:InputText;
		public var skipButton:PushButton;
		public var colorPannel:ColorChooser;
		
		public var transparentButton:CheckBox;
		public var transparentSlider:Slider;
		
		private var _stage:Stage;
		private var d_jimaku:gooddezair3;
		
		public var intervalSlider:Slider;
		private var intervalLabel:InputText;
		
		private var textColorWhite:CheckBox;
		private var textShadowCheckBox:CheckBox;
		private var randomText:CheckBox;
		
		private var blankInterbal:InputText;
		private var blankInterbalPush:PushButton;
		
		
		//public var viewAreaRectangle:GDViewAreaRectangle;
		
		
		
		public function DezaisoUIKit(s:gooddezair3)
		{
			d_jimaku = s;
			_stage = s.stage;
			_stage.addEventListener( KeyboardEvent.KEY_DOWN, showPannel );
			
			buttonSave = new PushButton( this, 20, 30, "CLOSE", doClose );
			buttonSave.width = 40;
			autoPlayCheckBox = new CheckBox(this, 20, 60, "AUTO PLAY", onChangeAutoPlay );
			autoPlayCheckBox.selected = true;
			skipTargetTextInput = new InputText( this, 20, 80, "0" );
			skipTargetTextInput.width = 160;
			skipButton = new PushButton(this, 200, 80, "SKIP", onSkip );
			skipButton.width = 40;
			colorPannel = new ColorChooser()
			this.addChild( colorPannel );
			colorPannel.x = 300;
			colorPannel.y = 100;
			colorPannel.addEventListener( Event.CHANGE, onChangeTransparent );
			
			transparentButton = new CheckBox(this, 300, 60, "Back Ground", onChangeTransparent);
			transparentButton.selected = true;			
			transparentSlider = new Slider( "horizontal", this, 300, 80, onChangeTransparent );
			transparentSlider.minimum = 0;
			transparentSlider.maximum = 1;
			transparentSlider.value = 1;
			onChangeTransparent(null);
			
			textShadowCheckBox = new CheckBox(this, 420, 60, "Text Shadow", onChangeTextColor );
			textShadowCheckBox.selected = true;
			textColorWhite = new CheckBox(this, 420, 80, "Text Color White", onChangeTextColor );
			textColorWhite.selected = true;
			onChangeTextColor(null);
			
			intervalSlider = new Slider( "horizontal", this, 600, 80, onChangeInterval );
			intervalSlider.minimum = 1000/30;
			intervalSlider.maximum = 15000;
			intervalSlider.value = intervalSlider.maximum;
			intervalSlider.width = 300;
			intervalLabel = new InputText( this, 600, 60, intervalSlider.value.toString(), onChangeIntervalText);
			var ti:Label = new Label( this, 600, 40, "Interval");
			
			onChangeInterval(null);
			
			blankInterbal = new InputText( this, 750, 60, "0");
			blankInterbalPush = new PushButton( this, 860, 57, "blank", onUpdateBlankInterval);
			blankInterbalPush.width = 40;
			var tbi:Label = new Label( this, 750, 40, "Blank Interval");
			
			
			var t:com.bit101.components.Label = new Label( this, 20, 100, "※Press “SPACE” / show this pannel.");
			d_jimaku.addEventListener("JIMAKU_COUNT_UP", onCountUp );
			
			randomText = new CheckBox(this, 100, 60, "RANDOM", doRandom );
		}
		
		private function onCountUp(e:Event):void
		{
			skipTargetTextInput.text=String(d_jimaku.currentTargetNumber);
		}
		
		
		private function showPannel(e:KeyboardEvent):void
		{
			trace(e.keyCode+"   "+Keyboard.SPACE)
			if(e.keyCode === Keyboard.SPACE){
				this.visible = true;
				Mouse.show();
			}
		}
		
		
		private function onSkip(e:Event):void
		{
			var n:int = int(skipTargetTextInput.text);
			if(n>d_jimaku.jimakuLength-1){
				n = d_jimaku.jimakuLength-1;
				skipTargetTextInput.text = String(n);
			}else if(n<0){
				n = 0;
				skipTargetTextInput.text = String(n);
			}

			
			d_jimaku.showJimaku( n );
		}
		
		private function onChangeAutoPlay(e:Event):void
		{
			if( autoPlayCheckBox.selected ){
				d_jimaku.playJimaku();
			}else{
				d_jimaku.stopJimaku();
			}
		}
		
		public function onChangeTransparent(e:Event):void
		{
			d_jimaku.bgTranspartent(transparentButton.selected, transparentSlider.value, colorPannel.value);
		}
		
		public function onChangeInterval(e:Event):void
		{
			d_jimaku.changeInterval( intervalSlider.value );
			intervalLabel.text = intervalSlider.value.toString();
		}
		
		private function onChangeIntervalText(e:Event):void
		{
			var v:Number = Number(intervalLabel.text);
			if(v){
				var val:Number = (v>intervalSlider.maximum)? intervalSlider.maximum:v;
				val = (v<intervalSlider.minimum)? intervalSlider.minimum:v;
				d_jimaku.changeInterval( val );
			}else{
				intervalLabel.text = intervalSlider.value.toString();
			}
		}
		
		private function onChangeTextColor(e:Event):void
		{
			var col:uint = textColorWhite.selected? 0xffffff : 0x0;
			d_jimaku.textShadow( col, textShadowCheckBox.selected );
		}
		
		private function onUpdateBlankInterval(e:Event):void
		{
			var n = Number(blankInterbal.text);
			if(!n){ n = 0; }
			if(n<0){ n = 0; }
			d_jimaku.setBlankInterval(n);
		}
		
		public function doClose(e:Event):void
		{
			this.visible = false;　
			Mouse.hide();
		}
		
		
		private function doRandom(e:Event):void
		{
			trace('oj', randomText.selected);
			
			d_jimaku.random = randomText.selected;
		}
		
		
	}
}