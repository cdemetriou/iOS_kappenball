//
//  ViewController.h
//  Kappenball
//
//  Created by Christos Demetriou on 28/10/2016.
//  Copyright © 2016 acq16cd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ballView.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) ballView* ballrect;
@property (nonatomic, strong) NSTimer* Timer;
@property (nonatomic, strong) UIImageView* gameEnvironment;
@property (nonatomic, strong) UIImageView* touchImgL;
@property (nonatomic, strong) UIImageView* touchImgR;

@property (nonatomic, weak) IBOutlet UIButton* startButton;
@property (nonatomic, weak) IBOutlet UIButton* resetButton;
@property (nonatomic, weak) IBOutlet UIButton* pauseButton;
@property (nonatomic, weak) IBOutlet UISlider* slider;
@property (nonatomic, weak) IBOutlet UILabel* scoreLabel;
@property (nonatomic, weak) IBOutlet UILabel* meanEnergyLabel;
@property (nonatomic, weak) IBOutlet UILabel* energyLabel;
@property (nonatomic, weak) IBOutlet UILabel* bottomLabel;
@property (nonatomic, weak) IBOutlet UILabel* gamePausedLabel1;
@property (nonatomic, weak) IBOutlet UILabel* gamePausedLabel2;
@property (nonatomic, weak) IBOutlet UILabel* gameResetedLabel;

@property (nonatomic, assign) int originX;
@property (nonatomic, assign) int originY;
@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;
@property (nonatomic, assign) int newAttempt;
@property (nonatomic, assign) int score;
@property (nonatomic, assign) float randomness;
@property (nonatomic, assign) float velocity;
@property (nonatomic, assign) float acceleration;
@property (nonatomic, assign) int energy;
@property (nonatomic, assign) float meanEnergy;
@property (nonatomic, assign) int totalEnergy;

-(IBAction)startButtonPressed:(id)sender;
-(IBAction)resetPressed:(id)sender;
-(IBAction)pausePressed:(id)sender;
-(IBAction)sliderMoved:(id)sender;

-(float)xChangeCalculation;
-(void)initializeVariables;
-(void)customizeObjects;
-(void)addObjectsToSuperview;
-(void)loadTouchImage;
-(void)updateLabels;

@end

