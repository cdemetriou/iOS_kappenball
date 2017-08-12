//
//  ViewController.m
//  Kappenball
//
//  Created by Christos Demetriou on 28/10/2016.
//  Copyright © 2016 acq16cd. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

// Constants for the borders of walls goals and spikes
#define SPIKES_Y 295
#define GOALS_Y 340

#define LEFTWALL 35
#define RIGHTWALL 703

#define LEFTGOAL_L 180
#define LEFTGOAL_R 237

#define RIGHTGOAL_L 494
#define RIGHTGOAL_R 558

// Constants used for calculating the change of the x
#define DT 0.1
#define DECAY 0.95
#define ACCELERATION 1.2


@interface ViewController ()

@end


@implementation ViewController

@synthesize newAttempt;
@synthesize score;
@synthesize energy;
@synthesize meanEnergy;
@synthesize totalEnergy;
@synthesize randomness;
@synthesize Timer;
@synthesize velocity;
@synthesize acceleration;
@synthesize originX, originY;
@synthesize x, y;
@synthesize touchImgL, touchImgR;


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeVariables];
    [self customizeObjects];
    [self loadTouchImage];

    // Create game environment with given image and add it to the view
    self.gameEnvironment = [[UIImageView alloc] initWithFrame:CGRectMake(4, 50, 730, 300)];
    self.gameEnvironment.image = [UIImage imageNamed:@"field.png"];
    [self.view addSubview:self.gameEnvironment];
    
    // Set alpha to zero for pause and reset labels
    self.gamePausedLabel1.alpha = 0;
    self.gamePausedLabel2.alpha = 0;
    self.gameResetedLabel.alpha = 0;

    // Get the bounds of the game environment and initialize origin x,y for the ball
    CGRect gameEnvironmentBounds = self.gameEnvironment.bounds;
    originX = (gameEnvironmentBounds.size.width) * 0.5;
    originY = 50;
}

// Load the image used for indicating the touch
-(void)loadTouchImage
{
    // Image for pushing ball to the left
    touchImgL = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    touchImgL.hidden = YES;
    touchImgL.alpha = 0.8;
    
    // Image for pushing ball to the right
    touchImgR = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    // Rotate image 180 degrees
    touchImgR.transform = CGAffineTransformMakeRotation(M_PI);
    touchImgR.hidden = YES;
    touchImgR.alpha = 0.8;
}

// Method invoked by the start button, initializing the ball and its parameters
// and calling the timer to begin the animation
-(IBAction)startButtonPressed:(id)sender
{
    // Remove the previous ball from the superview
    [self.ballrect removeFromSuperview];
    
    // Register new attept
    newAttempt += 1;
    
    // Initialize attempt variables
    energy = 0;
    velocity = 0;
    acceleration = 0;
    
    // Initialize pause button
    self.pauseButton.alpha = 1;
    self.pauseButton.enabled = TRUE;
    
    // Initialize new ball
    UIImage *ball = [UIImage imageNamed:@"ball.png"];
    self.ballrect = [[ballView alloc]initWithImage:ball];
    
    // Discard image after use
    ball = nil;
    
    // Set ball center to the origin position
    self.ballrect.center = CGPointMake(originX, originY);
    [self addObjectsToSuperview];
    
    [self startTimer];
}

// Method invoked by reset button
-(IBAction)resetPressed:(id)sender
{
    [self initializeVariables];
    [self stopTimer];
    self.gameResetedLabel.alpha = 0.8;
    
    // Animation removing the ball from the superview
    [UIView beginAnimations:@"ball.dissapear" context:nil];
    [UIView setAnimationDuration:0.5];
    self.ballrect.alpha = 0;
    [UIView commitAnimations];
    
    // Animation of the reseted label disappearing
    [UIView beginAnimations:@"gameResetedLabel.dissapear" context:nil];
    [UIView setAnimationDuration:3];
    self.gameResetedLabel.alpha = 0;
    [UIView commitAnimations];
}

// Method to control pausing and resuming the attempt
-(IBAction)pausePressed:(id)sender
{
    // Retrieving the current title of the button
    NSString *title = [(UIButton *)sender currentTitle];
    
    // Only able to use the button when the game is not won or lost yet
    if (y != SPIKES_Y && y != GOALS_Y)
    {
        // Actions taken when button title is Pause
        if ([title  isEqual: @"Pause"])
        {
            [self stopTimer];
            [self.pauseButton setTitle:@"Resume" forState:UIControlStateNormal];
            
            // Animation of notify label appearing
            [UIView beginAnimations:@"pause" context:nil];
            [UIView setAnimationDuration:0.5];
            self.gamePausedLabel1.alpha = 0.8;
            self.gamePausedLabel2.alpha = 0.8;
            [UIView commitAnimations];
            
            // Disable all other buttons
            self.startButton.enabled = FALSE;
            self.startButton.alpha = 0.5;
            self.resetButton.enabled = FALSE;
            self.resetButton.alpha = 0.5;
        }
        // Actions taken when button title is Resume
        else if ([title  isEqual: @"Resume"])
        {
            [self startTimer];
            [self.pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
            
            // Animation of notify label disappearing
            [UIView beginAnimations:@"resume" context:nil];
            [UIView setAnimationDuration:1];
            self.gamePausedLabel1.alpha = 0;
            self.gamePausedLabel2.alpha = 0;
            [UIView commitAnimations];
            
            // Enable all other buttons
            self.startButton.enabled = TRUE;
            self.startButton.alpha = 1;
            self.resetButton.enabled = TRUE;
            self.resetButton.alpha = 1;
        }
    }
}

// Get the sliders value to the randomness variable
-(IBAction)sliderMoved:(id)sender
{
    randomness = self.slider.value;
}

-(void)addObjectsToSuperview
{
    // Add ball to superview
    [self.view addSubview:self.ballrect];
    
    // Hierarchicaly add this label to make the ball dissapear after a goal is reached
    self.bottomLabel.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.bottomLabel];
    
    // Add buttons and slider
    [self.view addSubview:self.resetButton];
    [self.view addSubview:self.pauseButton];
    [self.view addSubview:self.startButton];
    [self.view addSubview:self.slider];
    
    // Add pause and reset labels
    [self.view addSubview:self.gamePausedLabel1];
    [self.view addSubview:self.gamePausedLabel2];
    [self.view addSubview:self.gameResetedLabel];
}

// Method controlling the animation of the ball
- (void) startAnimation
{
    // Get current ball coordinates
    x = self.ballrect.center.x;
    y = self.ballrect.center.y;
    
    // Set new ball coordinates
    x += [self xChangeCalculation];
    y++;
    
    // Conditions to reverse direction if the ball when it hits a wall
    if(x <= LEFTWALL || x >= RIGHTWALL)
    {
        if (acceleration == 0)
        {
            velocity = velocity * (-DECAY);
            if (x <= LEFTWALL)
            {
                x += 10 * DECAY;
            }
            else if (x >= RIGHTWALL)
            {
                x -= 10 * DECAY;
            }
        }
        else
        {
            velocity = 0;
            if (x <= LEFTWALL)
            {
                x += 10;
            }
            if (x >= RIGHTWALL)
            {
                x -= 10;
            }
        }
    }
    
    // Conditions to stop the timer when the ball hits the spikes
    if (y == SPIKES_Y)
    {
        // x coordinates where spikes lie
        if (( x >= LEFTWALL && x < LEFTGOAL_L) ||
            ( x > LEFTGOAL_R && x < RIGHTGOAL_L) ||
            ( x > RIGHTGOAL_R && x <= RIGHTWALL))
        {
            [self stopTimer];
            
            // Disable the Pause/Resume button
            self.pauseButton.enabled = FALSE;
            self.pauseButton.alpha = 0.5;
            
            // Animation of the ball dissapearing when it hits spikes
            [UIView beginAnimations:@"self.ballrect" context:nil];
            [UIView setAnimationDuration:1];
            self.ballrect.alpha = 0;
            [UIView commitAnimations];
            
            // Energy is added to the average energy
            if (energy != 0)
            {
                [self updateMeanEnergy];
            }
        }
    }
    
    // Conditions to reverse direction if the ball hits a wall within the goals
    if(y > SPIKES_Y)
    {
        // x coordinates of the walls in the goals. A range of x values are taken into account as to
        // avoid the ball going through the wall if the movement is too fast
        if (( x > LEFTGOAL_L-10 && x <= LEFTGOAL_L ) || ( x > RIGHTGOAL_L-10 && x <= RIGHTGOAL_L)||
            ( x < LEFTGOAL_R+10 && x >= LEFTGOAL_R ) || ( x < RIGHTGOAL_R+10 && x >= RIGHTGOAL_R))
        {
            if (acceleration == 0)
            {
                velocity = velocity * (-DECAY);
                if (( x > LEFTGOAL_L-10 && x <= LEFTGOAL_L ) || ( x > RIGHTGOAL_L-10 && x <= RIGHTGOAL_L))
                {
                    x += 10 * DECAY;
                }
                else if (( x < LEFTGOAL_R+10 && x >= LEFTGOAL_R ) || ( x < RIGHTGOAL_R+10 && x >= RIGHTGOAL_R))
                {
                    x -= 10 * DECAY;
                }
            }
            else
            {
                velocity = 0;
                if ((x > LEFTGOAL_L-20 && x <= LEFTGOAL_L ) || ( x > RIGHTGOAL_L-20 && x <= RIGHTGOAL_L))
                {
                    x += 10;
                }
                else if (( x < LEFTGOAL_R+20 && x >= LEFTGOAL_R ) || ( x < RIGHTGOAL_R+20 && x >= RIGHTGOAL_R))
                {
                    x -= 10;
                }
            }
        }
    }
    
    // Conditions to stop the timer when the ball passes the goals y coordinate and is within the goals limits
    if ((y == GOALS_Y + 20) &&
        (( x >= LEFTGOAL_L && x <= LEFTGOAL_R) || ( x >= RIGHTGOAL_L && x <= RIGHTGOAL_R )))
    {
        [self stopTimer];
        score++;
        
        // Disable the Pause/Resume button
        self.pauseButton.enabled = FALSE;
        self.pauseButton.alpha = 0.5;
        
        // Energy is added to the average energy
        if (energy != 0)
        {
            [self updateMeanEnergy];
        }
    }
    
    // Move the ball object to the new coordinates
    self.ballrect.center = CGPointMake(x , y);
    
    [self updateLabels];
}

// Method applying the given formula for change on x coordinate
-(float)xChangeCalculation
{
    float random = arc4random() % 40;
    velocity = (velocity * DECAY) + acceleration + (randomness * (-20 + random));
    float change = velocity * DT;
    
    // Return the change to be applied to x coordinate
    return change;
}

// Initialization of variables on game startup and resetting
-(void)initializeVariables
{
    newAttempt = 0;
    score = 0;
    energy = 0;
    totalEnergy = 0;
    meanEnergy = 0.0;
    [self updateLabels];
}

// Calculate the average energy spend
-(void)updateMeanEnergy
{
    totalEnergy += energy;
    meanEnergy = (float) totalEnergy/newAttempt;
}

// Update all labels based on their variable values at the time
-(void)updateLabels
{
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d / %d", score, newAttempt];
    self.meanEnergyLabel.text =[NSString stringWithFormat:@"Avg.Energy: %1.0f", meanEnergy];
    self.energyLabel.text = [NSString stringWithFormat:@"Energy: %d", energy];
}

// Method initializing the timer that calls the animation method
-(void)startTimer
{
    if(!Timer.isValid)
    {
        // Create timer with intervals of 0.02 secs callong the startAnimation method
        Timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(startAnimation) userInfo:nil repeats:YES];
    }
}

// Method used to invalidate the timer when the user wins or loses an attempt or the Reset or Pause button is pressed
-(void)stopTimer
{
    if(Timer.isValid)
    {
        [Timer invalidate];
    }
}

// Customization of buttons and slider
-(void)customizeObjects
{
    // Set customization of slider using the given image files
    [self.slider setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateNormal];
    [self.slider setThumbImage:[UIImage imageNamed:@"thumb.png"] forState:UIControlStateHighlighted];
    [self.slider setMaximumTrackImage:[[UIImage imageNamed:@"slider1.png" ] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 10)] forState:UIControlStateNormal];
    [self.slider setMinimumTrackImage:[[UIImage imageNamed:@"slider2.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)]forState:UIControlStateNormal];
    
    // Set customization of buttons
    [self.startButton addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.startButton addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.startButton.layer.cornerRadius = 18;
    self.startButton.clipsToBounds = YES;
    
    [self.resetButton addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.resetButton addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.resetButton.layer.cornerRadius = 18;
    self.resetButton.clipsToBounds = YES;
    
    [self.pauseButton addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.pauseButton addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    self.pauseButton.layer.cornerRadius = 18;
    self.pauseButton.clipsToBounds = YES;
}

// Method invoked when a button is pressed
- (void)buttonTouchDown:(UIButton *)button
{
    button.alpha = 0.3;
}

// Method invoked as soon as the button is released
- (void)buttonTouchUpInside:(UIButton *)button
{
    // Animation of the button being released
    [UIView beginAnimations:@"button" context:nil];
    [UIView setAnimationDuration:0.5];
    button.alpha = 1;
    [UIView commitAnimations];
}

// Method controlling the touch, changing the acceleration of the ball based
// on the location of the touch and providing an animated presentation of the touch
-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    
    // Allow touches only above the goals y coordinate and below the labels on top
    if (touchPoint.y > 50  && touchPoint.y < GOALS_Y)
    {
        CGPoint ballrectCenter = self.ballrect.center;
    
        if (touchPoint.x < ballrectCenter.x)
        {
            acceleration = ACCELERATION;
            [self.view addSubview:touchImgR];
            touchImgR.hidden = NO;
            touchImgR.center = [touch locationInView:self.view];
        }
        else if (touchPoint.x > ballrectCenter.x)
        {
            acceleration = -ACCELERATION;
            [self.view addSubview:touchImgL];
            touchImgL.hidden = NO;
            touchImgL.center = [touch locationInView:self.view];
        }
        energy++;
    }
}

// Method controlling the continuous touch, changing the acceleration of the ball based
// on the location of the touch and providing an animated presentation of the touch
-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    
    // Allow touches only above the goals y coordinate and below the labels on top
    if (touchPoint.y > 50  && touchPoint.y < GOALS_Y)
    {
        CGPoint ballrectCenter = self.ballrect.center;
    
        if (touchPoint.x < ballrectCenter.x)
        {
            acceleration = ACCELERATION;
            [self.view addSubview:touchImgR];
            touchImgR.hidden = NO;
            touchImgR.center = [touch locationInView:self.view];
        }
        else if (touchPoint.x > ballrectCenter.x)
        {
            acceleration = -ACCELERATION;
            [self.view addSubview:touchImgL];
            touchImgL.hidden = NO;
            touchImgL.center = [touch locationInView:self.view];
        }
        energy++;
    }
}

// When the touch has ended the touch image dissapears and acceleration
// and velocity are reseted to zero
-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    touchImgL.hidden = YES;
    touchImgR.hidden = YES;
    acceleration = 0;
    velocity = 0;
}

-(void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event {}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
