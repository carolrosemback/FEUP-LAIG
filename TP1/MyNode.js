/**
 * MyNode
 * @constructor
 * @param id - id
 * @param material - material
 * @param texture - texture
 * @param transformations - array of transformation matrices
 * @param descendants - array of node descendants
 */
class MyNode{
	constructor(id, material, texture, transformations, leafDescendants, nodeDescendants) {
		this.id = id;
		this.material = material;
		this.texture = texture;
		this.transformations = transformations;
		this.leafDescendants = leafDescendants;
		this.nodeDescendants = nodeDescendants;
	}

}
