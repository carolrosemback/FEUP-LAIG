class MyPiece extends CGFobject {
    constructor(scene, x, y, color, picked) {
        super(scene);
        this.x = x;
        this.y = y;
        this.picked = picked;
        this.color = color;

        this.piece = new MyCylinder2(this.scene, 30, 0.1, 0.1, 0.1,30);

        this.animation = null;
        this.initialx = this.x;
        this.initialy = this.y;

    }
    
    setPos(x, y) {
        this.x = x;
        this.y = y;
    }

    resetPos() {
        this.x = this.initialx;
        this.y = this.initialy;
    }

    display() {
        this.scene.pushMatrix();
        this.scene.translate(this.x/1000 +3.75, this.y/1000 - 5.75, 0);
        this.piece.display();
        this.scene.popMatrix();
    }
}