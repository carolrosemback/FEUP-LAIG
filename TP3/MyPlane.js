class MyPlane extends CGFobject {
    constructor(scene, npartsU, npartsV) {
        super(scene);
        this.npartsU = npartsU;
        this.npartsV = npartsV;
        this.scene = scene;
        this.plane;
        this.primitiveType = this.scene.gl.TRIANGLES;

        var degreeU = 1;
        var degreeV = 1;
        var controlvertexes = [
                            [
                                [0.5, 0.0, -0.5, 1 ],
                                [0.5, 0.0, 0.5, 1 ] 
                            ],
                            [
                                [-0.5, 0.0, -0.5, 1 ],
                                [-0.5,  0.0, 0.5, 1 ]                         
                            ]
                        ]

        this.makeSurface(degreeU, degreeV, controlvertexes);
    };

    makeSurface(degreeU, degreeV, controlvertexes) {
            
        var nurbsSurface = new CGFnurbsSurface(degreeU, degreeV, controlvertexes);
        var obj = new CGFnurbsObject(this.scene, this.npartsU, this.npartsV, nurbsSurface); 
        this.plane = obj;
    }

    display(){

        this.plane.display();
    };

    update(time){};
};