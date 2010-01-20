//
//  WDLWebImageLoader.m
//  Geotag
//
//  Created by William Lindmeier on 4/28/09.
//  Copyright 2009. All rights reserved.
//

#import "WDLWebImageLoader.h"

@implementation WDLWebImageLoader

@synthesize delegate, urlString;

-(void)loadImageFromURL:(NSString *)imageURLString{
	if(isLoading)
	{
		@throw [NSException exceptionWithName:@"Load Request Ignored" 
									   reason:@"Could Not Start Load While Load In Progress" 
									 userInfo:nil];
	}
	
	isLoading = YES;
	
	[urlString release];
	urlString = [imageURLString copy];
	
	[NSThread detachNewThreadSelector:@selector(performAsyncLoadWithURL:) 
							 toTarget:self 
						   withObject:[NSURL URLWithString:urlString]];	
}

- (void) performAsyncLoadWithURL:(NSURL*)url
{
	NSAutoreleasePool * pool =[[NSAutoreleasePool alloc] init];
	
	NSError* loadError = nil;
	NSData* imageData = [NSData dataWithContentsOfURL:url options:NSMappedRead error:&loadError];
	
	if(imageData)
	{
		[self performSelectorOnMainThread:@selector(loadDidFinishWithData:)
							   withObject:imageData 
							waitUntilDone:YES];
	}
	else
	{
		[self performSelectorOnMainThread:@selector(loadDidFinishWithError:)
							   withObject:loadError 
							waitUntilDone:YES];
	}
	
	[pool release]; // imageData will be released here
}


- (void)loadDidFinishWithData:(NSData*)imageData
{	
	isLoading = NO;
	UIImage *image = [[[UIImage alloc] initWithData:imageData] autorelease];	
	if(self.delegate) [self.delegate webImageLoader:self didLoadImage:image];
}

- (void)loadDidFinishWithError:(NSError*)error
{
	isLoading = NO;
	NSString *errorString = [NSString stringWithFormat:@"\nAPSWebImageView: Failed Image Load\n		[%@]\n		With Error - %@", 
									  urlString, [error localizedDescription]];
	if(self.delegate) [self.delegate webImageLoader:self failedToLoadWithError:errorString];
}

- (void)dealloc 
{
	[urlString release];
	[super dealloc];
}

@end