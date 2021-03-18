class MyGameBoard{
    constructor(scene) {
        this.scene = scene;
        this.board = [];
        
        this.pieces = [];
        this.lastMovements = [];
        

        this.white_wins = 0;
        this.black_wins = 0;

        this.playerBlack = new MyPlayer('black');
        this.playerWhite = new MyPlayer('white');


        this.server = new Connection();
        this.moveAllowed = 1;

        this.currentMode; 

    }

    getInitialBoard() {

        let failure = function() {
            return 400;
        };
        let reply = function(data) {
            this.board = data;
        };
        let request = this.server.getPrologRequest('initialBoard', reply, failure);
        return this.server.prologRequest(request);
    }

}