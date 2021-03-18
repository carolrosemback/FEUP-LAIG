class MyGameSequence {

    constructor(scene, orchestrator) {
        this.scene = scene;
        this.orchestrator = orchestrator;
        this.moves = [];
        this.animating = false;

    }

    reset() {
        this.moves = [];
        this.animating = false;
    }

    getMoves = () => this.moves;

    addMove(coordsInit, coordsFin) {
        this.moves.push(new MyGameMove(this.scene, coordsInit, coordsFin));
        this.animating = true;
    }

    addInvalidMove(tile) {
        this.moves.push(new MyGameMoveInvalid(tile, this.scene));
        this.animating = true;
    }


    update(t) {
        if (this.moves.length > 0 && this.animating) {
            this.animating = this.moves[this.moves.length - 1].update(t);  
            if (this.animating) {
                    this.moves.pop();
                    this.orchestrator.picking = true;
                    this.orchestrator.moveRequested = false;
                
            }
        }
    }

    display() {
        if (this.moves.length > 0 && this.animating)
            this.moves[this.moves.length - 1].display();
    }
}