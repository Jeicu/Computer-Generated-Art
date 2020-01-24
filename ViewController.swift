
import UIKit

class ViewController: UIViewController {
  //stores the last drawn point on the canvas
  var lastPoint = CGPoint.zero
  //stores the current selected color
  var color = UIColor.black
  //stores brush stroke width
  var brushWidth: CGFloat = 10.0
  //stores brush opacity
  var opacity: CGFloat = 1.0
  //indicates if brush stroke is continuous
  var swiped = false
  
  //called when user puts finger on screen
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    //make sure there was a touch
    guard let touch = touches.first else {
      return
    }
    //touch hasnt moved yet
    swiped = false
    //save point of touch
    lastPoint = touch.location(in: view)
  }
  
  //draws line between two specified points
  func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
    // 1
    UIGraphicsBeginImageContext(view.frame.size)
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }
    tempImageView.image?.draw(in: view.bounds)
    
    // 2
    context.move(to: fromPoint)
    context.addLine(to: toPoint)
    
    // 3
    context.setLineCap(.round)
    context.setBlendMode(.normal)
    context.setLineWidth(brushWidth)
    context.setStrokeColor(color.cgColor)
    
    // 4
    context.strokePath()
    
    // 5
    tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    tempImageView.alpha = opacity
    UIGraphicsEndImageContext()
  }
  
  //calls drawLine when there is a swipe
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else {
      return
    }
    
    // 6
    swiped = true
    let currentPoint = touch.location(in: view)
    drawLine(from: lastPoint, to: currentPoint)
    
    // 7
    lastPoint = currentPoint
  }
  
  //called when finger taken off screen
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if !swiped {
      // draw a single point
      drawLine(from: lastPoint, to: lastPoint)
    }
    
    // Merge tempImageView into mainImageView
    UIGraphicsBeginImageContext(mainImageView.frame.size)
    mainImageView.image?.draw(in: view.bounds, blendMode: .normal, alpha: 1.0)
    tempImageView?.image?.draw(in: view.bounds, blendMode: .normal, alpha: opacity)
    mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    tempImageView.image = nil
  }
  
  //configures new SettingsViewController by setting itself as delegate and pushing brush + opacity values
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard
      let navController = segue.destination as? UINavigationController,
      let settingsController = navController.topViewController as? SettingsViewController
      else {
        return
    }
    settingsController.delegate = self
    settingsController.brush = brushWidth
    settingsController.opacity = opacity
    //pass correct rgb values
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    color.getRed(&red, green: &green, blue: &blue, alpha: nil)
    settingsController.red = red
    settingsController.green = green
    settingsController.blue = blue
  }
  
  @IBOutlet weak var mainImageView: UIImageView!
  @IBOutlet weak var tempImageView: UIImageView!
  
  //reset picture
  @IBAction func resetPressed(_ sender: Any) {
    mainImageView.image = nil
  }
  
  //check for image, then share
  @IBAction func sharePressed(_ sender: Any) {
    guard let image = mainImageView.image else {
      return
    }
    let activity = UIActivityViewController(activityItems: [image],
                                            applicationActivities: nil)
    present(activity, animated: true)
  }
  
  @IBAction func pencilPressed(_ sender: UIButton) {
    //check that there is a valid tag set
    guard let pencil = Pencil(tag: sender.tag) else {
      return
    }
    
    // select specified color
    color = pencil.color
    
    // opacity to 0, background to white for eraser
    if pencil == .eraser {
      opacity = 1.0
    }
  }
}

//update results of settings
extension ViewController: SettingsViewControllerDelegate {
  func settingsViewControllerFinished(_ settingsViewController: SettingsViewController) {
    brushWidth = settingsViewController.brush
    opacity = settingsViewController.opacity
    //update color
    color = UIColor(red: settingsViewController.red,
                    green: settingsViewController.green,
                    blue: settingsViewController.blue,
                    alpha: opacity)
    dismiss(animated: true)
  }
}
