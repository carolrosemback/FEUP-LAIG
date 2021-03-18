class KeyFrame{

  constructor(instant, rotation, translation, scale){
    this.instant = instant * 1000; //ms
    this.rotation = rotation;
    this.translation = translation;
    this.scale = scale;
  }

};
