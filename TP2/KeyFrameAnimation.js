class KeyframeAnimation extends Animation{
    constructor(scene, keyframes) {
        super(scene);
        this.keyframes = keyframes;
        this.instant;
        this.currKeyframe = 0;
        this.time;
        this.startTime = 0;

        this.transMatrix = mat4.create();
        this.translation = vec3.create();
        this.rotation = vec3.create();
        this.scale = vec3.create();

        this.transMatrix = mat4.create();
    }



    update(t){

        if(this.startTime == 0) 
            this.startTime = t;

        this.time = t - this.startTime;

            //first keyframe
            if(this.currKeyframe == 0) {
                var ratio = t / (this.keyframes[this.currKeyframe+1].instant);
    
                vec3.lerp(this.translation, [0, 0, 0], this.keyframes[this.currKeyframe+1].translation, ratio);
                vec3.lerp(this.rotation, [0, 0, 0], this.keyframes[this.currKeyframe+1].rotation, ratio);
                vec3.lerp(this.scale, [1, 1, 1], this.keyframes[this.currKeyframe+1].scale, ratio);
            }
            //last keyframe
            else if (this.currKeyframe+1 >= this.keyframes.length) {
                vec3.keyframes[this.currKeyframe].translation;
                vec3.keyframes[this.currKeyframe].rotation;
                vec3.keyframes[this.currKeyframe].scale;
            }


            else{
            var ratio = (t - this.keyframes[this.currKeyframe].instant) / (this.keyframes[this.currKeyframe+1].instant - this.keyframes[this.currKeyframe].instant);
        
            vec3.lerp(this.translation, this.keyframes[this.currKeyframe].translation, this.keyframes[this.currKeyframe+1].translation, ratio);
            vec3.lerp(this.rotation, this.keyframes[this.currKeyframe].rotation, this.keyframes.rotation[this.currKeyframe+1], ratio);
            vec3.lerp(this.scale, this.keyframes[this.currKeyframe].scale, this.keyframes.scale[this.currKeyframe+1], ratio);

            }

            var animation = mat4.create();
             mat4.translate(animation, animation, this.translation);
             mat4.rotate(animation, animation, this.rotation[0]*DEGREE_TO_RAD, [1, 0, 0]);
             mat4.rotate(animation, animation, this.rotation[1]*DEGREE_TO_RAD, [0, 1, 0]);
             mat4.rotate(animation, animation, this.rotation[2]*DEGREE_TO_RAD, [0, 0, 1]);
             mat4.scale(animation, animation, this.scale);
    
            this.transMatrix = animation;
        

    }


    apply(){
        this.scene.multMatrix(this.transMatrix);
    }
};
