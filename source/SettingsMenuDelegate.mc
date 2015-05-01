using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class SettingsMenuDelegate extends Ui.MenuInputDelegate {

    function onMenuItem(item) {

        if(item == :MiTimer) {

            Ui.pushView(new Rez.Menus.TimerMenu(), new TimerMenuDelegate(), Ui.SLIDE_LEFT);
        }
        else if(item == :MiManual) {

            Ui.pushView(new Rez.Menus.ManualMenu(), new ManualMenuDelegate(), Ui.SLIDE_LEFT);
        }
        else if(item == :MiAuto) {

            Ui.pushView(new Rez.Menus.AutoMenu(), new AutoMenuDelegate(), Ui.SLIDE_LEFT);
        }
        else if(item == :MiBreathe)
        {
            Ui.pushView(new Rez.Menus.BreatheMenu(), new BreatheMenuDelegate(), Ui.SLIDE_LEFT);
        }
        else if(item == :MiColor)
        {
            Ui.pushView(new Rez.Menus.ColorMenu(), new ColorMenuDelegate(), Ui.SLIDE_LEFT);
        }
        else if(item == :MiGreen) {

            Ui.pushView(new Ui.NumberPicker(Ui.NUMBER_PICKER_TIME,
            	new Time.Duration(App.getApp().greenTimeSet)),
            	new GreenTimeDelegate(), Ui.SLIDE_LEFT);
        }
        else if(item == :MiSound) {

            Ui.pushView(new Rez.Menus.YesNoMenu(), new ChoiceMenuDelegate(method(:setSound)), Ui.SLIDE_LEFT);
        }
        else if(item == :MiVibration) {

            Ui.pushView(new Rez.Menus.YesNoMenu(), new ChoiceMenuDelegate(method(:setVibe)), Ui.SLIDE_LEFT);
        }
        else if(item == :MiReset) {

            Ui.pushView(new Rez.Menus.ResetMenu(), new ResetMenuDelegate(), Ui.SLIDE_LEFT);
        }
    }

    function setSound(value) {

    	var app = App.getApp();
		app.soundSet = value;
    }

    function setVibe(value) {

    	var app = App.getApp();
		app.vibeSet = value;
    }
}

class GreenTimeDelegate extends Ui.NumberPickerDelegate {

    function onNumberPicked(duration) {

		var app = App.getApp();
		app.greenTimeSet = duration.value().toNumber();
	}
}