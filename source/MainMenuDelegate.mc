using Toybox.WatchUi as Ui;

class MainMenuDelegate extends Ui.MenuInputDelegate {

    function onMenuItem(item) {

        if(item == :MiTestType) {

            Ui.pushView(new Rez.Menus.TestTypeMenu(), new TestTypeMenuDelegate(), Ui.SLIDE_LEFT);
        }
        else if(item == :MiSettings) {

            Ui.pushView(new Rez.Menus.SettingsMenu(), new SettingsMenuDelegate(), Ui.SLIDE_LEFT);
        }
        //else if(item == :MiColor) {
		//
        //    Ui.pushView(new Rez.Menus.ColorMenu(), new ColorMenuDelegate(), Ui.SLIDE_LEFT);
        //}
        else if(item == :MiAbout) {

            Ui.pushView(new Rez.Menus.AboutMenu(), new EmptyMenuDelegate(), Ui.SLIDE_LEFT);
        }
    }
}