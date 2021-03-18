class MyCylinder2 extends CGFobject {
    constructor(scene, slices, height, middle, base, stacks) {
        super(scene);

        this.base = base;
        this.middle = middle;
        this.height = height;
        this.slices = slices;
        this.stacks = stacks;

        this.cylinder2;

        var degreeU = 1;
        var degreeV = 8;

        var w = 1;

        var controlVertexes = [
                            [
                                 [0.0, -this.base, 0.0, 1],
                                [-this.base, -this.base, 0.0, w],
                                [-this.base, 0.0, 0.0, 1],
                                [-this.base, this.base, 0.0, w],
                                [0.0, this.base, 0.0, 1],
                                [this.base, this.base, 0.0, w],
                                [this.base, 0.0, 0.0, 1],
                                [this.base, -this.base, 0.0, w],
                                [0.0, -this.base, 0.0, 1]                       
                            ],

                            [
                                
                                [0.0, -this.middle, this.height, 1],
                                [-this.middle, -this.middle, this.height, w],
                                [-this.middle, 0.0, this.height, 1],
                                [-this.middle, this.middle, this.height, w],
                                [0.0, this.middle, this.height, 1],
                                [this.middle, this.middle, this.height, w],
                                [this.middle, 0.0, this.height, 1],
                                [this.middle, -this.middle, this.height, w],
                                [0.0, -this.middle, this.height, 1]                       
                            ]
                        ];
        
        this.makeSurface(degreeU, degreeV, controlVertexes);
    };

    makeSurface(degreeU, degreeV, controlvertexes) {

        var nurbsSurface = new CGFnurbsSurface(degreeU, degreeV, controlvertexes);
        var obj = new CGFnurbsObject(this.scene, this.stacks, this.slices, nurbsSurface); 

        this.cylinder2 = obj;
    }

    display() {
        this.cylinder2.display();
    }
    applyTextures(lengthS, lengthT) {}
    update(time){};
}