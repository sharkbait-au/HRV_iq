using Toybox.WatchUi as Ui;

class ResetMenuDelegate extends Ui.MenuInputDelegate {

    function onMenuItem(item) {

        if(item == :MiSettings) {

			Ui.pushView(new Ui.Confirmation("Reset settings?"), new SettingsDelegate(), Ui.SLIDE_LEFT);
        }
        else if(item == :MiResults) {

			Ui.pushView(new Ui.Confirmation("Clear results?"), new ResultsDelegate(), Ui.SLIDE_LEFT);
        }
    }
}