class MyTorus extends CGFobject {
  constructor(scene, inner, outer, slices, loops) {
    super(scene);
    this.inner = inner;
    this.outer = outer;
    this.slices = slices;
    this.loops = loops;
    this.initializeBuffers();
  }

  initializeBuffers() {
    this.vertices = [];
    this.normals = [];
    this.indices = [];
    this.texCoords = [];

    var loopAngle = 2 * Math.PI / this.loops;
    var sliceAngle = 2 * Math.PI / this.slices;

    for (let loop = 0; loop <= this.loops; loop++) {

      for (let slice = 0; slice <= this.slices; slice++) {

        this.normals.push(
          Math.cos(loop*loopAngle) * Math.cos(slice*sliceAngle),
          Math.sin(loop*loopAngle) * Math.cos(slice*sliceAngle),
          Math.sin(slice*sliceAngle)
        );

        this.vertices.push(
          Math.cos(loop*loopAngle) * (this.outer + Math.cos(slice*sliceAngle) * this.inner),
          Math.sin(loop*loopAngle) * (this.outer + Math.cos(slice*sliceAngle) * this.inner),
          Math.sin(slice*sliceAngle) * this.inner
        );

        this.texCoords.push(
          loop / this.loops,
          1 - slice / this.slices
        );
      }
    }

    for (var loop=0; loop<(this.loops-1); loop++){

      var thisLoop = loop;
      var nextLoop = loop+1;

      for (var slice=0; slice<(this.slices-1); slice++){

        var thisSlice = slice;
        var nextSlice = slice+1;

        var bl = (thisLoop*(this.slices+1))+thisSlice;
        var br = (nextLoop*(this.slices+1))+nextSlice;
        var tl = (thisLoop*(this.slices+1))+nextSlice;
        var tr = (nextLoop*(this.slices+1))+nextSlice;

        this.indices.push(

          bl, br, tr,
          tr, tl, bl

        );
      }
    }

    this.primitiveType = this.scene.gl.TRIANGLES;
    this.initGLBuffers();
  }

}
