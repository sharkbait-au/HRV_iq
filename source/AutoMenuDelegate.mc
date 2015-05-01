using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class AutoMenuDelegate extends Ui.MenuInputDelegate {

    function onMenuItem(item) {

        if(item == :MiDuration) {

            Ui.pushView(new Ui.NumberPicker(Ui.NUMBER_PICKER_TIME,
            	new Time.Duration(App.getApp().autoTimeSet)),
            	new AutoTimeDelegate(), Ui.SLIDE_LEFT);
        }
        else if(item == :MiSchedule) {

            Ui.pushView(new Ui.NumberPicker(Ui.NUMBER_PICKER_TIME_OF_DAY,
            	new Time.Duration(App.getApp().autoStartSet)),
            	new AutoStartDelegate(), Ui.SLIDE_LEFT);
        }
    }
}

class AutoTimeDelegate extends Ui.NumberPickerDelegate {

	function onNumberPicked(duration) {

		var app = App.getApp();
		app.autoTimeSet = duration.value().toNumber();
	}
}

class AutoStartDelegate extends Ui.NumberPickerDelegate {

	function onNumberPicked(duration) {

		var app = App.getApp();
		app.autoStartSet = duration.value().toNumber();
	}
}