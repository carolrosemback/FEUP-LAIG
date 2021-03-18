class Connection {

    constructor(orchestrator) {
        this.orchestrator = orchestrator;
        this.waitingRequest = false;
        this.port = 8081;

    }

    prologRequest(request) {
        // Get Parameter Values
        let requestString = request.command.toString();
        if (request.args != null)
        requestString += '(' + request.args.toString().replace(/"/g, '') + ')';
        // Make Request
        console.log('Request: ' + requestString);
        return this.getPrologRequest(requestString, request.onSuccess, request.onError);
    }

    getPrologRequest(requestString, onSuccess, onError) {
        var request = new XMLHttpRequest();

        request.open('GET', 'http://localhost:' + this.port + '/' + requestString, false);

        request.onload =  onSuccess || function(data) {
            console.log("Request received. Reply: ", JSON.parse(data.target.response));
            request.result = JSON.parse(data.target.response);
            resolve(request.result);
        };

        request.onerror = onError ||  function() {
            console.log("Error waiting for response");
            };

        request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
        request.send();
    }

    validateMove(board, coords) {
        let request = 'validMove(' + this.getArrayToString(board) + ',' + coords.x + ',' + coords.y + ')';
        this.getPrologRequest(request, this.move, this.getError);
        this.waitingRequest = true;
    }

    move(data) {
        let response = this.getStringToArray(data.target.response);
        let x = response[1];
        let y = response[2];
        
        if (response[0] == 'valid') {
            this.orchestrator.move(x, y);
        }
        else {
            this.orchestrator.failledMove(x, y);
        }
        this.waitingRequest = false;
    }

    AImove(data) {
        let response = this.getStringToArray(data.target.response);
        let x = response[1];
        let y = response[2];
        if (response[0] == 'valid') {
            this.orchestrator.move(x, y);
        }
        else if (response[0] == 'invalid') {
            this.orchestrator.failledMove(x, y);
        }
        this.waitingRequest = false;
    }

    aiMove(board, dificulty) {
        let request = 'aiMove(' + this.getArrayToString(board) + ',' + dificulty + ')';
        this.getPrologRequest(request, this.AImove, this.getError);
        this.waitingRequest = true;
    }

}