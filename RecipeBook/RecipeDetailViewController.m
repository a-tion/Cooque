//
//  RecipeDetailViewController.m
//  RecipeBook
//
//  Created by Simon Ng on 17/6/12.
//  Copyright (c) 2012 Appcoda. All rights reserved.
//

#import "RecipeDetailViewController.h"
#import <OpenEars/LanguageModelGenerator.h>


@interface RecipeDetailViewController ()

@end

@implementation RecipeDetailViewController


int counter = 0; // Counts which line of recipe it is currently on
@synthesize recipe;
@synthesize pocketsphinxController;
@synthesize openEarsEventsObserver;
@synthesize fliteController;
@synthesize slt;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.openEarsEventsObserver setDelegate:self];
    
    self.title = recipe.name;
    self.preptimeLabel.text = recipe.prepTime;
    self.recipePhoto.image = [UIImage imageNamed:recipe.imageFile];
    
    NSMutableString *ingredientText = [NSMutableString string];
    for (NSString* ingredient in recipe.ingredients) {
        [ingredientText appendFormat:@"%@\n", ingredient];
    }
    self.ingredientTextView.text = ingredientText;
    
    // Initialize the commands to be recognized
    LanguageModelGenerator *lmGenerator = [[LanguageModelGenerator alloc] init];
    NSArray *words = [NSArray arrayWithObjects:@"START", @"NEXT", @"PREVIOUS", @"REPEAT", @"OK COOK", @"STOP LISTENING", nil];
    NSString *name = @"Cooque";
    NSError *err = [lmGenerator generateLanguageModelFromArray:words withFilesNamed:name forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]]; // Set it to English mode
    NSDictionary *languageGeneratorResults = nil;
    NSString *lmPath = nil;
    NSString *dicPath = nil;
	if([err code] == noErr) {
        languageGeneratorResults = [err userInfo];
        lmPath = [languageGeneratorResults objectForKey:@"LMPath"];
        dicPath = [languageGeneratorResults objectForKey:@"DictionaryPath"];
    } else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }
    
    [self.pocketsphinxController startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
    
    [self.fliteController say:recipe.name withVoice:self.slt]; // It tells the user what the name of the recipe is


}

- (void)viewDidUnload
{
    [self setRecipePhoto:nil];
    [self setPreptimeLabel:nil];
    [self setIngredientTextView:nil];
    [self setStopButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (PocketsphinxController *)pocketsphinxController {
	if (pocketsphinxController == nil) {
		pocketsphinxController = [[PocketsphinxController alloc] init];
	}
	return pocketsphinxController;
}

- (OpenEarsEventsObserver *)openEarsEventsObserver {
	if (openEarsEventsObserver == nil) {
		openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
	}
	return openEarsEventsObserver;
}

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    
	NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID); // Check the accuracy level
    
    if([hypothesis isEqualToString:@"OK COOK"]) { // The app tells the user it is listening (kind of imitates Google's "OK GOOGLE")
        
       [self.fliteController say:@"Listening" withVoice:self.slt];
        
    } else if([hypothesis isEqualToString:@"STOP LISTENING"]) { // The app stops listening
        
        [self.pocketsphinxController stopListening];
        
    } else if([hypothesis isEqualToString:@"START"]) { // The app starts to read the first line of the recipe
        
        [self.fliteController say:recipe.ingredients[0] withVoice:self.slt];
        counter++;
        
    } else if([hypothesis isEqualToString:@"NEXT"]) { // The app reads the next line of recipe
        
        if(counter < recipe.length - 1) {
            
            counter++;
            [self.fliteController say:recipe.ingredients[counter] withVoice:self.slt];
            
        } else {
            
            [self.fliteController say:@"Reach the end" withVoice:self.slt];
            
        }
        
    } else if([hypothesis isEqualToString:@"PREVIOUS"]) { // The app goes back and reads the previous line of recipe
        
        if(counter > 0) {
            
            counter--;
            [self.fliteController say:recipe.ingredients[counter] withVoice:self.slt];
            
        } else {
            
            [self.fliteController say:@"Reach the beginning" withVoice:self.slt];
            
        }
        
    } else if([hypothesis isEqualToString:@"REPEAT"]) { // The app repeats the same line of recipe
        
        [self.fliteController say:recipe.ingredients[counter] withVoice:self.slt];
        
    }
}

- (void) pocketsphinxDidStartCalibration {
	NSLog(@"Pocketsphinx calibration has started.");
}

- (void) pocketsphinxDidCompleteCalibration {
	NSLog(@"Pocketsphinx calibration is complete.");
}

- (void) pocketsphinxDidStartListening {
	NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
	NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
	NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
	NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
	NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
	NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
	NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFail {
	NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on OpenEarsLogging to learn more.");
}
- (void) testRecognitionCompleted {
	NSLog(@"A test file that was submitted for recognition is now complete.");
}

- (FliteController *)fliteController {
	if (fliteController == nil) {
		fliteController = [[FliteController alloc] init];
	}
	return fliteController;
}

- (Slt *)slt {
	if (slt == nil) {
		slt = [[Slt alloc] init];
	}
	return slt;
}

- (IBAction)stopListeningAction:(id)sender {
    [self.pocketsphinxController stopListening];
}

@end
