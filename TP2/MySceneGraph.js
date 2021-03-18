const DEGREE_TO_RAD = Math.PI / 180;

// Order of the groups in the XML document.
var INITIALS_INDEX = 0;
var VIEWS_INDEX = 1;
var ILLUMINATION_INDEX = 2;
var LIGHTS_INDEX = 3;
var TEXTURES_INDEX = 4;
var MATERIALS_INDEX = 5;
var ANIMATIONS_INDEX = 6;
var NODES_INDEX = 7;

/**
 * MySceneGraph class, representing the scene graph.
 */
class MySceneGraph {
    /**
     * Constructor for MySceneGraph class.
     * Initializes necessary variables and starts the XML file reading process.
     * @param {string} filename - File that defines the 3D scene
     * @param {XMLScene} scene
     */
    constructor(filename, scene) {
        this.loadedOk = null;

        // Establish bidirectional references between scene and graph.
        this.scene = scene;
        scene.graph = this;

        this.nodes = [];

        this.idRoot = null; // The id of the root element.

        this.axisCoords = [];
        this.axisCoords['x'] = [1, 0, 0];
        this.axisCoords['y'] = [0, 1, 0];
        this.axisCoords['z'] = [0, 0, 1];

        // File reading
        this.reader = new CGFXMLreader();

        /*
         * Read the contents of the xml file, and refer to this class for loading and error handlers.
         * After the file is read, the reader calls onXMLReady on this object.
         * If any error occurs, the reader calls onXMLError on this object, with an error message
         */
        this.reader.open('scenes/' + filename, this);
    }

    /*
     * Callback to be executed after successful reading
     */
    onXMLReady() {
        this.log("XML Loading finished.");
        var rootElement = this.reader.xmlDoc.documentElement;

        // Here should go the calls for different functions to parse the various blocks
        var error = this.parseXMLFile(rootElement);

        if (error != null) {
            this.onXMLError(error);
            return;
        }

        this.loadedOk = true;

        // As the graph loaded ok, signal the scene so that any additional initialization depending on the graph can take place
        this.scene.onGraphLoaded();
    }

    /*
     * Callback to be executed on any read error, showing an error on the console.
     * @param {string} message
     */
    onXMLError(message) {
        console.error("XML Loading Error: " + message);
        this.loadedOk = false;
    }

    /**
     * Callback to be executed on any minor error, showing a warning on the console.
     * @param {string} message
     */
    onXMLMinorError(message) {
        console.warn("Warning: " + message);
    }

    /**
     * Callback to be executed on any message.
     * @param {string} message
     */
    log(message) {
        console.log("   " + message);
    }

    /**
     * Parses the XML file, processing each block.
     * @param {XML root element} rootElement
     */
    parseXMLFile(rootElement) {
        if (rootElement.nodeName != "lsf")
            return "root tag <lsf> missing";

        var nodes = rootElement.children;

        // Reads the names of the nodes to an auxiliary buffer.
        var nodeNames = [];

        for (var i = 0; i < nodes.length; i++) {
            nodeNames.push(nodes[i].nodeName);
        }

        var error;

        // Processes each node, verifying errors.

        // <initials>
        var index;
        if ((index = nodeNames.indexOf("initials")) == -1)
            return "tag <initials> missing";
        else {
            if (index != INITIALS_INDEX)
                this.onXMLMinorError("tag <initials> out of order " + index);

            //Parse initials block
            if ((error = this.parseInitials(nodes[index])) != null)
                return error;
        }

        // <views>
        if ((index = nodeNames.indexOf("views")) == -1)
            return "tag <views> missing";
        else {
            if (index != VIEWS_INDEX)
                this.onXMLMinorError("tag <views> out of order");

            //Parse views block
            if ((error = this.parseViews(nodes[index])) != null)
                return error;
        }

        // <illumination>
        if ((index = nodeNames.indexOf("illumination")) == -1)
            return "tag <illumination> missing";
        else {
            if (index != ILLUMINATION_INDEX)
                this.onXMLMinorError("tag <illumination> out of order");

            //Parse illumination block
            if ((error = this.parseIllumination(nodes[index])) != null)
                return error;
        }

        // <lights>
        if ((index = nodeNames.indexOf("lights")) == -1)
            return "tag <lights> missing";
        else {
            if (index != LIGHTS_INDEX)
                this.onXMLMinorError("tag <lights> out of order");

            //Parse lights block
            if ((error = this.parseLights(nodes[index])) != null)
                return error;
        }
        // <textures>
        if ((index = nodeNames.indexOf("textures")) == -1)
            return "tag <textures> missing";
        else {
            if (index != TEXTURES_INDEX)
                this.onXMLMinorError("tag <textures> out of order");

            //Parse textures block
            if ((error = this.parseTextures(nodes[index])) != null)
                return error;
        }

        // <materials>
        if ((index = nodeNames.indexOf("materials")) == -1)
            return "tag <materials> missing";
        else {
            if (index != MATERIALS_INDEX)
                this.onXMLMinorError("tag <materials> out of order");

            //Parse materials block
            if ((error = this.parseMaterials(nodes[index])) != null)
                return error;
        }

        // <animations>
        if ((index = nodeNames.indexOf("animations")) == -1)
            return "tag <animations> missing";
        else {
            if (index != ANIMATIONS_INDEX)
                this.onXMLMinorError("tag <animations> out of order");

            //Parse animations block
            if ((error = this.parseAnimations(nodes[index])) != null)
                return error;
        } 

        // <nodes>
        if ((index = nodeNames.indexOf("nodes")) == -1)
            return "tag <nodes> missing";
        else {
            if (index != NODES_INDEX)
                this.onXMLMinorError("tag <nodes> out of order");

            //Parse nodes block
            if ((error = this.parseNodes(nodes[index])) != null)
                return error;
        }
        this.log("all parsed");
    }

    /**
     * Parses the <initials> block.
     * @param {initials block element} initialsNode
     */
    parseInitials(initialsNode) {
        var children = initialsNode.children;
        var nodeNames = [];

        for (var i = 0; i < children.length; i++)
            nodeNames.push(children[i].nodeName);

        var rootIndex = nodeNames.indexOf("root");
        var referenceIndex = nodeNames.indexOf("reference");

        // Get root of the scene.
        if(rootIndex == -1)
            return "No root id defined for scene.";

        var rootNode = children[rootIndex];
        var id = this.reader.getString(rootNode, 'id');
        if (id == null)
            return "No root id defined for scene.";

        this.idRoot = id;

        // Get axis length
        if(referenceIndex == -1)
            this.onXMLMinorError("no axis_length defined for scene; assuming 'length = 1'");

        var refNode = children[referenceIndex];
        var axis_length = this.reader.getFloat(refNode, 'length');
        if (axis_length == null)
            this.onXMLMinorError("no axis_length defined for scene; assuming 'length = 1'");

        this.referenceLength = axis_length || 1;

        this.log("Parsed initials");

        return null;
    }

    /**
     * Parses the <views> block.
     * @param {view block element} viewsNode
     */
    parseViews(viewsNode) {

        this.views = [];
        var children = viewsNode.children;
        var nodeNames = [];

        let viewNodes = viewsNode.children;
        for(let view of viewNodes)
        {

                let id = this.reader.getString(view, "id", true);
                let near = this.reader.getFloat(view, "near", true);
                let far = this.reader.getFloat(view, "far", true);

                if (view.nodeName == "perspective"){
                    let angle = this.reader.getFloat(view, "angle", true);

                    nodeNames = [];
                for (var i = 0; i < view.children.length; i++)
                    nodeNames.push(view.children[i].nodeName);

                var fromIndex = nodeNames.indexOf("from");
                var toIndex = nodeNames.indexOf("to");

                let position = vec4.fromValues(...this.parseCoordinates3D(view.children[fromIndex], "from node"));
                let target = vec4.fromValues(...this.parseCoordinates3D(view.children[toIndex], "to node"));

                this.views[id] = new CGFcamera(angle, near, far, position, target);
            }
            else if ("ortho") {
                let left = this.reader.getFloat(view, "left", true);
                let right = this.reader.getFloat(view, "right", true);
                let top = this.reader.getFloat(view, "top", true);
                let bottom = this.reader.getFloat(view, "bottom", true);

            nodeNames =[];
                for (var i = 0; i < view.children.length; i++)
                    nodeNames.push(view.children[i].nodeName);

                var fromIndex = nodeNames.indexOf("from");
                var toIndex = nodeNames.indexOf("to");
                var upIndex = nodeNames.indexOf("up");

                let position = vec4.fromValues(...this.parseCoordinates3D(view.children[fromIndex], "from node"));
                let target = vec4.fromValues(...this.parseCoordinates3D(view.children[toIndex], "to node"));
                let up;
                if (upIndex == -1) {
                    up = vec4.fromValues(0, 1, 0);
                } else {
                    up = vec4.fromValues(...this.parseCoordinates3D(view.children[upIndex], "up node"));
                }

                this.views[id] = new CGFcameraOrtho(left, right, bottom, top, near, far, position, target, up);


            }
        }
        this.scene.interface.setActiveCamera(this.scene.camera);
        this.log("Parsed Views");
        return null;
    }

    /**
     * Parses the <illumination> node.
     * @param {illumination block element} illuminationsNode
     */
    parseIllumination(illuminationsNode) {

        var children = illuminationsNode.children;

        this.ambient = [];
        this.background = [];

        var nodeNames = [];

        for (var i = 0; i < children.length; i++)
            nodeNames.push(children[i].nodeName);

        var ambientIndex = nodeNames.indexOf("ambient");
        var backgroundIndex = nodeNames.indexOf("background");

        var color = this.parseColor(children[ambientIndex], "ambient");
        if (!Array.isArray(color))
            return color;
        else
            this.ambient = color;

        color = this.parseColor(children[backgroundIndex], "background");
        if (!Array.isArray(color))
            return color;
        else
            this.background = color;

        this.log("Parsed Illumination.");

        return null;
    }

    /**
     * Parses the <light> node.
     * @param {lights block element} lightsNode
     */
    parseLights(lightsNode) {
        var children = lightsNode.children;

        this.lights = [];
        var numLights = 0;

        var grandChildren = [];
        var nodeNames = [];

        // Any number of lights.
        for (var i = 0; i < children.length; i++) {

            // Storing light information
            var global = [];
            var attributeNames = [];
            var attributeTypes = [];

            //Check type of light
            if (children[i].nodeName != "light") {
                this.onXMLMinorError("unknown tag <" + children[i].nodeName + ">");
                continue;
            }
            else {
                attributeNames.push(...["enable", "position", "ambient", "diffuse", "specular"]);
                attributeTypes.push(...["boolean","position", "color", "color", "color"]);
            }

            // Get id of the current light.
            var lightId = this.reader.getString(children[i], 'id');
            if (lightId == null)
                return "no ID defined for light";

            // Checks for repeated IDs.
            if (this.lights[lightId] != null)
                return "ID must be unique for each light (conflict: ID = " + lightId + ")";

            grandChildren = children[i].children;
            // Specifications for the current light.

            nodeNames = [];
            for (var j = 0; j < grandChildren.length; j++) {
                nodeNames.push(grandChildren[j].nodeName);
            }

            for (var j = 0; j < attributeNames.length; j++) {
                var attributeIndex = nodeNames.indexOf(attributeNames[j]);

                if (attributeIndex != -1) {
                    if (attributeTypes[j] == "boolean")
                        var aux = this.parseBoolean(grandChildren[attributeIndex], "value", "enabled attribute for light of ID" + lightId);
                    else if (attributeTypes[j] == "position")
                        var aux = this.parseCoordinates4D(grandChildren[attributeIndex], "light position for ID" + lightId);
                    else
                        var aux = this.parseColor(grandChildren[attributeIndex], attributeNames[j] + " illumination for ID" + lightId);

                    if (typeof aux === 'string')
                        return aux;

                    global.push(aux);
                }
                else
                    return "light " + attributeNames[i] + " undefined for ID = " + lightId;
            }
            this.lights[lightId] = global;
            numLights++;
        }

        if (numLights == 0)
            return "at least one light must be defined";
        else if (numLights > 8)
            this.onXMLMinorError("too many lights defined; WebGL imposes a limit of 8 lights");

        this.log("Parsed lights");
        return null;
    }

    /**
     * Parses the <textures> block.
     * @param {textures block element} texturesNode
     */
    parseTextures(texturesNode) {
        var children = texturesNode.children;

        this.textures = [];
        var numTextures = 0;

        var nodeNames = [];


        for (var i=0; i<children.length; i++){

          if (children[i].nodeName != "texture") {
              this.onXMLMinorError("unknown tag <" + children[i].nodeName + ">");
              continue;
          }

          var textureID = this.reader.getString(children[i], 'id');
          if (textureID == null)
              return "no ID defined for texture";

          // Checks for repeated IDs.
          if (this.textures[textureID] != null)
              return "ID must be unique for each texture (conflict: ID = " + textureID + ")";

          var path = this.reader.getString(children[i], 'path');
          if (path == null)
              return "no path defined for texture";

          var texture = new CGFtexture(this.scene, path);

          this.textures[textureID] = texture;

        }

        this.log("Parsed Textures")
        return null;
    }


    /**
     * Parses the <materials> node.
     * @param {materials block element} materialsNode
     */
    parseMaterials(materialsNode) {
        var children = materialsNode.children;

        this.materials = [];

        var grandChildren = [];
        var nodeNames = [];
        var attributeNames = [];
        var attributeTypes = [];


        // Any number of materials.
        for (var i = 0; i < children.length; i++) {
            var mat = new Object();
            if (children[i].nodeName != "material") {
                this.onXMLMinorError("unknown tag <" + children[i].nodeName + ">");
                continue;
            }
            else {
                attributeNames.push(...["shininess", "ambient", "diffuse", "specular", "emissive"]);
                attributeTypes.push(...["float","color", "color", "color", "color"]);

            // Get id of the current material.
            var materialID = this.reader.getString(children[i], 'id');
            if (materialID == null)
                return "no ID defined for material";
                mat.id = materialID;
            // Checks for repeated IDs.
            if (this.materials[materialID] != null)
                return "ID must be unique for each material (conflict: ID = " + materialID + ")";

                grandChildren = children[i].children;
                // Specifications for the current material  .

                nodeNames = [];
                for (var j = 0; j < grandChildren.length; j++) {
                    nodeNames.push(grandChildren[j].nodeName);
                }

                var shininessIndex = nodeNames.indexOf("shininess");
                var ambientIndex = nodeNames.indexOf("ambient");
                var diffuseIndex = nodeNames.indexOf("diffuse");
                var specularIndex = nodeNames.indexOf("specular");
                var emissionIndex = nodeNames.indexOf("emissive");


                if (shininessIndex != -1){
                  var aux = this.reader.getFloat(grandChildren[shininessIndex], 'value');

                  var shininess = aux;
                }
                else
                  return "shininess component not defined for material with ID: " + materialID;

                if (ambientIndex != -1){
                  var aux = this.parseColor(grandChildren[ambientIndex], 'ambient' + " illumination for ID" + materialID);
                  if (!Array.isArray(aux))
                    return aux;
                  var ambient = aux;
                }
                else
                  return "ambient component not defined for material with ID: " + materialID;

                if (diffuseIndex != -1){
                  var aux = this.parseColor(grandChildren[diffuseIndex], 'diffuse' + " illumination for ID" + materialID);
                  if (!Array.isArray(aux))
                    return aux;
                  var diffuse = aux;
                }
                else
                  return "diffuse component not defined for material with ID: " + materialID;

                if (specularIndex != -1){
                  var aux = this.parseColor(grandChildren[specularIndex], 'specular' + " illumination for ID" + materialID);
                  if (!Array.isArray(aux))
                    return aux;
                  var specular = aux;
                }
                else
                  return "specular component not defined for material with ID: " + materialID;

                if (emissionIndex != -1){
                  var aux = this.parseColor(grandChildren[emissionIndex], 'emission' + " illumination for ID" + materialID);
                  if (!Array.isArray(aux))
                    return aux;
                  var emission = aux;
                }
                else
                  return "emission component not defined for material with ID: " + materialID;

                var material = new CGFappearance(this.scene);
                material.setShininess(shininess);
                material.setAmbient(ambient[0], ambient[1], ambient[2], ambient[3]);
                material.setDiffuse(diffuse[0], diffuse[1], diffuse[2], diffuse[3]);
                material.setSpecular(specular[0], specular[1], specular[2], specular[3]);
                material.setEmission(emission[0], emission[1], emission[2], emission[3]);
                this.materials[materialID] = material;
            }

        }

        this.log("Parsed Materials");
        //console.log(this.materials);
        return null;
    }



    /**
   * Parses the <nodes> block.
   * @param {nodes block element} nodesNode
   */

    parseNodes(nodesNode)
    {
        var children = nodesNode.children;

        this.nodes = [];
        var grandChildren = [];
        var nodeNames = [];

        this.children=[];
        this.transformations=[];
        this.materialNode=[];
        this.textureNode=[];
        this.primitives=[];

        var material;
        var texture;
        var transformations;
        var leafDescendants;
        var nodeDescendants;
        var animation;


        // Any number of nodes.
        for (var i = 0; i < children.length; i++) {

          if (children[i].nodeName != "node") {
              this.onXMLMinorError("unknown tag <" + children[i].nodeName + ">");
              continue;
          }

          // Get id of the current node.
          var nodeID = this.reader.getString(children[i], 'id');
          if (nodeID == null)
              return "no ID defined for nodeID";

          // Checks for repeated IDs.
          if (this.nodes[nodeID] != null)
              return "ID must be unique for each node (conflict: ID = " + nodeID + ")";


          grandChildren = children[i].children;

          nodeNames = [];
          for (var j = 0; j < grandChildren.length; j++) {
              nodeNames.push(grandChildren[j].nodeName);
          }

          var materialIndex = nodeNames.indexOf("material");
          var textureIndex = nodeNames.indexOf("texture");
          var transformationsIndex = nodeNames.indexOf("transformations");
          var descendantsIndex = nodeNames.indexOf("descendants");
          var animationIndex = nodeNames.indexOf("animations");

          if (materialIndex != -1){
            material = this.parseNodeMaterial(grandChildren[materialIndex]);
          }

          if (textureIndex != -1){
            texture = this.parseNodeTexture(grandChildren[textureIndex]);
          }

          if (transformationsIndex != -1){
            transformations = this.parseNodeTransformations(grandChildren[transformationsIndex]);
          }

          if (descendantsIndex != -1){
            leafDescendants = this.parseLeafDescendants(grandChildren[descendantsIndex]);
            nodeDescendants = this.parseNodeDescendants(grandChildren[descendantsIndex]);

          }

          if (animationIndex != -1){
            animation = this.parseAnimation(grandChildren[animationIndex]);
          }

          var newNode = new MyNode(children[i].id, material, texture, transformations, leafDescendants, nodeDescendants, animation);
          this.nodes.push(newNode);

        }

        this.log("Parsed Nodes");
        return null;
    }

    parseNodeMaterial(material){
      var materialID = this.reader.getString(material,'id');

      return materialID;
    }

    parseNodeTexture(texture){

      var textureID = this.reader.getString(texture,'id');
      var children = texture.children;
      var textures = [];

      textures.push(textureID);

      for(var i=0;i < children.length; i++)
      {
          var aux=[];
          if(children[i].nodeName == "amplification")
          {
              var afs = this.reader.getFloat(children[i],'afs');
              var aft = this.reader.getFloat(children[i],'aft');
              aux = [afs,aft];
              textures.push(aux);

      }
    }

    return textures;
  }

    parseNodeTransformations(transformations){

      var transMatrix = mat4.create();
      var children = transformations.children;

      if(children.length != 0)
      {
          //getting into the grandgrandChildren
          for(var j = 0; j < children.length; j++)
          {
              if(children[j].nodeName == "translation")
              {
                  var x = this.reader.getFloat(children[j], 'x', true);
                  var y = this.reader.getFloat(children[j], 'y', true);
                  var z = this.reader.getFloat(children[j], 'z', true);
                  //Matrix
                  mat4.translate(transMatrix, transMatrix, [x,y,z]);
              }

              else if(children[j].nodeName == "rotation")
              {
                  var axis = this.reader.getString(children[j], 'axis', true);
                  var angle = this.reader.getFloat(children[j], 'angle', true);
                  //Matrix
                  if(axis == "x")
                      mat4.rotateX(transMatrix , transMatrix , angle*DEGREE_TO_RAD);
                  else if(axis == "y")
                      mat4.rotateY(transMatrix , transMatrix , angle*DEGREE_TO_RAD);
                  else if(axis == "z")
                      mat4.rotateZ(transMatrix , transMatrix , angle*DEGREE_TO_RAD)
              }
              else if(children[j].nodeName == "scale")
              {
                  var x = this.reader.getFloat(children[j], 'sx', true);
                  var y = this.reader.getFloat(children[j], 'sy', true);
                  var z = this.reader.getFloat(children[j], 'sz', true);
                  //Matrix
                  mat4.scale(transMatrix , transMatrix , [x, y, z]);
              }
          }
      }

      return transMatrix;
    }

    parseLeafDescendants(descendants){

      var leafDescendants = [];
      var children = descendants.children;
      var aux=null;
      var leafType;

      for (var i=0; i<descendants.children.length; i++){

        if(descendants.children[i].nodeName =="leaf")
        {
            leafType=this.reader.getString(descendants.children[i],'type');
            this.log("LEAF TYPE: " + leafType);

            if(leafType=="rectangle")
            {
                var x1 = this.reader.getFloat(descendants.children[i], "x1");
                var y1 = this.reader.getFloat(descendants.children[i], "y1");
                var x2 = this.reader.getFloat(descendants.children[i], "x2");
                var y2 = this.reader.getFloat(descendants.children[i], "y2");
                aux = new MyRectangle(this.scene, x1, y1, x2, y2);

            }

            else if(leafType =="torus")
             {
                 var inner = this.reader.getFloat(descendants.children[i], "inner");
                 var outer = this.reader.getFloat(descendants.children[i], "outer");
                 var slices = this.reader.getFloat(descendants.children[i], "slices");
                 var loops = this.reader.getFloat(descendants.children[i], "loops");
                 aux = new MyTorus(this.scene, inner, outer, slices, loops);
            }
            else if(leafType =="triangle")
            {
                var x1 = this.reader.getFloat(descendants.children[i], "x1");
                var y1 = this.reader.getFloat(descendants.children[i], "y1");
                var x2 = this.reader.getFloat(descendants.children[i], "x2");
                var y2 = this.reader.getFloat(descendants.children[i], "y2");
                var x3 = this.reader.getFloat(descendants.children[i], "x3");
                var y3 = this.reader.getFloat(descendants.children[i], "y3");
                aux = new MyTriangle(this.scene);

            }
            else if(leafType =="sphere")
            {
                //var radius = this.reader.getFloat(children[i], "radius");
                var slices = this.reader.getFloat(descendants.children[i], "slices");
                var stacks = this.reader.getFloat(descendants.children[i], "stacks");
                aux = new MySphere(this.scene, slices, stacks);

            }
            else if(leafType =="cylinder")
            {
                var height = this.reader.getFloat(descendants.children[i], "height");
                var topRadius = this.reader.getFloat(descendants.children[i], "topRadius");
                var bottomRadius = this.reader.getFloat(descendants.children[i], "bottomRadius");
                var stacks = this.reader.getFloat(descendants.children[i], "stacks");
                var slices = this.reader.getFloat(descendants.children[i], "slices");
                aux = new MyCylinder(this.scene,slices, stacks, height, topRadius, bottomRadius);
            }
            else if (leafType =="defbarrel")
            {   
                var base = this.reader.getFloat(descendants.children[i], "base");
                var middle = this.reader.getFloat(descendants.children[i], "middle");
                var height = this.reader.getFloat(descendants.children[i], "height");
                var slices = this.reader.getFloat(descendants.children[i], "slices");
                var stacks = this.reader.getFloat(descendants.children[i], "stacks");
                aux = new MyCylinder2(this.scene,slices, height, middle, base, stacks);
            }
            else if (leafType =="plane")
            {   
                var npartsU = this.reader.getFloat(descendants.children[i], "npartsU");
                var npartsV = this.reader.getFloat(descendants.children[i], "npartsV");
                aux = new MyPlane(this.scene, npartsU, npartsV);
            }
/*             else if (leafType =="patch")
            {   
                var npartsU = this.reader.getFloat(descendants.children[i], "npartsU");
                var npartsV = this.reader.getFloat(descendants.children[i], "npartsV");
                var npointsU = this.reader.getFloat(descendants.children[i], "npointsU");
                var npointsV = this.reader.getFloat(descendants.children[i], "npointsV");
                aux = new MyPatch(this.scene, npartsU, npartsV, npointsU, npointsV);
            } */

            else
                return "Invalid leaf type - "+ leafType +" on descendant from node ";
            if(aux != null){
               leafDescendants.push(aux);
             }
           }
       }

      return leafDescendants;
    }

    parseNodeDescendants(descendants){

      var nodeDescendants = [];
      var children = descendants.children;
      var childrenID;


      for(var i = 0; i < descendants.children.length; i++)
      {
          if(descendants.children[i].nodeName =="noderef")
          {
              childrenID = this.reader.getString(descendants.children[i],'id');
              if(childrenID != null){
                  nodeDescendants.push(childrenID);
                }
          }
    }
    return nodeDescendants;
  }

  parseAnimations(animationsNode){
    var children = animationsNode.children;

    this.log("ANIMATIONS Node: " +  animationsNode.nodeName);

    this.animations = [];

    var grandChildren = [];
    var nodeNames = [];
    var animationKeyFrames = [];

    // Any number of animations.
    for (var i = 0; i < children.length; i++) {
        animationKeyFrames = [];

        
        this.log("ANIMATIONS CHILD NODE NAME: " + children[i].nodeName);

        if (children[i].nodeName != "animation") {
            this.onXMLMinorError("unknown tag <" + children[i].nodeName + ">");
            continue;
        }

        // Get id of the current animation.
        var animationID = this.reader.getString(children[i], 'id');
        this.log("ANIMATION ID: " + animationID);
        if (animationID == null)
            return "no ID defined for animation";
        // Checks for repeated IDs.
        if (this.animations[animationID] != null)
            return "ID must be unique for each animation (conflict: ID = " + animationID + ")";

        grandChildren = children[i].children;

        for (var j = 0; j < grandChildren.length; j++){
          this.log("ANIMATION CHILD NODE NAME: " + grandChildren[j].nodeName);

          if (grandChildren[j].nodeName != "keyframe"){
            this.onXMLMinorError("unknown tag <" + grandChildren[j].nodeName + ">");
            continue;
          }

          var keyframeInstant = this.reader.getFloat(grandChildren[j], 'instant');
          if (keyframeInstant == null)
              this.onXMLMinorError("No instant defined for keyframe");

              animationKeyFrames.push( new KeyFrame(0, [0,0,0], [0,0,0], [1, 1, 1]));

              
               var grandgrandChildren = grandChildren[j].children;
              for(var k = 0; k < grandgrandChildren.length; k++)
              {
                  if(grandgrandChildren[k].nodeName == "translation")
                  {
                      var tx = this.reader.getFloat(grandgrandChildren[k], 'x', true);
                      var ty = this.reader.getFloat(grandgrandChildren[k], 'y', true);
                      var tz = this.reader.getFloat(grandgrandChildren[k], 'z', true);
                  }
    
                  else if(grandgrandChildren[k].nodeName == "rotation")
                  {
                      var axis = this.reader.getString(grandgrandChildren[k], 'axis', true);
                      var angle = this.reader.getFloat(grandgrandChildren[k], 'angle', true);
                      //Matrix
                      if(axis == "x")
                      var rx = angle;
                      else if(axis == "y")
                      var ry = angle;
                      else if(axis == "z")
                      var rz = angle;
                  }
                  else if(grandgrandChildren[k].nodeName == "scale")
                  {
                      var sx = this.reader.getFloat(grandgrandChildren[k], 'sx', true);
                      var sy = this.reader.getFloat(grandgrandChildren[k], 'sy', true);
                      var sz = this.reader.getFloat(grandgrandChildren[k], 'sz', true);
                  }
              }

          var keyframe = new KeyFrame(keyframeInstant, [rx,ry,rz], [tx,ty,tz], [sx,sy,sz]);
          animationKeyFrames.push(keyframe);
          //console.log(animationKeyFrames);

        }
        var keyframeAnimation = new KeyframeAnimation(this.scene, animationKeyFrames);
        this.animations[animationID] = keyframeAnimation;
        //console.log(this.animations);

        }

    this.log("Parsed Animations");
    return null;
  }


    parseBoolean(node, name, messageError){
        var boolVal = true;
        boolVal = this.reader.getBoolean(node, name);
        if (!(boolVal != null && !isNaN(boolVal) && (boolVal == true || boolVal == false)))
            this.onXMLMinorError("unable to parse value component " + messageError + "; assuming 'value = 1'");

        return boolVal || 1;
    }
    /**
     * Parse the coordinates from a node with ID = id
     * @param {block element} node
     * @param {message to be displayed in case of error} messageError
     */
    parseCoordinates3D(node, messageError) {
        var position = [];

        // x
        var x = this.reader.getFloat(node, 'x');
        if (!(x != null && !isNaN(x)))
            return "unable to parse x-coordinate of the " + messageError;

        // y
        var y = this.reader.getFloat(node, 'y');
        if (!(y != null && !isNaN(y)))
            return "unable to parse y-coordinate of the " + messageError;

        // z
        var z = this.reader.getFloat(node, 'z');
        if (!(z != null && !isNaN(z)))
            return "unable to parse z-coordinate of the " + messageError;

        position.push(...[x, y, z]);

        return position;
    }

    /**
     * Parse the coordinates from a node with ID = id
     * @param {block element} node
     * @param {message to be displayed in case of error} messageError
     */
    parseCoordinates4D(node, messageError) {
        var position = [];

        //Get x, y, z
        position = this.parseCoordinates3D(node, messageError);

        if (!Array.isArray(position))
            return position;


        // w
        var w = this.reader.getFloat(node, 'w');
        if (!(w != null && !isNaN(w)))
            return "unable to parse w-coordinate of the " + messageError;

        position.push(w);

        return position;
    }

    /**
     * Parse the color components from a node
     * @param {block element} node
     * @param {message to be displayed in case of error} messageError
     */
    parseColor(node, messageError) {
        var color = [];

        // R
        var r = this.reader.getFloat(node, 'r');
        if (!(r != null && !isNaN(r) && r >= 0 && r <= 1))
            return "unable to parse R component of the " + messageError;

        // G
        var g = this.reader.getFloat(node, 'g');
        if (!(g != null && !isNaN(g) && g >= 0 && g <= 1))
            return "unable to parse G component of the " + messageError;

        // B
        var b = this.reader.getFloat(node, 'b');
        if (!(b != null && !isNaN(b) && b >= 0 && b <= 1))
            return "unable to parse B component of the " + messageError;

        // A
        var a = this.reader.getFloat(node, 'a');
        if (!(a != null && !isNaN(a) && a >= 0 && a <= 1))
            return "unable to parse A component of the " + messageError;

        color.push(...[r, g, b, a]);

        return color;
    }

    /**
     * Displays the scene, processing each node, starting in the root node.
     */
    displayScene() {
        //To do: Create display loop for transversing the scene graph, calling the root node's display function
        //this.nodes[this.idRoot].display()
        for (var i=0; i<this.nodes.length; i++){
          if (this.nodes[i].id == "demoRoot"){
            var idRoot = i;
            break;
          }
        }
        var texture = this.nodes[idRoot].texture;
        var material = this.nodes[idRoot].material;
        var node = this.nodes[idRoot];
        this.processNode(node, material, texture);

    }

    processNode(node, parentMaterial, parentTexture){

      this.scene.pushMatrix();
        // get node form array
        // get material/texture ---> apply
        //

        this.log("NODE MAT: " + node.material);
        this.log("NODE TEXT: " + node.texture[0]);


        var materialID = parentMaterial;
        var textureID = parentTexture;

        var currMaterial;
        var currTexture;


        if(this.materials.hasOwnProperty(materialID))
        {
            this.materials[materialID].apply();
            currMaterial=materialID;
        }
        else
        {
            this.materials[node.material].apply();
            currMaterial=node.material;
        }

        if(node.texture[0]=="null")
        {
            if(this.textures.hasOwnProperty(textureID))
            {
                this.log("THIS.TEXTURES: " + this.textures[textureID]);
                this.textures[textureID].bind();
                currTexture=textureID;
            }
        }
        else if(node.texture[0]!="clear")
        {
            var te=node.texture[0];
            this.log("THIS.TEXTURES: " + this.textures[te]);
            this.textures[te].bind();
            currTexture=node.texture[0];
        }


        this.log("CURRENT NODE: " + node.id);

        // APLICAR TRANFORMAÇÕES E IR BUSCAR MATRIZES //

        this.log("MATRIX: " + node.transformations);
        this.scene.multMatrix(node.transformations);


        // PERCORRER ARRAY DE LEAF DESCENDANTS, APLICAR TEXTURE E MATERIAL E DESENHAR A PRIMITIVA //
        for (var i = 0; i < node.leafDescendants.length; i++) {
            node.leafDescendants[i].display();
          }

        var newNodeIndex;

        // PERCORRER ARRAY DE NODE DESCENDANTS E CHAMAR O PROCESS NODE NO PROXIMO NODE

        for (var i=0; i<node.nodeDescendants.length; i++){
          for (var j=0; j<this.nodes.length; j++){
            if (this.nodes[j].id == node.nodeDescendants[i]){
              newNodeIndex = j;
              break;
            }
          }

           if(node.animationID!= null) {
            this.animations[node.animationID].apply();
        } 

          this.scene.pushMatrix();
          this.processNode(this.nodes[newNodeIndex], materialID, textureID);
        }
        this.scene.popMatrix();
        return null;
    }
}
