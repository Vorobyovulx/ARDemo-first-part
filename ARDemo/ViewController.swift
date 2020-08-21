import UIKit
import SceneKit
import ARKit

@available(iOS 11.3, *)
class ViewController: UIViewController {

    @IBOutlet private var sceneView: ARSCNView!
    
    private let configuration = ARWorldTrackingConfiguration()
    
    var planes = [Plane]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        sceneView.delegate = self
        
        let imageTexture = UIImage(named: "mad_texture.png")
        let colorTexture = UIColor.red
        
        // Создаем сцену
        let scene = SCNScene()
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        configuration.planeDetection = [.horizontal, .vertical]
        
        addNewCubeModel(
            size: 0.2,
            position: SCNVector3(0, 0, -1.0),
            texture: colorTexture,
            scene: scene
        )
        
        addNewCubeModel(
            size: 0.2,
            position: SCNVector3(0, 0, -1.0),
            texture: imageTexture,
            scene: scene
        )
        
        addNewTextModel(
            text: "This is Mad Box",
            scale: SCNVector3(0.005, 0.005, 0.005),
            position: SCNVector3(-0.2, 0.3, -1.0),
            depth: 3.0,
            color: .orange,
            scene: scene
        )
        
        addNewModel(
            withPath: "art.scnassets/dance/dance.dae",
            scale: SCNVector3(0.07, 0.07, 0.07),
            position: SCNVector3(-0.25, -0.1, -1.0),
            scene: scene
        )
        
        addNewModel(
            withPath: "art.scnassets/dance/dance.dae",
            scale: SCNVector3(0.07, 0.07, 0.07),
            position: SCNVector3(0.25, -0.1, -1.0),
            scene: scene
        )
        
        addNewModel(
            withPath: "art.scnassets/dance/dance.dae",
            scale: SCNVector3(0.07, 0.07, 0.07),
            position: SCNVector3(0, -0.1, -1.5),
            scene: scene
        )
        
        //addFloor(to: scene)
        
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
    
    private func addNewCubeModel(size: CGFloat, position: SCNVector3, texture: Any?, scene: SCNScene) {
        // Создаем геометрию - каркас
        let boxGeometry = SCNBox(
            width: size,
            height: size,
            length: size,
            chamferRadius: 0
        )
        
        // Создаем набор атрибутов, определяющих внешний вид поверхности геометрии при визуализации
        let material = SCNMaterial()
        material.diffuse.contents = texture
        
        // Структурный элемент графа сцены, представляющий положение и преобразование в трехмерном координатном пространстве, к которому вы можете прикрепить геометрию, источники света, камеры или другой отображаемый контент.
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.geometry?.materials = [material]
        boxNode.position = position
        
        scene.rootNode.addChildNode(boxNode)
    }
    
    private func addNewTextModel(text: String, scale: SCNVector3, position: SCNVector3, depth: CGFloat, color: UIColor, scene: SCNScene) {
        let textGeometry = SCNText(string: text, extrusionDepth: depth)
        
        let textMaterial = SCNMaterial()
        textMaterial.diffuse.contents = color
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.scale = scale
        textNode.geometry?.materials = [textMaterial]
        textNode.position = position
        
        scene.rootNode.addChildNode(textNode)
    }
    
    private func addNewModel(withPath: String, scale: SCNVector3, position: SCNVector3, scene: SCNScene) {
        let node = SCNNode()
        
        guard let loadedScene = SCNScene(named: withPath) else {
            return
        }
        
        loadedScene.rootNode.childNodes.forEach {
            node.addChildNode($0 as SCNNode)
        }
        
        node.scale = scale
        node.position = position
        
        scene.rootNode.addChildNode(node)
    }
    
    private func addFloor(to scene: SCNScene) {
        let floor = SCNFloor()
        floor.reflectivity = 0.5
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "mad_texture.jpg")
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(50, 50, 0)
        // Координата текстуры S измеряет горизонтальную ось
        material.diffuse.wrapS = .repeat
        // Координата текстуры T измеряет вертикальную ось
        material.diffuse.wrapT = .repeat
        
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(x: 0, y: -0.1, z: 0)
        floorNode.geometry?.materials = [material]
        
        scene.rootNode.addChildNode(floorNode)
    }
    
}

@available(iOS 11.3, *)
extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        let plane = Plane(anchor: planeAnchor)
        
        planes.append(plane)
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let plane = planes.filter {
            $0.anchor.identifier == anchor.identifier
        }.first
        
        guard let uPlane = plane else {
            return
        }
        
        uPlane.update(anchor: anchor as! ARPlaneAnchor)
    }
}













