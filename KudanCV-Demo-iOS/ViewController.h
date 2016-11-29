#import <UIKit/UIKit.h>
#import "CameraAccess.h"

@interface ViewController : UIViewController <CameraFrameEvent>

@property (nonatomic, weak) IBOutlet UILabel *stateLabel;
@property (nonatomic, weak) IBOutlet UILabel *trackerLabel;

@property (nonatomic, weak) IBOutlet UIImageView *cameraImageView;

@property (nonatomic, weak) IBOutlet UIButton *arbitrackButton;
@property (nonatomic, weak) IBOutlet UILabel *arbitrackLabel;


- (IBAction)arbitrackAction:(id)sender;


@end
