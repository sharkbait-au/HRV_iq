using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class HRVInputDelegate extends Ui.InputDelegate {

    var app;

    function onKey(event) {

    	if(Ui.KEY_ENTER == event.getKey()) {

			onEnter();
		}
		else if(Ui.KEY_ESC == event.getKey()) {

			onEscape();
      	}
      	else if(Ui.KEY_MENU == event.getKey()) {

			onMenu();
      	}
		else if(Ui.KEY_UP == event.getKey()) {

			onDown();
		}
		else if(Ui.KEY_DOWN == event.getKey()) {

			onUp();
		}
      	else if(Ui.KEY_POWER == event.getKey()) {

			onPower();
		}
		return true;
	}

	function onSwipe(event) {

        if(Ui.SWIPE_LEFT == event.getDirection()) {

            onNextPage();
        }
        else if(Ui.SWIPE_RIGHT == event.getDirection()) {

            onPreviousPage();
        }
        //else if(Ui.SWIPE_UP == event.getDirection()) {

		//		onUp();
        //}
        //else if(Ui.SWIPE_DOWN == event.getDirection()) {

		//	onDown();
        //}

        return true;
    }

    function onTap(event) {

        onEnter();
        return true;
    }

    function onNextPage() {

		Ui.switchToView(app.plusView(), new HRVInputDelegate(), slide(Ui.SLIDE_LEFT));
    }

    function onPreviousPage() {

		Ui.switchToView(app.subView(), new HRVInputDelegate(), slide(Ui.SLIDE_RIGHT));
    }

    function onUp() {

		if(FENIX == app.device || FORERUNNER == app.device) {

			Ui.switchToView(app.plusView(), new HRVInputDelegate(), slide(Ui.SLIDE_LEFT));
		}
		else {

			Ui.switchToView(app.plusView(), new HRVInputDelegate(), slide(Ui.SLIDE_UP));
		}
    }

    function onDown() {

		if(FENIX == app.device || FORERUNNER == app.device) {

			Ui.switchToView(app.subView(), new HRVInputDelegate(), slide(Ui.SLIDE_RIGHT));
		}
		else {

			Ui.switchToView(app.subView(), new HRVInputDelegate(), slide(Ui.SLIDE_DOWN));
		}
    }

    function slide(direction) {

    	//if((Ui.SLIDE_LEFT == direction || Ui.SLIDE_UP == direction) && GRAPH_VIEW == app.viewNum) {
    	if(Ui.SLIDE_LEFT == direction && GRAPH_VIEW == app.viewNum) {

    		return Ui.SLIDE_IMMEDIATE;
		}
    	//else if((Ui.SLIDE_RIGHT == direction || Ui.SLIDE_DOWN == direction) && GRAPH_VIEW == app.viewNum) {
    	else if(Ui.SLIDE_RIGHT == direction && GRAPH_VIEW == app.viewNum) {

    		return Ui.SLIDE_IMMEDIATE;
    	}
    	else {

    		return direction;
    	}
    }

    function onEnter() {

		if(0 < app.viewNum) {

			Ui.switchToView(app.getView(TEST_VIEW), new HRVInputDelegate(), Ui.SLIDE_RIGHT);
			return;
		}
		else if(app.isNotSaved && MIN_SAMPLES < app.dataCount) {

			Ui.pushView(new Ui.Confirmation("Save result?"), new SaveDelegate(), Ui.SLIDE_LEFT);
			return;
    	}
    	else if(app.isFinished) {

    		app.resetTest();
    		Ui.requestUpdate();
    	}
    	else if(app.isTesting || app.isWaiting) {

    		app.stopTest();
    		Ui.requestUpdate();
    	}
    	else if(!app.isAntRx){

    		app.alert(TONE_ERROR);
    	}
    	else {

    		app.startTest();
    		app.stopViewTimer();
    		app.updateSeconds();
    	}

    	app.resetGreenTimer();
	}

	function onMenu() {

		app.stopGreenTimer();
		app.stopViewTimer();
		Ui.pushView(new Rez.Menus.MainMenu(), new MainMenuDelegate(), Ui.SLIDE_LEFT);
    }

	function onEscape() {

		if(TEST_VIEW == app.viewNum) {

			if(app.isTesting) {

				app.stopTest();
			}
			if(app.isFinished && app.isNotSaved && MIN_SAMPLES < app.dataCount) {

				app.isClosing = true;
				Ui.pushView(new Ui.Confirmation("Save result?"), new SaveDelegate(), Ui.SLIDE_LEFT);
			}
			else {

				app.onStop();
				Ui.popView(Ui.SLIDE_RIGHT);
			}
		}
		else {

			Ui.switchToView(app.getView(TEST_VIEW), new HRVInputDelegate(), Ui.SLIDE_RIGHT);
		}
	}

	function onPower() {

		app.resetGreenTimer();
	}

	function initialize() {

		app = App.getApp();
	}
}
