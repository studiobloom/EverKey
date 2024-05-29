import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController, ARSessionDelegate {

    @IBOutlet var arView: ARView!
    @IBOutlet var messageLabel: RoundedLabel!

    private var cameraPlane: ModelEntity?
    private var isPlaneCreated = false
    private var effectSwitch: UISwitch!
    private var segmentedControl: UISegmentedControl!
    private var currentEffect: EffectMode = .depthkey

    enum EffectMode {
        case depthkey
        case chromaKey
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        arView.session.delegate = self
        arView.automaticallyConfigureSession = false // Disable automatic session configuration
        setupSegmentedControl()
        setupEffectSwitch()
        setupGestureRecognizers()
        configureARSession()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyCurrentEffect()
    }

    private func configureARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.environmentTexturing = .none // Disable environment lighting
        arView.session.run(configuration)
    }

    private func setupSegmentedControl() {
        let items = ["Depth Key", "Chroma Key"]
        segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            segmentedControl.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
        
        self.view.bringSubviewToFront(segmentedControl)
    }

    private func setupEffectSwitch() {
        effectSwitch = UISwitch()
        effectSwitch.isOn = false
        effectSwitch.addTarget(self, action: #selector(effectSwitchValueChanged(_:)), for: .valueChanged)
        
        effectSwitch.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(effectSwitch)
        
        NSLayoutConstraint.activate([
            effectSwitch.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10),
            effectSwitch.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
        
        self.view.bringSubviewToFront(effectSwitch)
    }

    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        // Turn off the current effect before switching
        effectSwitch.isOn = false
        applyCurrentEffect()

        // Update the current effect mode
        switch sender.selectedSegmentIndex {
        case 0:
            currentEffect = .depthkey
            messageLabel.displayMessage("Depth Key Mode", duration: 1.0)
        case 1:
            currentEffect = .chromaKey
            messageLabel.displayMessage("Chroma Key Mode", duration: 1.0)
        default:
            break
        }
    }

    @objc private func effectSwitchValueChanged(_ sender: UISwitch) {
        applyCurrentEffect()
    }

    private func applyCurrentEffect() {
        switch currentEffect {
        case .depthkey:
            togglePeopleOcclusion(isOn: effectSwitch.isOn)
        case .chromaKey:
            toggleChromaKey(isOn: effectSwitch.isOn)
        }
    }

    fileprivate func togglePeopleOcclusion(isOn: Bool) {
        guard let config = arView.session.configuration as? ARWorldTrackingConfiguration else {
            fatalError("Unexpectedly failed to get the configuration.")
        }
        guard ARWorldTrackingConfiguration.supportsFrameSemantics([.personSegmentationWithDepth, .personSegmentation]) else {
            fatalError("Depth Key is not supported on this device.")
        }
        if isOn {
            config.frameSemantics.insert([.personSegmentationWithDepth, .personSegmentation])
            messageLabel.displayMessage("Depth Key Enabled", duration: 1.0)
        } else {
            config.frameSemantics.remove([.personSegmentationWithDepth, .personSegmentation])
            messageLabel.displayMessage("Depth Key Disabled", duration: 1.0)
        }
        arView.session.run(config)
    }

    private func toggleChromaKey(isOn: Bool) {
        if isOn {
            messageLabel.displayMessage("Chroma Key Enabled", duration: 1.0)
            // Add the chroma key setup here
        } else {
            messageLabel.displayMessage("Chroma Key Disabled", duration: 1.0)
            // Remove the chroma key effect here
        }
    }

    private func setupCameraPlane() {
        let planeMesh = MeshResource.generatePlane(width: 1.0, height: 1.0)
        let planeMaterial = UnlitMaterial(color: .black)
        let planeEntity = ModelEntity(mesh: planeMesh, materials: [planeMaterial])

        // Position the plane far back and scale it to cover the entire screen
        let distance: Float = 100.0 // Position the plane 100 meters in front of the camera
        let scaleFactor: Float = 200.0 // Adjust this to ensure it covers the screen at that distance

        planeEntity.scale = [scaleFactor, scaleFactor, 1]
        planeEntity.position = [0, 0, -distance]

        let cameraAnchor = AnchorEntity(.camera)
        cameraAnchor.addChild(planeEntity)

        arView.scene.addAnchor(cameraAnchor)
        cameraPlane = planeEntity
    }

    private func setupGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        arView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func onTap(_ sender: UITapGestureRecognizer) {
        // Empty tap action to ensure ARView recognizes taps
    }

    // ARSessionDelegate method to detect when tracking is properly established
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if (!isPlaneCreated) {
            setupCameraPlane()
            isPlaneCreated = true
        }
    }
}
