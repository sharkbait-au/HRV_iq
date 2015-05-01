using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class TestTypeMenuDelegate extends Ui.MenuInputDelegate {

    function onMenuItem(item) {

		var app = App.getApp();

        if(item == :MiTimer) {

            app.testTypeSet = TYPE_TIMER;
        }
        else if(item == :MiManual) {

            app.testTypeSet = TYPE_MANUAL;
        }
        else if(item == :MiAuto) {

            app.testTypeSet = TYPE_AUTO;
        }

        if(item != :MiAuto && app.isWaiting) {
        	app.endTest();
        }
    }
}