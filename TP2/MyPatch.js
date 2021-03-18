class MyPatch extends CGFobject {
    constructor(scene, npointsU, npointsV, degreeU, degreeV, controlVertexes) {
        super(scene);
        this.scene = scene;

        var surface = new CGFnurbsSurface(npointsU, npointsV, controlVertexes);
        this.nurb = new CGFnurbsObject(scene, degreeU, degreeV, surface);
    }

    display() {
        this.nurb.display();
    }
}