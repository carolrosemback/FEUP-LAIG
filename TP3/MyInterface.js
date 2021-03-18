/**
* MyInterface class, creating a GUI interface.
*/
class MyInterface extends CGFinterface {
    /**
     * @constructor
     */
    constructor() {
        super();
    }

    /**
     * Initializes the interface.
     * @param {CGFapplication} application
     */
    init(application) {
        super.init(application);
        // init GUI. For more information on the methods, check:
        //  http://workshop.chromeexperiments.com/examples/gui

        this.gui = new dat.GUI();

        // add a group of controls (and open/expand by defult)

        this.initKeys();
        return true;
    }

    initMyInterface() {

        this.gui.add(this.scene, 'selectedEnvironment', this.scene.environments).name('Environment').onChange(this.scene.changeEnvironment.bind(this.scene));
        this.gui.add(this.scene, 'start').onChange(function(newValue) {
            this.start = newValue;
        });
        this.gui.add(this.scene, 'quit').onChange(function(newValue) {
            this.quit = newValue;
        });
        this.gui.add(this.scene, 'selectedCamera', this.scene.cameraID).name('Camera').onChange(this.scene.changeCamera.bind(this.scene));


    }

    /**
     * initKeys
     */
    initKeys() {
        this.scene.gui=this;
        this.processKeyboard=function(){};
        this.activeKeys={};
    }

    processKeyDown(event) {
        this.activeKeys[event.code]=true;
    };

    processKeyUp(event) {
        this.activeKeys[event.code]=false;
    };

    isKeyPressed(keyCode) {
        return this.activeKeys[keyCode] || false;
    }
}
