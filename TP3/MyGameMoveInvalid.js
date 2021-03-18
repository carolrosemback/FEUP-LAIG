class MyGameMoveInvalid {
 
    constructor(tile, scene) {
        this.tile = tile;
        this.scene = scene;
        this.animating = false;
        this.reversing = false;
        this.ended = false;
        this.startTime = null;
        this.deltaTime = 2;
        this.animate();
    }

    animate() {
        this.ended = false;
        this.animating = true;
        this.startTime = null;
    }
    
    endAnimation() {
        this.ended = true;
        this.animating = false;
        this.startTime = null;
    }

    reverse() {
        this.reversing = true;
        if (this.animating) this.startTime -= this.deltaTime/2 - this.delta;
        else {
            this.startTime = null;
            this.animating = true;
        }
    }

    update(t) {
        if (!this.animating) return false;
        if (this.startTime == null) this.startTime = t;

        this.delta = t - this.startTime;

        if (this.delta > this.deltaTime/this.scene.speed) {
            this.endAnimation();
            return false;
        }
        return true;
    }

    display() {}
}