class MyGameOrchestrator extends CGFobject {
    constructor(scene) {
        super(scene);
        this.scene = scene;
        this.time = 0;
        this.prolog;
        this.gameboard = new MyGameBoard(scene);
        this.picking = true;
        this.moveRequested = false;
        this.boardPicking = false;
        this.piece2;

        this.white = new CGFappearance(this.scene);
        this.white.setAmbient(1, 1, 1, 1);
        this.white.setDiffuse(1, 1, 1, 1);
        this.white.setSpecular(1, 1, 1, 1);
        this.white.setEmission(1, 1, 1, 1);

        this.black = new CGFappearance(this.scene);
        this.black.setAmbient(0, 0, 0, 0);
        this.black.setDiffuse(0, 0, 0, 0);
        this.black.setSpecular(0, 0, 0, 0);
        this.black.setEmission(0, 0, 0, 0);

        this.moves = [];
        this.movement;

        this.pieceX;
        this.pieceY;

        this.counter;
        this.timeCounter = 0;

        
        this.mode = { 
            PLAYER_VS_PLAYER: 0,
            PLAYER_VS_BOT: 1,
            BOT_VS_BOT: 2
        };

        this.gameStates = {
            'Menu' : 0,
            'Next turn' : 1,
            'Select Piece' : 2,
            'Select Change Positions' : 3,
            'Animation' : 4,
            'Check Win' : 5,
            'Win' : 6,
            'Undo' : 7,
            'End Game' : 8
        }

        this.gameState = this.gameStates.Menu;
        this.pieces = [];
        this.changingPlayer = false;

        this.sizeboard = 10;

        this.botMoveMade;
        this.initPieces();                
        this.init();
        this.start();

    }


    initPieces()
    {
        for(var i = 0; i < this.sizeboard; i++)
        {
            for(var j=0; j < this.sizeboard; j++)
            {
                if(i % 2 == 0)
                {
                    if((i*this.sizeboard +j) % 2 == 0)
                        this.pieces.push(new MyPiece(this.scene, i, j/2, this.black, false));
                    else
                        this.pieces.push(new MyPiece(this.scene, i, j/2, this.white, false));
                }

                if(i %2 != 0)
                {
                    if((i*this.sizeboard +j) % 2 == 0)
                        this.pieces.push(new MyPiece(this.scene, i, j/2, this.white,false));
                    else
                        this.pieces.push(new MyPiece(this.scene, i, j/2, this.black, false));
                }           
            }
        }
    }


    start() {  
        this.prolog.getPrologRequest('pvp', function(data) {
            if(data.target.response == "ok") {
                console.log("The board is initialized, you can start the game!");

                this.player1 = new MyPlayer('black');
                this.player2 = new MyPlayer('white');
                this.player = this.player1;
            }
            else {
                console.log("ERROR");
                console.log(data.target.response);
            }
        });

        

    }

    init() {    
        this.prolog = new Connection();
        this.gameboard = new MyGameBoard(this.scene);
        this.counter = 0;
    
    }

    quit() {   
        this.prolog.request('exit', function(data) {
            if(data.target.response == "goodbye") {
                console.log("The server is now closed");
            }
            else {
                console.log("ERROR");
                console.log(data.target.response);
            }
        });
    }

    update(time) {
        this.time = time;
        this.timeCounter += time;

        
    }

    OnObjectSelected(obj, uniqueId) {
        if (obj instanceof MyPiece && this.boardPicking) {
            this.picking = false;
            this.prolog.validateMove(this.gameboard, [this.pieceX, this.pieceY]);
        }
    }
    
    managePick(mode, results) {        

        if (mode == false && this.picking == true)
        {
            if (results != null && results.length > 0) 
            { 
                for (var i=0; i< results.length; i++) 
                {
                    var obj = results[i][0]; // get object from result
                    if (obj) 
                    { 
                        var uniqueId = results[i][1] // get id
                        this.OnObjectSelected(obj, uniqueId);
                    }
                }
            }
        }
        results.splice(0, results.length);
    }


    changePlayer() {
        this.picking = false;
        this.changingPlayer = true;
        if(this.player = this.player1)
            this.player = this.player2;
        else 
            this.player = this.player1;
    }

    getMoveCoords()
    {
        for(var i=0; i < this.pieces.length; i++)
        {
            for(var j=0; i < this.pieces.length; j++)
            {
                if(this.pieces[i].picked = true && this.pieces[j].picked)
                    this.piece2 = this.pieces[j];
                
            }
        }
        return [this.piece2.x, this.piece2.y];
    }

    move() {
        for(var i=0; i < this.pieces.length; i++)
            if(this.pieces[i].picked = true)
                {
                    movement = addMove([this.pieces[i].x, this.pieces[i].y], getMoveCoords()); 
                    this.pieceX = this.piece[i].x;
                    this.pieceY = this.piece[i].y;
                    this.moves.push(movement);
                }

    }

    display(){
        var k =0; 
        for(var i = 0; i < this.pieces.length; i++)
        {
            if(i % this.sizeboard == 0)
                k++;

            var x  = this.pieces[i].x;
            var y  = this.pieces[i].y;
            var transM = mat4.translate(mat4.create(), mat4.create(), [x,y,0.3 ]);
            this.scene.pushMatrix();
            this.scene.multMatrix(transM);
            this.pieces[i].color.apply();
            this.pieces[i].display();
            this.scene.defaultAppearance.apply()
            this.scene.popMatrix();

        }
    }

    moveBot() {
        let failure = function() {
        };

        let reply = function(data) {
            this.updateTurn();
            this.botMoveMade = 0;
            this.parseBotMoveResponse(data);
        };

        let request = this.prolog.getPrologRequest('bvb', reply.bind(this), failure.bind(this));
        this.server.prologRequest(request);
    }

}
