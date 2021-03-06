class MyGameMove {

    constructor(scene, coordsInit, coordsFin) {
        this.scene = scene;
        this.piece; 
        this.animating = false;
        this.reversing = false;
        this.ended = false;
        this.startTime = null;
        this.matrix = mat4.create();
        this.coordsInit = coordsInit;
        this.createAnimation(coordsInit, coordsFin);
    }

    createAnimation(coordsInit, coordsFin) {
        this.coordsDiff = {
            x: coordsFin.x - coordsInit.x,
            y: coordsFin.y - coordsInit.y,
            z: coordsFin.z - coordsInit.z
        };
        let distOffset = 0.1 * Math.sqrt(this.coordsDiff.x * this.coordsDiff.x + this.coordsDiff.y * this.coordsDiff.y);
        this.deltaTime = 1 + distOffset;
        this.height = 0.5 + distOffset;
        this.animate();
    }

    animate() {
        this.ended = false;
        this.animating = true;
        if (this.reversing) {
            this.coordsInit = {
                x: this.coordsInit.x + this.coordsDiff.x,
                y: this.coordsInit.y + this.coordsDiff.y,
                z: this.coordsInit.z + this.coordsDiff.z
            };
            this.coordsDiff.x = -this.coordsDiff.x;
            this.coordsDiff.y = -this.coordsDiff.y;
            this.coordsDiff.z = -this.coordsDiff.z;
            this.reversing = false;
        }
        this.startTime = null;
    }

    quadratic = (percent) => (-4 * (percent - 0.5) * (percent - 0.5) + 1) * this.height;
    
    endAnimation() {
        if (this.animating) {
            if (this.reversing)
                this.piece.setPos(this.piece);
            else {
                this.ended = true;
                this.piece.setPos();            
            }
        }
        this.animating = false;
        this.startTime = null;
    }

    reverse() {
        this.reversing = true;
        this.coordsInit = {
            x: this.coordsInit.x + this.coordsDiff.x,
            y: this.coordsInit.y + this.coordsDiff.y,
            z: this.coordsInit.z + this.coordsDiff.z
        };
        this.coordsDiff.x = -this.coordsDiff.x;
        this.coordsDiff.y = -this.coordsDiff.y;
        this.coordsDiff.z = -this.coordsDiff.z;
        if (this.animating) this.startTime -= this.deltaTime/2 - this.delta;
        else {
            this.startTime = null;
            this.animating = true;        }
    }

    update(t) {
        if (!this.animating) return false;
        if (this.startTime == null) this.startTime = t;

        this.matrix = mat4.create();

        this.delta = t - this.startTime;

        if (this.delta > (this.deltaTime/this.scene.speed)) {
            this.endAnimation();
            return false;
        }

        let percent = this.delta / (this.deltaTime/this.scene.speed);

        mat4.translate(this.matrix, this.matrix, [
            this.coordsDiff.x * percent,
            this.coordsDiff.y * percent,
            this.coordsDiff.z * percent + this.quadratic(percent)
        ]);

        return true;
    }

    display() {
        if (this.animating) {
            this.scene.pushMatrix();
                this.scene.multMatrix(this.matrix);
                this.scene.translate(this.coordsInit.x, this.coordsInit.y, this.coordsInit.z);
                this.piece.display();
            this.scene.popMatrix();
        }
    }
}