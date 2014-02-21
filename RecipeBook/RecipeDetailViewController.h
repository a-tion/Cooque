//
//  RecipeDetailViewController.h
//  RecipeBook
//
//  Created by Simon Ng on 17/6/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recipe.h"
#import <OpenEars/PocketsphinxController.h>
#import <OpenEars/AcousticModel.h>
#import <OpenEars/OpenEarsEventsObserver.h>
#import <Slt/Slt.h>
#import <OpenEars/FliteController.h>


@interface RecipeDetailViewController : UIViewController <OpenEarsEventsObserverDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *recipePhoto;
@property (strong, nonatomic) IBOutlet UILabel *preptimeLabel;
@property (strong, nonatomic) IBOutlet UITextView *ingredientTextView;
@property (nonatomic, strong) Recipe *recipe;
@property (strong, nonatomic) PocketsphinxController *pocketsphinxController;
@property (strong, nonatomic) OpenEarsEventsObserver *openEarsEventsObserver;
@property (strong, nonatomic) FliteController *fliteController;
@property (strong, nonatomic) Slt *slt;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *stopButton;

@end
