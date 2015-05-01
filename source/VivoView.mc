using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class VivoView extends Ui.View {

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {

    	requestUpdate();
    }

    //! Update the view
    function onUpdate(dc) {

		var str = "Vivoactive\nnot currently\nsupported";
		dc.clear();
		dc.setColor(WHITE, BLACK);
		dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Gfx.FONT_MEDIUM, str, Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
    }

    //! Called when this View is removed from the screen. Save the
    //! state of your app here.
    function onHide() {
    }

}

class VivoDelegate extends Ui.BehaviorDelegate {

	function onBack() {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        return true;
    }

}