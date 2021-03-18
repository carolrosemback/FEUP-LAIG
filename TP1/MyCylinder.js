/**
* MyCylinder
* @constructor
*/
class MyCylinder extends CGFobject {
    constructor(scene, slices, stacks, height, topRadius, bottomRadius) {
        super(scene);
        this.slices = slices;
        this.stacks = stacks;
        this.height = height;
        this.topRadius = topRadius;
        this.bottomRadius = bottomRadius;
        this.initBuffers();
    }


    initBuffers() {
      this.vertices = [];
      this.indices = [];
      this.normals = [];
      this.texCoords = [];


      var ang = (2*Math.PI) / this.slices;
      var deltaRadius = this.topRadius - this.bottomRadius
      var stackAngVariance = deltaRadius / this.stacks;
      var stackHeight = this.height / this.stacks;



      for (var stack = 0; stack <= this.stacks; stack++) {
        var z = stack * stackHeight;
        var radius = this.topRadius - stack * stackAngVariance;

        for (var slice = 0; slice <= this.slices; slice++) {

          var x = radius * Math.cos(slice * ang);
          var y = radius * Math.sin(slice * ang);
          var s = slice * ang;
          var t = z;

          this.vertices.push(x, y, z);
          this.normals.push(x, y, 0);
          this.texCoords.push(s, t);
        }
      }

      for (var stack = 0; stack < this.stacks; stack++) {
        for (var slice = 0; slice < this.slices; slice++) {
          var first = (stack * (this.slices + 1)) + slice;
          var second = first + this.slices + 1;

          this.indices.push(first, second + 1, second);
          this.indices.push(first, first + 1, second + 1);
        }
      }


        this.primitiveType = this.scene.gl.TRIANGLES;
        this.initGLBuffers();
    }

    updateBuffers(complexity) {
        this.slices = 4 + Math.round(16 * complexity); //complexity varies 0-1, so slices varies 3-12

        // reinitialize buffers
        this.initBuffers();
        this.initNormalVizBuffers();
    }

}
