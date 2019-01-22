

#import "PDFDocumentScrollView.h"

//#import "PDFDisplayViewController.h"
//#import "GlobalDocumentTracker.h"



#define SPECIAL_DELETE_ANNOTATION_BUTTON_TAG 100

@interface SpecialDeleteAnnotationButton : UIButton {
    
    id userInfo;
}
@property (retain) id userInfo;

-(id) init;
-(id) initWithFrame:(CGRect)frame;

@end


@implementation SpecialDeleteAnnotationButton

@synthesize userInfo;


-(id) init {
    self = [super init];
    if (self) { [self commonInit]; }
    return self;
}

-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) { [self commonInit]; }
    return self;
}



-(void) commonInit {
    self.userInfo = nil;
//    self.backgroundColor = [UIColor redColor];
//    [self setTitle:@"delete" forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"delete_active.png"] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:@"delete_inactive.png"] forState:UIControlStateHighlighted];
//    [self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    self.tag = SPECIAL_DELETE_ANNOTATION_BUTTON_TAG;
}




-(void) dealloc {
    self.userInfo = nil;
    [super dealloc];
}

@end














#define SPACE_BETWEEN_PAGES				30.0
#define PAGES_TO_UPDATE_AROUND			2

extern int sysctlbyname(const char *name, void *oldp, size_t *oldlenp, void *newp, size_t newlen);

static CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}



@implementation PDFPageView

@synthesize pageNumber, parentDocument, allowViewUpdate;

-(id) initWithPosition:(CGPoint) position andPage:(CGPDFPageRef) PDFPage {
	
	self = [super initWithFrame:CGRectMake(position.x, position.y, 0.0, 0.0)];
	if (self!=nil) {
        
        
		willDeallocate = NO;
		allowViewUpdate = NO;
        deviceModel = [[self IphoneModel] retain];
        
//        NSLog(@" deviceModel = %@", deviceModel);
		
        CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
        
        // choose the right tile size
        CGSize rightTileSize = CGSizeMake(768.0, 768.0);
		int rightBias = 4;
        int rightLevelsOfDetail = 20;
        
        if ([deviceModel isEqualToString:@"iPhone 1G"] || [deviceModel isEqualToString:@"iPod Touch 1G"] ) { 
            rightTileSize = CGSizeMake(512.0, 512.0); 
			rightBias = 3;
		}
		
        if ([deviceModel isEqualToString:@"iPhone 3G"] || [deviceModel isEqualToString:@"iPod Touch 2G"] ) {
            rightTileSize = CGSizeMake(768.0, 768.0); 
			rightBias = 5;
		}

        //fucking added+++++++++++++++++++++++++++++++++++++++++++++++
        if ([deviceModel isEqualToString:@"iPhone 3GS"] || [deviceModel isEqualToString:@"iPod Touch 3G"] || [deviceModel isEqualToString:@"iPhone 4"] || [deviceModel isEqualToString:@"iPhone 4s"] ) {
            rightTileSize = CGSizeMake(768.0, 768.0);
			rightBias = 6;
		}   
        
        
        
        if ([deviceModel isEqualToString:@"iPad"] ) {
//            NSLog(@" deviceModel = iPad");
            rightTileSize = CGSizeMake(768.0, 768.0);
			rightBias = 6;            
        }
        
        
        if ([deviceModel isEqualToString:@"iPad 2"] ) {
//            NSLog(@" deviceModel = iPad 2");
            rightTileSize = CGSizeMake(768.0, 768.0);
			rightBias = 3;
        }
        
        
        if ([deviceModel isEqualToString:@"iPad 3"] ) { 
//            NSLog(@" device is iPad 3");
            rightTileSize = CGSizeMake(CGPDFPageGetBoxRect(PDFPage, kCGPDFMediaBox).size.width, CGPDFPageGetBoxRect(PDFPage, kCGPDFMediaBox).size.height); //CGSizeMake(768.0, 768.0);
			rightBias = 0;      
            rightLevelsOfDetail = 20;
            
		}
        
        
        //fucking added+++++++++++++++++++++++++++++++++++++++++++++++
        if ([deviceModel isEqualToString:@"iPhone 5"] || [deviceModel isEqualToString:@"iPod Touch 5"] ) {
//            NSLog(@" device is iPhone 5");
            rightTileSize = CGSizeMake(1024.0, 1024.0); //CGSizeMake(768.0, 768.0);
			rightBias = 6;
            rightLevelsOfDetail = 10;
		}
        
        
        
        if ([deviceModel isEqualToString:@"iPod Touch 4G"]) {
            rightTileSize = CGSizeMake(768.0, 768.0); //CGSizeMake(768.0, 768.0);
			rightBias = 1;
            rightLevelsOfDetail = 20;
        }
        
        
        if ([deviceModel isEqualToString:@"x86_64"] || [deviceModel isEqualToString:@"Simulator"]) {
//            rightTileSize = CGSizeMake(768.0, 768.0);
            rightTileSize = CGSizeMake(CGPDFPageGetBoxRect(PDFPage, kCGPDFMediaBox).size.width, CGPDFPageGetBoxRect(PDFPage, kCGPDFMediaBox).size.height);
			rightBias = 4;      
            rightLevelsOfDetail = 20;
//            NSLog(@" Simulator detected ");             
		}

        
    
		tiledLayer.levelsOfDetailBias = rightBias;
		tiledLayer.tileSize = rightTileSize; //CGSizeMake(320.0, 480.0);
        tiledLayer.levelsOfDetail = rightLevelsOfDetail;
        
        tiledLayer.geometryFlipped = NO;
        
        /*
//        tiledLayer.levelsOfDetail = 10;
//        tiledLayer.levelsOfDetailBias = 2;
//        tiledLayer.tileSize = CGSizeMake(10000.0, 10000.0);  // CGSizeMake(CGPDFPageGetBoxRect(PDFPage, kCGPDFMediaBox).size.width, CGPDFPageGetBoxRect(PDFPage, kCGPDFMediaBox).size.height); //CGSizeMake(CGPDFPageGetBoxRect(PDFPage, kCGPDFMediaBox).size.width, 300.0); //rightTileSize; //CGSizeMake(320.0, 480.0);
*/
		 
        if (PDFPage!=NULL) { 
			pdfPage = CGPDFPageRetain(PDFPage); 
            CGRect selfFrame = self.frame;
            selfFrame.size = CGSizeMake(CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox).size.width, CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox).size.height);
            self.frame = selfFrame;
		} else {
			pdfPage = NULL; 
			CGRect selfFrame = self.frame;
			selfFrame.size = CGSizeMake(0.0, 0.0);
			self.frame = selfFrame;
        }
	}
	self.allowViewUpdate = YES;
    
    
    
    //ANNOTATIONS
    //==============================================================================================
    //text
    textAnnotations = [[NSMutableArray alloc] init];
    annotationCornerImage = [[UIImage imageNamed:@"annotation_delete_corner_image.png"] retain];
    
    //draw
    drawAnnotations = [[NSMutableArray alloc] init];
    
    //==============================================================================================
    
//    [self temp_addBezierPoints];
    
    
	return self;	
}







//-(void) temp_addBezierPoints {
//    
//    if (bezierPath==nil) {
//        bezierPath = [[UIBezierPath bezierPath] retain];
//        [bezierPath setLineCapStyle:kCGLineCapRound];
//        [bezierPath setLineWidth:4];
//    }
//    
//    
//    secondPoint = CGPointMake(50, 50);
//    firstPoint = CGPointMake(100, 50);
//    currentPoint = CGPointMake(100, 100);
//    
//    //points in the middle of the line segments
//    CGPoint mid1 = midPoint(firstPoint, secondPoint);
//    CGPoint mid2 = midPoint(currentPoint, firstPoint);
//
//    [bezierPath moveToPoint:mid1];
//    [bezierPath addQuadCurveToPoint:mid2 controlPoint:firstPoint];
//    
//    [self setNeedsDisplay];
//}










#pragma mark Annotations
//===================================================================================DRAW ANNOTATIONS

#pragma mark Draw annots

-(void) addDrawAnnotationDict:(NSDictionary*) drawAnnotDict {
    
    if (drawAnnotations!=nil) {
        [drawAnnotations addObject:drawAnnotDict];
        [self.layer setNeedsDisplay];
    }
}

-(void) removeDrawAnnotationSpecificDict:(NSDictionary*) dictToRemove {
    
    NSUInteger indexOfDict = [drawAnnotations indexOfObject:dictToRemove];
    if (indexOfDict<[drawAnnotations count]) {
        restrictArrayEnumeration = YES;
        [drawAnnotations removeObjectAtIndex:indexOfDict];
        restrictArrayEnumeration= NO;
        [self.layer setNeedsDisplay];
    }
}







//===================================================================================TEXT ANNOTATIONS
#pragma mark Text annots

//runtime in-memory store
-(void) addTextAnnotationsFromArray:(NSArray *) array {
    
    if (textAnnotations!=nil) {
        [textAnnotations addObjectsFromArray:array];
        [self.layer setNeedsDisplay];
    }
}

-(void) addTextAnnotationDictionary:(NSDictionary*) dict {
    
//    NSLog(@" addTextAnnotationDictionary ");
    
    if (textAnnotations!=nil) {
        [textAnnotations addObject:dict];
        [self.layer setNeedsDisplay];
    }
}

-(void) replaceTextAnnotationsWithArray:(NSArray *) array {
    if (textAnnotations!=nil) {
        [textAnnotations removeAllObjects];
        [self addTextAnnotationsFromArray:array];
        [self.layer setNeedsDisplay];
    } else {
        textAnnotations = [[NSMutableArray alloc] init];
        [self addTextAnnotationsFromArray:array];
    }
}

-(void) removeTextAnnotationSpecificDict:(NSDictionary*) dictToRemove {
    
    NSUInteger indexOfDict = [textAnnotations indexOfObject:dictToRemove];
    
    if (indexOfDict<[textAnnotations count]) {
        restrictArrayEnumeration = YES;
        [textAnnotations removeObjectAtIndex:indexOfDict];
        restrictArrayEnumeration = NO;
        [self.layer setNeedsDisplay];
    }
}

-(void) removeAllTextAnnotations {
    if (textAnnotations!=nil) {
        [textAnnotations removeAllObjects];
        [self.layer setNeedsDisplay];
    } else {
        textAnnotations = [[NSMutableArray alloc] init];
    }
}
//===================================================================================
















-(void) didMoveToSuperview {
    [super didMoveToSuperview];
//    NSLog(@" PDFPageView text annotations = %@",textAnnotations);
}







-(void) removeFromSuperview {
    NSLog(@"pdfpage remove from superview");
	@synchronized(self) {
		willDeallocate = YES;
		parentDocument = nil;
		if (pdfPage!=NULL) { CGPDFPageRelease(pdfPage); pdfPage=NULL; }
		[deviceModel release];
	}
	[super removeFromSuperview];
}




-(void) setCGPDFPage:(CGPDFPageRef)CGPDFPage {
    if (pdfPage!=NULL) { CGPDFPageRelease(pdfPage); }
    pdfPage = CGPDFPageRetain(CGPDFPage);
}


-(CGPDFPageRef) getCGPDFPage {
    return pdfPage;
}




+(Class)layerClass {
	return [CATiledLayer class];
}












#pragma mark Drawing









-(void) drawLayer:(CALayer *) layer inContext:(CGContextRef)context {

    
    [super drawLayer:layer inContext:context];
//    CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
//    NSLog(@" TILE SIZE = %@, BIAS = %zu, LEVELS = %zu", NSStringFromCGSize(tiledLayer.tileSize), tiledLayer.levelsOfDetailBias, tiledLayer.levelsOfDetail);
    

	if (pdfPage==NULL || willDeallocate==YES || allowViewUpdate==NO) { NSLog(@" return from drawLayer, willDeallocate = %d, pdfPage=%@", willDeallocate, pdfPage);  return; }
//    NSLog(@" context address = %d, layer = %d", &context, &layer );

    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // First fill the background with white.
	CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0); // CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.0); //	CGContextSetRGBFillColor(context, 0.0,0.6,0.4,1.0);
    CGContextFillRect(context,self.bounds);
	
	CGContextSaveGState(context);
	
	// Flip the context so that the PDF page is rendered
	// right side up.
    

    
    CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);


	// will draw content only if told so, othewise will draw nothing to save resourses.
//	if ([self isThisPageInUpdateRange]==YES) { CGContextDrawPDFPage(context, pdfPage); } else { } fuck this
    
    @synchronized(self) {
        CGContextDrawPDFPage(context, pdfPage);
    }
    
    
    CGContextRestoreGState(context);
    
    
 
    
    
    
    PDFDocumentScrollView *parentDoc = (PDFDocumentScrollView*)self.parentDocument;
    
    if (parentDoc!=nil && parentDoc.shouldDrawRuntimeAnnotations) {
        if (restrictArrayEnumeration==NO) {
            //text annots.
            
            for (NSDictionary *currentTextAnnotation in textAnnotations) {
                
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                
                UIGraphicsPushContext(context);
                CGContextSaveGState(context);
                
                NSString *text = [currentTextAnnotation objectForKey:TEXT_ANNOTATION_TEXT_STRING_KEY];
                //        CGRect scrollTextFrame = CGRectFromString([currentTextAnnotation objectForKey:TEXT_ANNOTATION_SCROLLVIEW_TEXT_FRAME_STRING_KEY]);
                NSInteger thePageNumber = [[currentTextAnnotation objectForKey:TEXT_ANNOTATION_PAGE_NUMBER_KEY] integerValue];
                CGRect pdfPageTextFrame = CGRectFromString([currentTextAnnotation objectForKey:TEXT_ANNOTATION_CGPDFPAGE_TEXT_FRAME_STRING_KEY]);
                NSString *fontName = [currentTextAnnotation objectForKey:TEXT_ANNOTATION_FONTNAME_STRING_KEY];
                
                CGFloat red = [[[currentTextAnnotation objectForKey:TEXT_ANNOTATION_COLOR_RGB_DICT_KEY] objectForKey:COLOR_RED_VALUE_KEY] floatValue];
                CGFloat green = [[[currentTextAnnotation objectForKey:TEXT_ANNOTATION_COLOR_RGB_DICT_KEY] objectForKey:COLOR_GREEN_VALUE_KEY] floatValue];
                CGFloat blue = [[[currentTextAnnotation objectForKey:TEXT_ANNOTATION_COLOR_RGB_DICT_KEY] objectForKey:COLOR_BLUE_VALUE_KEY] floatValue];
                CGFloat alpha = [[[currentTextAnnotation objectForKey:TEXT_ANNOTATION_COLOR_RGB_DICT_KEY] objectForKey:COLOR_ALPHA_VALUE_KEY] floatValue];
                //        UIColor *textColor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
                CGFloat pointSize = [[currentTextAnnotation objectForKey:TEXT_ANNOTATION_POINTSIZE_NUMBER_KEY] floatValue];
                
                
                if (self.pageNumber!=thePageNumber) { //redundant check, but still...
                    NSLog(@" Warning, this annotation is not for this page! check it");
                    continue;
                }
                
                
                UIFont *textFont = [UIFont fontWithName:fontName size:pointSize];
                CGSize sizeDrawn;
                
                CGContextSetRGBFillColor(context, red, green, blue, alpha);
                
                sizeDrawn = [text drawInRect:pdfPageTextFrame withFont:textFont lineBreakMode:NSLineBreakByWordWrapping];
                
                
                
                BOOL removeMode = [(PDFDocumentScrollView* )parentDocument textAnnotationsRemoveMode];
                
                if (removeMode==YES) {
                    
                    CGFloat cornerWidth = 5.0;
                    
                    //lines
                    const CGFloat *comps = CGColorGetComponents([UIColor redColor].CGColor);
                    CGContextSetRGBStrokeColor(context, comps[0], comps[1], comps[2], comps[3]);
                    const CGFloat components[4] = {0,0,0, 0.6};
                    CGColorRef shadowColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), components);
                    CGContextSetShadowWithColor(context, CGSizeMake(0, 0.5), 1, shadowColor);
                    
                    CGContextStrokeRectWithWidth(context, CGRectMake(pdfPageTextFrame.origin.x, pdfPageTextFrame.origin.y, sizeDrawn.width, sizeDrawn.height), 1);
                    
                    
                    //corners
                    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
                    CGFloat colors[] =
                    {
                        1, 1, 1, 1,
                        1.0, 0.0, 0.0, 1
                    };
                    const CGFloat locations[] = { 0, 0.38 }; //will gradient till the middle of the cirle, then just red
                    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors, locations, sizeof(colors)/(sizeof(colors[0])*sizeof(CGFloat)));
                    
                    //up left
                    CGContextSaveGState(context);
                    CGContextAddArc(context, pdfPageTextFrame.origin.x, pdfPageTextFrame.origin.y,  cornerWidth/2.0, 0, M_PI*2, 1);
                    CGContextClip(context);
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(pdfPageTextFrame.origin.x, pdfPageTextFrame.origin.y-cornerWidth/2.0), CGPointMake(pdfPageTextFrame.origin.x, pdfPageTextFrame.origin.y+cornerWidth), kCGGradientDrawsAfterEndLocation);
                    CGContextRestoreGState(context);
                    
                    //up right
                    CGContextSaveGState(context);
                    CGContextAddArc(context, pdfPageTextFrame.origin.x+sizeDrawn.width, pdfPageTextFrame.origin.y,  cornerWidth/2.0, 0, M_PI*2, 1);
                    CGContextClip(context);
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(pdfPageTextFrame.origin.x+sizeDrawn.width, pdfPageTextFrame.origin.y-cornerWidth/2.0), CGPointMake(pdfPageTextFrame.origin.x+sizeDrawn.width, pdfPageTextFrame.origin.y+cornerWidth), kCGGradientDrawsAfterEndLocation);
                    CGContextRestoreGState(context);
                    
                    //down left
                    CGContextSaveGState(context);
                    CGContextAddArc(context, pdfPageTextFrame.origin.x, pdfPageTextFrame.origin.y+sizeDrawn.height,  cornerWidth/2.0, 0, M_PI*2, 1);
                    CGContextClip(context);
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(pdfPageTextFrame.origin.x, pdfPageTextFrame.origin.y+sizeDrawn.height-cornerWidth/2.0), CGPointMake(pdfPageTextFrame.origin.x, pdfPageTextFrame.origin.y+sizeDrawn.height+cornerWidth), kCGGradientDrawsAfterEndLocation);
                    CGContextRestoreGState(context);
                    
                    //down right
                    CGContextSaveGState(context);
                    CGContextAddArc(context, pdfPageTextFrame.origin.x+sizeDrawn.width, pdfPageTextFrame.origin.y+sizeDrawn.height,  cornerWidth/2.0, 0, M_PI*2, 1);
                    CGContextClip(context);
                    CGContextDrawLinearGradient(context, gradient, CGPointMake(pdfPageTextFrame.origin.x+sizeDrawn.width, pdfPageTextFrame.origin.y+sizeDrawn.height-cornerWidth/2.0), CGPointMake(pdfPageTextFrame.origin.x+sizeDrawn.width, pdfPageTextFrame.origin.y+sizeDrawn.height+cornerWidth), kCGGradientDrawsAfterEndLocation);
                    CGContextRestoreGState(context);
                    
                    
                    
                    CGGradientRelease(gradient);
                    CGColorSpaceRelease(rgb);
                    
                    
                    if ([self isDeleteSpecialButtonAlreadyAddedOnViewForAnnotationDictionary:currentTextAnnotation]==NO) {
                        SpecialDeleteAnnotationButton *deleteButton = [[SpecialDeleteAnnotationButton alloc] initWithFrame:CGRectMake(pdfPageTextFrame.origin.x-31.0, pdfPageTextFrame.origin.y-31.0, 35, 35)];
                        //                    deleteButton.center = CGPointMake(pdfPageTextFrame.origin.x, pdfPageTextFrame.origin.y);
                        
                        if (deleteButton.frame.origin.x<=0) { deleteButton.frame = CGRectMake(3, deleteButton.frame.origin.y, deleteButton.frame.size.width, deleteButton.frame.size.height); }
                        if (deleteButton.frame.origin.y<=0) { deleteButton.frame = CGRectMake(deleteButton.frame.origin.y, 3.0, deleteButton.frame.size.width, deleteButton.frame.size.height); }
                        
                        deleteButton.exclusiveTouch = YES;
                        deleteButton.userInfo = currentTextAnnotation;
                        [deleteButton addTarget:self action:@selector(deleteTextAnnotationAction:) forControlEvents:UIControlEventTouchUpInside];
                        [self addSubview:[deleteButton autorelease] ];
                    }
                }
                
                CGContextRestoreGState(context);
                UIGraphicsPopContext();
    
                [pool drain];
            }
           
            
            
            @synchronized(self) {    //saves from disaster
            
                CGContextSaveGState(context);
                
                CGContextSetLineCap(context, kCGLineCapRound);
                CGContextSetLineJoin(context, kCGLineJoinRound);
                
                CGContextSetShouldAntialias(context, true);
                CGContextSetAllowsAntialiasing(context, true);
                
        
//                kCGBlendModeMultiply, ++++
//                kCGBlendModeDarken, +++++++
//                kCGBlendModeColorDodge, +
//                kCGBlendModePlusDarker, ++++
                
//                NSLog(@" scaleFactor=%f", scaleFactor);
//                NSLog(@" self.frame = %@", NSStringFromCGRect(self.frame) );
                
                for (NSDictionary *currentDrawAnnotation in drawAnnotations) {
                   
                    
                    NSArray *curves = [currentDrawAnnotation objectForKey:DRAW_ANNOTATION_CURVES_ARRAY_KEY];
                    NSInteger pageNum = [[currentDrawAnnotation objectForKey:DRAW_ANNOTATION_PAGE_NUMBER_KEY] unsignedIntValue];
                    NSString *drawMode = [currentDrawAnnotation objectForKey:DRAW_ANNOTATIONS_DRAW_MODE];
                    
                    CGContextSetBlendMode(context, kCGBlendModeNormal);
                    if ([drawMode isEqualToString:DRAW_MODE_MARK_DRAWING])  { CGContextSetBlendMode(context, kCGBlendModeDarken); }
                    
                    if (pageNum!=self.pageNumber) {
                        NSLog(@" drawLayer inRect CHECK FOR ERRORS - wrong page number for annotation, this must not be.");
                        continue;
                    }
                    
                    
                    
                    //remove mode
                    CGMutablePathRef removePath = NULL;
                    CGFloat linesWidth = 0;
                    if (parentDoc.drawAnnotationsRemoveMode) {
                        removePath = CGPathCreateMutable();
                    }
                    //============
                    
                    
                    for (NSDictionary *currentCurveDict in curves) {
                        CGFloat lWidth = linesWidth = [[currentCurveDict objectForKey:CURVE_DESCRIPTION_WIDTH_VALUE] floatValue];
                        const CGFloat components[4] = {[[[currentCurveDict objectForKey:CURVE_DESCRIPTION_COLOR_RGB_DICT] objectForKey:COLOR_RED_VALUE_KEY] floatValue],
                            [[[currentCurveDict objectForKey:CURVE_DESCRIPTION_COLOR_RGB_DICT] objectForKey:COLOR_GREEN_VALUE_KEY] floatValue],
                            [[[currentCurveDict objectForKey:CURVE_DESCRIPTION_COLOR_RGB_DICT] objectForKey:COLOR_BLUE_VALUE_KEY] floatValue],
                            [[[currentCurveDict objectForKey:CURVE_DESCRIPTION_COLOR_RGB_DICT] objectForKey:COLOR_ALPHA_VALUE_KEY] floatValue]};
                        CGColorRef lineColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), components);
                        
                        
                        NSMutableArray *curvePointsArray = [currentCurveDict objectForKey:CURVE_DESCRIPTION_POINTS_ARRAY];
                        NSDictionary *firstPointInCurve = [curvePointsArray objectAtIndex:0];
                        CGPointMakeWithDictionaryRepresentation( (CFDictionaryRef)firstPointInCurve , &firstPoint);
                        
                        secondPoint = currentPoint = firstPoint;
                        
                        
                        //setting params for cur. curve
                        CGContextSetLineWidth(context, lWidth);
                        CGContextSetStrokeColorWithColor(context, lineColor);
                        CGContextSetFillColorWithColor(context, lineColor);
                        
                        //first point
                        CGContextMoveToPoint(context, currentPoint.x, currentPoint.y);
                        if ([drawMode isEqualToString:DRAW_MODE_SOLID_DRAWING]) { CGContextAddLineToPoint(context, currentPoint.x, currentPoint.y); }
                        CGContextStrokePath(context);
                        
                        
                        //remove mode
                        if (parentDoc.drawAnnotationsRemoveMode) {
                            CGPathMoveToPoint(removePath, NULL, currentPoint.x, currentPoint.y);
                        }
                        

                        
                        for (NSDictionary *pointDict in curvePointsArray) {
                            CGPoint point;
                            
                            CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)pointDict, &point);
                            
                            secondPoint = firstPoint;
                            firstPoint = currentPoint;
                            currentPoint = point;
                            
                            CGPoint mid1 = midPoint(firstPoint, secondPoint);
                            CGPoint mid2 = midPoint(currentPoint, firstPoint);
                            
                            CGContextMoveToPoint(context, mid1.x, mid1.y);
                            CGContextAddQuadCurveToPoint(context, firstPoint.x, firstPoint.y, mid2.x, mid2.y);
                            
                            
                            //remove mode
                            if (parentDoc.drawAnnotationsRemoveMode) {
                            CGPathAddLineToPoint(removePath, NULL, currentPoint.x, currentPoint.y);
                            }
                            
                        }
                        CGContextStrokePath(context);
                    
                    } //curves
                    
                    
                    
                    if (parentDoc.drawAnnotationsRemoveMode) {
                        //remove mode
                        CGContextSaveGState(context);
                        
                        CGContextSetShouldAntialias(context, true);
                        CGContextSetAllowsAntialiasing(context, true);
                        CGContextSetBlendMode(context, kCGBlendModeNormal);
                        CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
                        CGRect pathBox = CGPathGetPathBoundingBox(removePath);
                        pathBox.size.width = pathBox.size.width+linesWidth;
                        pathBox.size.height = pathBox.size.height+linesWidth;
                        pathBox.origin.x = pathBox.origin.x-linesWidth/2.0;
                        pathBox.origin.y = pathBox.origin.y-linesWidth/2.0;
                        
                        //adjust to fit the page if beyond...
                        if (pathBox.origin.x<=0) { pathBox.origin.x = 3.0; }
                        if (pathBox.origin.x+pathBox.size.width>=self.frame.size.width) { pathBox.size.width = pathBox.size.width-fabsf(self.frame.size.width-(pathBox.origin.x+pathBox.size.width) )-3.0;  }
                        if (pathBox.origin.y<=0) { pathBox.origin.y = 3.0; }
                        if (pathBox.origin.y+pathBox.size.height>=self.frame.size.height) { pathBox.size.height = pathBox.size.height-fabsf(self.frame.size.height-(pathBox.origin.y+pathBox.size.height))-3.0;  }
                        
                        
                        

                        const CGFloat components[4] = {0,0,0, 0.6};
                        CGColorRef shadowColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), components);
                        CGContextSetShadowWithColor(context, CGSizeMake(0, 0.5), 1, shadowColor);
                        CGContextStrokeRectWithWidth(context, pathBox, 1);
                        
                        
                        CGFloat cornerWidth = 5.0;
                        //corners
                        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
                        CGFloat colors[] =
                        {
                            1, 1, 1, 1,
                            1.0, 0.0, 0.0, 1
                        };
                        const CGFloat locations[] = { 0, 0.38 }; //will gradient till the middle of the cirle, then just red
                        CGGradientRef gradient = CGGradientCreateWithColorComponents(rgb, colors, locations, sizeof(colors)/(sizeof(colors[0])*sizeof(CGFloat)));
                        
                        
                        //up left
                        CGContextSaveGState(context);
                        CGContextAddArc(context, pathBox.origin.x, pathBox.origin.y,  cornerWidth/2.0, 0, M_PI*2, 1);
                        CGContextClip(context);
                        CGContextDrawLinearGradient(context, gradient, CGPointMake(pathBox.origin.x, pathBox.origin.y-cornerWidth/2.0), CGPointMake(pathBox.origin.x, pathBox.origin.y+cornerWidth), kCGGradientDrawsAfterEndLocation);
                        CGContextRestoreGState(context);
                        
                        //up right
                        CGContextSaveGState(context);
                        CGContextAddArc(context, pathBox.origin.x+pathBox.size.width, pathBox.origin.y,  cornerWidth/2.0, 0, M_PI*2, 1);
                        CGContextClip(context);
                        CGContextDrawLinearGradient(context, gradient, CGPointMake(pathBox.origin.x+pathBox.size.width, pathBox.origin.y-cornerWidth/2.0), CGPointMake(pathBox.origin.x+pathBox.size.width, pathBox.origin.y+cornerWidth), kCGGradientDrawsAfterEndLocation);
                        CGContextRestoreGState(context);
                        
                        //down left
                        CGContextSaveGState(context);
                        CGContextAddArc(context, pathBox.origin.x, pathBox.origin.y+pathBox.size.height,  cornerWidth/2.0, 0, M_PI*2, 1);
                        CGContextClip(context);
                        CGContextDrawLinearGradient(context, gradient, CGPointMake(pathBox.origin.x, pathBox.origin.y+pathBox.size.height-cornerWidth/2.0), CGPointMake(pathBox.origin.x, pathBox.origin.y+pathBox.size.height+cornerWidth), kCGGradientDrawsAfterEndLocation);
                        CGContextRestoreGState(context);
                        
                        //down right
                        CGContextSaveGState(context);
                        CGContextAddArc(context, pathBox.origin.x+pathBox.size.width, pathBox.origin.y+pathBox.size.height,  cornerWidth/2.0, 0, M_PI*2, 1);
                        CGContextClip(context);
                        CGContextDrawLinearGradient(context, gradient, CGPointMake(pathBox.origin.x+pathBox.size.width, pathBox.origin.y+pathBox.size.height-cornerWidth/2.0), CGPointMake(pathBox.origin.x+pathBox.size.width, pathBox.origin.y+pathBox.size.height+cornerWidth), kCGGradientDrawsAfterEndLocation);
                        CGContextRestoreGState(context);
                        
                        
                        
                        
                        if ([self isDeleteSpecialButtonAlreadyAddedOnViewForAnnotationDictionary:currentDrawAnnotation]==NO) {
                            SpecialDeleteAnnotationButton *deleteButton = [[SpecialDeleteAnnotationButton alloc] initWithFrame:CGRectMake(pathBox.origin.x-31.0, pathBox.origin.y-31.0, 35, 35)];
                            //                    deleteButton.center = CGPointMake(pdfPageTextFrame.origin.x, pdfPageTextFrame.origin.y);
                            
                            if (deleteButton.frame.origin.x<=0) { deleteButton.frame = CGRectMake(3, deleteButton.frame.origin.y, deleteButton.frame.size.width, deleteButton.frame.size.height); }
                            if (deleteButton.frame.origin.y<=0) { deleteButton.frame = CGRectMake(deleteButton.frame.origin.y, 3.0, deleteButton.frame.size.width, deleteButton.frame.size.height); }
                            
                            deleteButton.exclusiveTouch = YES;
                            deleteButton.userInfo = currentDrawAnnotation;
                            [deleteButton addTarget:self action:@selector(deleteDrawAnnotationsAction:) forControlEvents:UIControlEventTouchUpInside];
                            [self addSubview:[deleteButton autorelease] ];
                        }
                        
                        
                        
                        
                        
                        CGContextRestoreGState(context);
                        
                    }
                    
                    if (removePath!=NULL) { CGPathRelease(removePath); removePath=NULL; }
                    
                } //end draw annots.
                CGContextRestoreGState(context);
            } //synchr.
        
            
            
        }//restrictArrayEnumeration
    }//shouldDrawRuntimeAnnotations

    
    [pool drain];
}





-(void) deleteDrawAnnotationsAction:(id) sender {
    SpecialDeleteAnnotationButton *currentSpecialButton = (SpecialDeleteAnnotationButton*)sender;
    NSDictionary *annotationDictToRemove = [[NSDictionary alloc] initWithDictionary: (NSDictionary *) currentSpecialButton.userInfo ];
//    NSLog(@" currentDrawAnnotation=%@", annotationDictToRemove);
    [self removeDrawAnnotationSpecificDict:annotationDictToRemove];
    [self removeAllAnnotationSpecialDeleteButtons];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:ANNOTATION_WAS_REMOVED_NOTIFICATION object:nil userInfo:annotationDictToRemove];
    
    PDFDocumentScrollView *parentDoc = (PDFDocumentScrollView*)self.parentDocument;
    [parentDoc removeFromUserDefaultsDrawAnnotationDict:[annotationDictToRemove autorelease]];
    parentDoc.drawAnnotationsRemoveMode = NO;
}


















-(void) deleteTextAnnotationAction:(id) sender {
    SpecialDeleteAnnotationButton *currentSpecialButton = (SpecialDeleteAnnotationButton*)sender;
    NSDictionary *annotationDictToRemove = [[NSDictionary alloc] initWithDictionary: (NSDictionary *) currentSpecialButton.userInfo ];
    [self removeTextAnnotationSpecificDict:annotationDictToRemove];
    [self removeAllAnnotationSpecialDeleteButtons];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:ANNOTATION_WAS_REMOVED_NOTIFICATION object:nil userInfo:annotationDictToRemove];
    
    PDFDocumentScrollView *parentDoc = (PDFDocumentScrollView*)self.parentDocument;
    [parentDoc removeFromUserDefaultsTextAnnotationDict:[annotationDictToRemove autorelease]];
    parentDoc.textAnnotationsRemoveMode = NO;
}



-(void) removeAllAnnotationSpecialDeleteButtons {
    
//    NSLog(@" removeAllAnnotationSpecialDeleteButtons ");
    
    for (UIView *currentView in [self subviews]) {
        if (currentView.tag==SPECIAL_DELETE_ANNOTATION_BUTTON_TAG) {
            SpecialDeleteAnnotationButton *currentSpecialButton = (SpecialDeleteAnnotationButton*) currentView;
            currentSpecialButton.userInfo = nil;
            [currentSpecialButton removeFromSuperview];
        }
    }
}




-(BOOL) isDeleteSpecialButtonAlreadyAddedOnViewForAnnotationDictionary:(NSDictionary *) dict {  //sorry for long stuff
    
    BOOL result =NO;
    for (UIView *currentView in [self subviews]) {
        if (currentView.tag==SPECIAL_DELETE_ANNOTATION_BUTTON_TAG) {
            SpecialDeleteAnnotationButton *currentSpecialButton = (SpecialDeleteAnnotationButton*) currentView;
            NSDictionary *annotDict = (NSDictionary*) currentSpecialButton.userInfo;
            if ([annotDict isEqualToDictionary:dict]) { result = YES; break; }
        }
    }
    return result;
}








-(BOOL) isThisPageInUpdateRange {
	if (parentDocument==nil) { NSLog(@"isThisPageInUpdateRange return "); return NO; }
	PDFDocumentScrollView *parentDoc = (PDFDocumentScrollView *) parentDocument;
	NSRange rangeToLookIn = parentDoc.rangeOfPagesToBeUpdated;
	return	NSLocationInRange(pageNumber, rangeToLookIn);
}




- (void)setNeedsDisplayInRect:(CGRect)theRect {		
	[super setNeedsDisplayInRect:theRect];	
}




// determined iPhone Device
- (NSString *) IphoneModel {
//    return [[GlobalDocumentTracker sharedInstance] deviceModel];
    return @"";
}










-(void) changeTileSize {
    
    NSLog(@" changeTileSize ");
    
    CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
    tiledLayer.tileSize = CGSizeMake(256.0, 256.0);
}










-(void) dealloc {
    [super dealloc];
	willDeallocate = YES;
    
    if (textAnnotations!=nil) {
        [textAnnotations removeAllObjects];
        [textAnnotations release];
    }
    
    if (drawAnnotations!=nil) {
        [drawAnnotations removeAllObjects];
        [drawAnnotations release];
    }
}

//
////touches are here for drawing annotations
//
//-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    PDFDocumentScrollView *parentDoc = (PDFDocumentScrollView*) self.parentDocument;
//    if (parentDoc.drawingModeON==YES) {
//        
//        UITouch *touch = [touches anyObject];
//        firstPoint = [touch previousLocationInView:self];
//        secondPoint = [touch previousLocationInView:self];
//        currentPoint = [touch locationInView:self];
//        
//        
//        if (bezierPath==nil) {
//            bezierPath = [[UIBezierPath bezierPath] retain];
//            [bezierPath setLineCapStyle:kCGLineCapRound];
//            [bezierPath setLineWidth:parentDoc.drawingLineWidth];
//        }
//        
//        [bezierPath moveToPoint:currentPoint];
//        [bezierPath addLineToPoint:currentPoint];
//        [self setNeedsDisplay];
//        
//        /*
//         [curves addObject:[NSMutableArray array]];
//         
//         NSMutableArray *currentCurve = [curves lastObject];
//         if (currentCurve!=nil) {
//         NSDictionary *pointDict = (NSDictionary*) CGPointCreateDictionaryRepresentation(currentPoint);
//         [currentCurve addObject:[pointDict autorelease]];
//         }
//         
//         */
//    }
//}
//
//
//-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    PDFDocumentScrollView *parentDoc = (PDFDocumentScrollView*) self.parentDocument;
//    if (parentDoc.drawingModeON==YES) {
//        
//        UITouch *touch = [touches anyObject];
//        //here we save 3 last points
//        secondPoint = firstPoint;
//        firstPoint = [touch previousLocationInView:self];
//        currentPoint = [touch locationInView:self];
//        
//        //points in the middle of the line segments
//        CGPoint mid1 = midPoint(firstPoint, secondPoint);
//        CGPoint mid2 = midPoint(currentPoint, firstPoint);
//        
//        
//        if (bezierPath==nil) {
//            bezierPath = [[UIBezierPath bezierPath] retain];
//            [bezierPath setLineCapStyle:kCGLineCapRound];
//            [bezierPath setLineWidth:parentDoc.drawingLineWidth];
//        }
//        
//        [bezierPath moveToPoint:mid1]; //start new curve between two actual touches.
//        [bezierPath addQuadCurveToPoint:mid2 controlPoint:firstPoint]; //curves connect in middle points and use actual touch points as control points.
//        
//        [self setNeedsDisplay]; //redraw view.
//        
//        
//        //    NSMutableArray *currentCurve = [curves lastObject];
//        //    if (currentCurve!=nil) {
//        //        NSDictionary *pointDict = (NSDictionary*) CGPointCreateDictionaryRepresentation(currentPoint);
//        //        [currentCurve addObject:[pointDict autorelease]];
//        //    }
//    }
//    
//    
//}





//===========================================================================

/*
 -(id) initWithFrame:(CGRect) frame { //andPage:(CGPDFPageRef) page {
 
 self = [super initWithFrame:frame];
 
 if (self!=nil) {
 
 //init here
 
 NSLog(@"PDFPage initWithFrame: ");
 
 CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
 tiledLayer.levelsOfDetail = 4;
 tiledLayer.levelsOfDetailBias = 4;
 tiledLayer.tileSize = CGSizeMake(150.0, 150.0);
 
 NSString *docPath = [[NSBundle mainBundle] pathForResource:@"Exif" ofType:@"pdf"];
 NSURL *docURL = [NSURL fileURLWithPath:docPath];
 CGPDFDocumentRef pdfDoc = CGPDFDocumentCreateWithURL((CFURLRef)docURL);
 pdfPage =  CGPDFDocumentGetPage(pdfDoc, 3);
 
 NSLog(@" boxRect = %@", NSStringFromCGRect(CGPDFPageGetBoxRect(pdfPage, kCGPDFCropBox)));
 
 CGRect selfFrame = self.frame;
 selfFrame.size = CGSizeMake(CGPDFPageGetBoxRect(pdfPage, kCGPDFCropBox).size.width*2.0, CGPDFPageGetBoxRect(pdfPage, kCGPDFCropBox).size.height*2);
 self.frame = selfFrame;
 
 
 }
 
 return self;
 }
 */


/*
 // First fill the background with white.
 CGContextSetRGBFillColor(context, 1.0,1.0,1.0,1.0);
 
 CGContextSaveGState(context);
 
 
 NSString *docPath = [[NSBundle mainBundle] pathForResource:@"Exif" ofType:@"pdf"];
 NSURL *docURL = [NSURL fileURLWithPath:docPath];
 
 CGPDFDocumentRef pdfDoc = CGPDFDocumentCreateWithURL((CFURLRef)docURL);
 
 pdfPage =  CGPDFDocumentGetPage(pdfDoc, 1);
 
 NSLog(@" pdfPage = %@", pdfPage);
 
 CGContextDrawPDFPage(context, pdfPage);
 CGContextRestoreGState(context);
 
 UIGraphicsEndImageContext();
 */



/*
 
 -(id) init {
 
 self = [super init];
 
 if (self!=nil) {
 
 //init here
 
 NSLog(@" PDFPage init");
 
 CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
 tiledLayer.levelsOfDetail = 8;
 tiledLayer.levelsOfDetailBias = 3;
 tiledLayer.tileSize = CGSizeMake(300.0, 300.0);
 
 NSString *docPath = [[NSBundle mainBundle] pathForResource:@"Exif" ofType:@"pdf"];
 NSURL *docURL = [NSURL fileURLWithPath:docPath];
 CGPDFDocumentRef pdfDoc = CGPDFDocumentCreateWithURL((CFURLRef)docURL);
 pdfPage =  CGPDFDocumentGetPage(pdfDoc, 3);
 
 NSLog(@" boxRect = %@", NSStringFromCGRect(CGPDFPageGetBoxRect(pdfPage, kCGPDFCropBox)));
 
 CGRect selfFrame = self.frame;
 selfFrame.size = CGSizeMake(CGPDFPageGetBoxRect(pdfPage, kCGPDFCropBox).size.width, CGPDFPageGetBoxRect(pdfPage, kCGPDFCropBox).size.height);
 self.frame = selfFrame;
 }
 
 return self;
 }
 */



/*
 NSString *docPath = [[NSBundle mainBundle] pathForResource:@"Exif" ofType:@"pdf"];
 NSURL *docURL = [NSURL fileURLWithPath:docPath];
 CGPDFDocumentRef pdfDoc = CGPDFDocumentCreateWithURL((CFURLRef)docURL);
 */

@end

















#pragma mark -
#pragma mark -


#define BACKGROUND_SHADOW_TAG 124




@implementation PDFDocumentScrollView

@synthesize numberOfPages, rangeOfPagesToBeUpdated, parentObject, willDeallocateNow, PDFDocDelegate, lockHorizontal, docPath, drawingColor, drawingLineWidth, shouldDrawRuntimeAnnotations, shouldCenterTheContent;


- (id)initWithFrame:(CGRect)theFrame andDocument:(CGPDFDocumentRef) PDFDocument documentPath:(NSString *)documentPath{
	 
    @synchronized (self)    {
    
    self = [super initWithFrame:theFrame ];
	 
	 if (self!=nil) {
         
         self.docPath = documentPath;
         
		 deviceModel = [self IphoneModel];
		 willDeallocateNow = NO;
		 self.delegate = self;
		 self.bounces = YES;
		 self.alwaysBounceHorizontal = YES;
		 self.alwaysBounceVertical	 = YES;         
         
		 mainContentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0) ]; 
		 mainContentView.backgroundColor = [UIColor clearColor];
		 mainContentView.contentMode = UIViewContentModeScaleToFill;
		 
		 if (PDFDocument!=NULL) {
			 
			 pdfDocument = CGPDFDocumentRetain(PDFDocument);
			 
			 numberOfPages = CGPDFDocumentGetNumberOfPages(pdfDocument);
//			 NSLog(@" numberOfPages = %ld", numberOfPages);
			 pagesArray = [[NSMutableArray alloc] initWithCapacity:numberOfPages];
			 
			 CGSize pagesSize = CGSizeMake(0.0, 0.0);
			 CGFloat maxWidth = 0.0;
			 
			 pageStartPositions = (float*) malloc(numberOfPages*sizeof(CGFloat) );
                        
			 for (UInt32 i=1; i<=numberOfPages; i++) {
				 PDFPageView *currentPage = [[PDFPageView alloc] initWithPosition:CGPointMake(0.0, pagesSize.height) andPage:[self getPDFPageWithNumber:i] ];
				 currentPage.pageNumber = i;
				 currentPage.parentDocument = self;
                 
                 /*
                 // optional stuff. Show where the page will be shown. +++++++++++++++++++++++++++++++++++++++++++
                 UIView *backShadowView = [[UIView alloc] initWithFrame:currentPage.frame];
                 backShadowView.alpha = 0.1;
                 backShadowView.backgroundColor = [UIColor whiteColor];
                 backShadowView.tag = BACKGROUND_SHADOW_TAG + currentPage.pageNumber;
                 [mainContentView addSubview:[backShadowView autorelease] ];
                 */
                 	 
				 //remember where each page starts
				 pageStartPositions[i-1] = pagesSize.height;

                 
				 [mainContentView addSubview:[currentPage autorelease] ];
				 [pagesArray addObject:currentPage ];
				 
				 //take the maximum width from all pages and add heights
				 if (maxWidth<currentPage.frame.size.width) { maxWidth = currentPage.frame.size.width; }
				 pagesSize = CGSizeMake(maxWidth, currentPage.frame.origin.y + currentPage.frame.size.height + SPACE_BETWEEN_PAGES);
                 
                }
			 
			 // align page in center if there is more space for it.
				 for (PDFPageView *currentPage in pagesArray) {
					 float widthDifference = maxWidth - currentPage.frame.size.width;
					 if (widthDifference>0) {
                         currentPage.frame = CGRectMake(widthDifference/2.0, currentPage.frame.origin.y, currentPage.frame.size.width, currentPage.frame.size.height);
                         
                         // optional stuff. aligning shadow view with currentPage 
                         UIView *backShadowView = [mainContentView viewWithTag:BACKGROUND_SHADOW_TAG + currentPage.pageNumber];
                         backShadowView.frame = currentPage.frame;
                     }
				 }
			 NSRange pagesRange = [self currentRangeDisplayedInScrollView];
			 [self updateCurrentRangeFromRange:pagesRange];
			 
			 mainContentView.frame = CGRectMake(0.0, 0.0, pagesSize.width, pagesSize.height);
			 self.contentSize = mainContentView.frame.size;
			 
			 //offset by first page
			 PDFPageView *firstPage = [pagesArray objectAtIndex:0];
			 self.contentOffset = CGPointMake(firstPage.frame.origin.x, 0.0);
			 
			 [self addSubview:[mainContentView autorelease]];
		 } else {
			 self.contentSize = CGSizeMake(0.0, 0.0);
		 }

    
    
    
    //ANNOTATIONS
    //================================================================================================================
         textAnnotationsRemoveMode = NO;
         
        
    NSDictionary *allAnnotations = [[NSUserDefaults standardUserDefaults] dictionaryForKey:PDF_DOCUMENTS_ANNOTATION_COLLECTION];
    NSDictionary *currentDocAnnotations = [allAnnotations objectForKey:self.docPath];

         
         //text annotations============================
         for (NSDictionary *currentTextAnnotation in [currentDocAnnotations objectForKey:ANNOTATION_TEXT_ANNOTATION_ARRAY]) {
             UInt32 annotationPageNumber = [[currentTextAnnotation objectForKey:TEXT_ANNOTATION_PAGE_NUMBER_KEY] integerValue];
             PDFPageView *pageToAddAnnotationTo = [self getPDFPageViewWithNumber:annotationPageNumber];
             [pageToAddAnnotationTo  addTextAnnotationDictionary:currentTextAnnotation];
         }
         
//         NSLog(@" CURRENT DOC ANNOTS =%@ ", currentDocAnnotations);
//         NSLog(@" number OF OBJECTS = %d", [[allAnnotations allValues] count]);
//         NSLog(@" ALL KEYS = %@", [allAnnotations allKeys]);
//         NSLog(@" OBJECT FOR SELF.DOCPATH = %@", [allAnnotations objectForKey:self.docPath] );
         
         
         //drawing defaults
         self.drawingModeON = NO;
         self.drawingColor = [UIColor blackColor];
         self.drawingLineWidth = 4;
         self.drawAnnotationsRemoveMode = NO;
         
         for (NSDictionary *currentDrawAnnotDict in [currentDocAnnotations objectForKey:ANNOTATION_DRAW_ANNOTATION_ARRAY]) {
             PDFPageView *pageToAddAnnotationTo = [self getPDFPageViewWithNumber:[[currentDrawAnnotDict objectForKey:DRAW_ANNOTATION_PAGE_NUMBER_KEY] integerValue] ];
             [pageToAddAnnotationTo addDrawAnnotationDict:currentDrawAnnotDict];
         }
         
         
         self.shouldCenterTheContent = YES;
    //================================================================================================================
	 }
        
        isScrollingNow = NO;
        
    } //synchronized end
    
	 return self;
    
//    [self temp_addBezierPoints];
}


-(void) temp_addBezierPoints {
    
    if (temp_bezier==nil) {
        temp_bezier = [[UIBezierPath bezierPath] retain];
        [temp_bezier setLineCapStyle:kCGLineCapRound];
        [temp_bezier setLineWidth:4];
    }
    
    CGPoint secondPoint = CGPointMake(50, 50);
    CGPoint firstPoint = CGPointMake(100, 50);
    CGPoint currentPoint = CGPointMake(100, 100);
    
    //points in the middle of the line segments
    CGPoint mid1 = midPoint(firstPoint, secondPoint);
    CGPoint mid2 = midPoint(currentPoint, firstPoint);
    
    [temp_bezier moveToPoint:mid1];
    [temp_bezier addQuadCurveToPoint:mid2 controlPoint:firstPoint];
    
    [self setNeedsDisplay];
}



-(void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    [temp_bezier stroke];
}












//========================================================================================================
#pragma mark ANNOTATIONS
//========================================================================================================
-(BOOL) textAnnotationsRemoveMode {
    return textAnnotationsRemoveMode;
}

-(void) setTextAnnotationsRemoveMode:(BOOL) value {
    //    NSLog(@" setAnnotationRemoveMode, value = %d", value);
    textAnnotationsRemoveMode = value;
    
    for (PDFPageView *currentView in pagesArray) {
        if (textAnnotationsRemoveMode==NO) { [currentView removeAllAnnotationSpecialDeleteButtons]; }
        [currentView.layer setNeedsDisplay];
    }
}







#pragma mark Draw

-(BOOL) drawAnnotationsRemoveMode {
    return drawAnnotationsRemoveMode;
}

-(void) setDrawAnnotationsRemoveMode:(BOOL) value {
    //    NSLog(@" setAnnotationRemoveMode, value = %d", value);
    drawAnnotationsRemoveMode = value;
    
    for (PDFPageView *currentView in pagesArray) {
        if (drawAnnotationsRemoveMode==NO) { [currentView removeAllAnnotationSpecialDeleteButtons]; }
        [currentView.layer setNeedsDisplay];
    }
}



//drawing
-(BOOL) drawingModeON {
    return drawingModeON;
}

-(void) setDrawingModeON:(BOOL)value {
    drawingModeON = value;
    self.scrollEnabled = !value;
}




-(void) addDrawAnnotationsWithDict:(NSDictionary*) drawAnnotDict { //this is pack of curves and page number, inside the pack curves are only for one page
    PDFPageView *pageView = [self getPDFPageViewWithNumber:[[drawAnnotDict objectForKey:DRAW_ANNOTATION_PAGE_NUMBER_KEY] unsignedIntValue]];
    [pageView addDrawAnnotationDict:drawAnnotDict];
    [self updateUserDefaultsWithDrawAnnotationDict:drawAnnotDict];
}

-(void) removeFromUserDefaultsDrawAnnotationDict:(NSDictionary*) dictToRemove {
    
    NSMutableDictionary *allAnnotations = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:PDF_DOCUMENTS_ANNOTATION_COLLECTION] ];
    NSMutableDictionary *updatedDocAnnotations = [NSMutableDictionary dictionaryWithDictionary:[allAnnotations objectForKey:self.docPath] ];
    NSMutableArray *updatedDrawAnnotationsArray = [NSMutableArray arrayWithArray:[updatedDocAnnotations objectForKey:ANNOTATION_DRAW_ANNOTATION_ARRAY] ];
    NSInteger indexToRemove = -1;
    for (NSDictionary *currentDict in updatedDrawAnnotationsArray) {
        if ([currentDict isEqualToDictionary:dictToRemove]==YES) {
            indexToRemove = [updatedDrawAnnotationsArray indexOfObject:currentDict];
            break;
        }
    }
    if (indexToRemove>=0 && indexToRemove<[updatedDrawAnnotationsArray count]) { [updatedDrawAnnotationsArray removeObjectAtIndex:indexToRemove]; }
    [updatedDocAnnotations removeObjectForKey:ANNOTATION_DRAW_ANNOTATION_ARRAY];
    [updatedDocAnnotations setObject:updatedDrawAnnotationsArray forKey:ANNOTATION_DRAW_ANNOTATION_ARRAY];
    [allAnnotations removeObjectForKey:self.docPath];
    [allAnnotations setObject:updatedDocAnnotations forKey:self.docPath];
    
    [[NSUserDefaults standardUserDefaults] setObject:allAnnotations forKey:PDF_DOCUMENTS_ANNOTATION_COLLECTION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) updateUserDefaultsWithDrawAnnotationDict:(NSDictionary *) drawAnnot {
    
    NSMutableDictionary *allAnnotations = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:PDF_DOCUMENTS_ANNOTATION_COLLECTION] ];
    NSMutableDictionary *updatedDocAnnotations = [NSMutableDictionary dictionaryWithDictionary:[allAnnotations objectForKey:self.docPath] ];
    NSMutableArray *updatedDrawAnnotationsArray = [NSMutableArray arrayWithArray:[updatedDocAnnotations objectForKey:ANNOTATION_DRAW_ANNOTATION_ARRAY]];
    [updatedDrawAnnotationsArray addObject:drawAnnot];
    [updatedDocAnnotations removeObjectForKey:ANNOTATION_DRAW_ANNOTATION_ARRAY]; //perhaps redundant
    [updatedDocAnnotations setObject:updatedDrawAnnotationsArray forKey:ANNOTATION_DRAW_ANNOTATION_ARRAY];
    [allAnnotations removeObjectForKey:self.docPath];
    [allAnnotations setObject:updatedDocAnnotations forKey:self.docPath];
    [[NSUserDefaults standardUserDefaults] setObject:allAnnotations forKey:PDF_DOCUMENTS_ANNOTATION_COLLECTION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}









#pragma mark Text

-(void) addTextAnnotationWithText:(NSString *) text insideScrollViewFrame: (CGRect) frame withFont:(UIFont *) font withColor:(UIColor *) color withPointSize:(CGFloat) pointSize {
    
    CGPoint positionInMainContainer = [self convertPoint:frame.origin toView:mainContentView];
    PDFPageView *pageToAnnotate = nil;
    
    for (PDFPageView *currentPage in pagesArray) {
        
        if (CGRectContainsPoint(currentPage.frame, positionInMainContainer) ) {
            pageToAnnotate = currentPage;
            break;
        }
    }
    

    //composing annotation dictionary
    //==========================================================================================
    
    NSString *scrollTextFrameString = NSStringFromCGRect(frame);
    NSNumber *pageNumber = [NSNumber numberWithInteger:pageToAnnotate.pageNumber];
    CGPoint positionInCurrentPage = [pageToAnnotate convertPoint:positionInMainContainer fromView:mainContentView];
    NSString *PDFPageTextFrameString = NSStringFromCGRect(CGRectMake(positionInCurrentPage.x, positionInCurrentPage.y, frame.size.width/self.zoomScale, frame.size.height/self.zoomScale));
    NSString *fontName = font.fontName;
    
    const CGFloat* components = CGColorGetComponents([color CGColor]);
    CGFloat red = components[0];
    CGFloat green = components[1];
    CGFloat blue = components[2];
    CGFloat alpha = CGColorGetAlpha([color CGColor]);
    
    if (CGColorGetNumberOfComponents([color CGColor])<4) {
        red = green = blue = 0.0;
        alpha = 1.0;
    }

    NSDictionary *RGBColorsDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:red], COLOR_RED_VALUE_KEY, [NSNumber numberWithFloat:green], COLOR_GREEN_VALUE_KEY, [NSNumber numberWithFloat:blue], COLOR_BLUE_VALUE_KEY, [NSNumber numberWithFloat:alpha], COLOR_ALPHA_VALUE_KEY, nil];
    
    NSNumber *pointSizeNumber = [NSNumber numberWithFloat:font.pointSize/self.zoomScale];
    
    
    NSDictionary *textAnnotationDictionary = [NSDictionary dictionaryWithObjectsAndKeys:text, TEXT_ANNOTATION_TEXT_STRING_KEY, scrollTextFrameString,
                                              TEXT_ANNOTATION_SCROLLVIEW_TEXT_FRAME_STRING_KEY, pageNumber,
                                              TEXT_ANNOTATION_PAGE_NUMBER_KEY, PDFPageTextFrameString,
                                              TEXT_ANNOTATION_CGPDFPAGE_TEXT_FRAME_STRING_KEY, fontName,
                                              TEXT_ANNOTATION_FONTNAME_STRING_KEY, RGBColorsDict,
                                              TEXT_ANNOTATION_COLOR_RGB_DICT_KEY, pointSizeNumber,
                                              TEXT_ANNOTATION_POINTSIZE_NUMBER_KEY, nil];
    //==========================================================================================
    
    [pageToAnnotate addTextAnnotationDictionary:textAnnotationDictionary];
    [self updateUserDefaultsWithTextAnnotationDict:textAnnotationDictionary];
}

-(void) removeFromUserDefaultsTextAnnotationDict:(NSDictionary *) dictToRemove {
    
    NSMutableDictionary *allAnnotations = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:PDF_DOCUMENTS_ANNOTATION_COLLECTION] ];
    NSMutableDictionary *updatedDocAnnotations = [NSMutableDictionary dictionaryWithDictionary:[allAnnotations objectForKey:self.docPath] ];
    NSMutableArray *updatedTextAnnotationsArray = [NSMutableArray arrayWithArray: [updatedDocAnnotations objectForKey:ANNOTATION_TEXT_ANNOTATION_ARRAY] ];
    
    NSInteger indexToRemove = -1;
    for(NSDictionary *currentDict in updatedTextAnnotationsArray) {
        if ([currentDict isEqualToDictionary:dictToRemove]==YES) {
            indexToRemove = [updatedTextAnnotationsArray indexOfObject:currentDict];
            NSLog(@" indexToRemove = %d", indexToRemove);
            break;
        }
    }
    
    if (indexToRemove>=0 && indexToRemove<[updatedTextAnnotationsArray count]) { [updatedTextAnnotationsArray removeObjectAtIndex:indexToRemove]; }
    
    [updatedDocAnnotations removeObjectForKey:ANNOTATION_TEXT_ANNOTATION_ARRAY];
    [updatedDocAnnotations setObject:updatedTextAnnotationsArray forKey:ANNOTATION_TEXT_ANNOTATION_ARRAY];
    [allAnnotations removeObjectForKey:self.docPath];
    [allAnnotations setObject:updatedDocAnnotations forKey:self.docPath];
    
    [[NSUserDefaults standardUserDefaults] setObject:allAnnotations forKey:PDF_DOCUMENTS_ANNOTATION_COLLECTION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) updateUserDefaultsWithTextAnnotationDict:(NSDictionary *) newTextDict {
    
    NSMutableDictionary *allAnnotations = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:PDF_DOCUMENTS_ANNOTATION_COLLECTION] ];
    NSMutableDictionary *updatedDocAnnotations = [NSMutableDictionary dictionaryWithDictionary:[allAnnotations objectForKey:self.docPath] ];
    NSMutableArray *updatedTextAnnotationsArray = [NSMutableArray arrayWithArray: [updatedDocAnnotations objectForKey:ANNOTATION_TEXT_ANNOTATION_ARRAY] ];
    [updatedTextAnnotationsArray addObject:newTextDict];
    [updatedDocAnnotations removeObjectForKey:ANNOTATION_TEXT_ANNOTATION_ARRAY];
    [updatedDocAnnotations setObject:updatedTextAnnotationsArray forKey:ANNOTATION_TEXT_ANNOTATION_ARRAY];
    [allAnnotations removeObjectForKey:self.docPath];
    [allAnnotations setObject:updatedDocAnnotations forKey:self.docPath];
    
    [[NSUserDefaults standardUserDefaults] setObject:allAnnotations forKey:PDF_DOCUMENTS_ANNOTATION_COLLECTION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}























#pragma mark Helpers


-(void) showPageViewWithNumber:(NSInteger) pageNum toFitInScrollViewRect:(CGRect) rect animated:(BOOL) animated outputPageRect:(CGRect*) pageRect{
    PDFPageView *pageView = [self getPDFPageViewWithNumber:pageNum];
    CGRect pageRectInScrollView = [pageView.superview convertRect:pageView.bounds toView:self];
    
    //scale
    CGFloat scaleFactor = MIN(rect.size.width/pageRectInScrollView.size.width, rect.size.height/pageRectInScrollView.size.height);
    [self setZoomScale:scaleFactor*self.zoomScale animated:animated];

    pageRectInScrollView = [pageView.superview convertRect:pageView.frame toView:self];
    //move
    float offsetToGoTo = (pageStartPositions[pageNum-1] * self.zoomScale);
	[self setContentOffset:CGPointMake(pageRectInScrollView.origin.x, offsetToGoTo) animated:animated];
    

    NSLog(@" pageRectInScrollView=%@", NSStringFromCGRect(pageRectInScrollView));
    *pageRect = pageRectInScrollView;
}



-(PDFPageView *) getPDFPageViewWithNumber:(NSInteger) pageNumber  { //starts with 1
    if (pageNumber<=0 || pageNumber>numberOfPages) { return nil;  }
    if (pageNumber>[pagesArray count]) { NSLog(@" check for errors 324"); return nil; }
    return [pagesArray objectAtIndex:pageNumber-1];
}





-(void) showPoint:(CGPoint) position onThePageWithNumber:(NSInteger) pageNumber { //will show position on the specified page in the top left corner

    if (pageNumber<1 || pageNumber>numberOfPages) { return;  }
    float widthDifference = self.frame.size.width - mainContentView.frame.size.width;
    
    // will show point in the corner only if page exceeds screen size, othewise will just show beginning of the page
	if (widthDifference<=0.0) { 
        float pageBeginning = pageStartPositions[pageNumber-1]*self.zoomScale;
        float someExtraSpace = 30.0;
        PDFPageView *currentPage = [pagesArray objectAtIndex:pageNumber-1];
        float widthToAdjust = currentPage.frame.origin.x * self.zoomScale;
        CGPoint offsetToSet = CGPointMake(position.x*self.zoomScale-someExtraSpace+widthToAdjust, pageBeginning+position.y*self.zoomScale-someExtraSpace);
        [self setContentOffset:offsetToSet animated:YES];         
    } else {
        [self goToPage:(NSUInteger)pageNumber animated:YES];
    }
}


-(PDFPageView *) getCurrentPageViewDisplayed {
	if (willDeallocateNow==YES) { return NULL; }	
    int pageNumber = [self getCurrentPageNumberDisplayed];
    if (pageNumber-1>[pagesArray count] || pageNumber-1<0) { return NULL; }
    PDFPageView *currentPage = [pagesArray objectAtIndex:pageNumber-1];
    return currentPage;
}


-(CGPDFPageRef) getCurrentCGPDFPageDisplayed {
	if (willDeallocateNow==YES) { return NULL; }	
    int pageNumber = [self getCurrentPageNumberDisplayed];
    if (pageNumber>[pagesArray count]) { return NULL; }
    PDFPageView *currentPage = [pagesArray objectAtIndex:pageNumber-1];
    return [currentPage getCGPDFPage];
}


-(CGPDFDocumentRef) getCurrentCGPDFDocument {
    return pdfDocument;
}





// will assume that this will put retain count to 0 and dealloc will be called to destroy self. 
-(void) removeFromSuperview {
    NSLog(@"pdfdocscroll remove from superview");
    @synchronized (self) {
    [super removeFromSuperview];
	self.delegate = nil;
        
        
    for (int i = 0; i < pagesArray.count; i++) {
        PDFPageView *currentPage = [pagesArray objectAtIndex:i];
        currentPage.parentDocument = nil; currentPage.allowViewUpdate = NO;
        
    }
        
    
    [pagesArray removeAllObjects];
    [pagesArray release];
    CGPDFDocumentRelease(pdfDocument);
	pdfDocument = NULL;
        
//    [mainContentView removeFromSuperview];
    }
}



-(void) setMainContentViewToZeroPosition {    
    mainContentView.frame = CGRectMake(0, 0, mainContentView.frame.size.width, mainContentView.frame.size.height);
}


-(void) centerTheContent {
	if (willDeallocateNow==YES || shouldCenterTheContent==NO) { return; }
	float widthDifference = self.frame.size.width - mainContentView.frame.size.width;
	if (widthDifference>0.0) { 
		[UIView animateWithDuration:0.3 animations:^{
			mainContentView.frame = CGRectMake(widthDifference/2.0, mainContentView.frame.origin.y, mainContentView.frame.size.width, mainContentView.frame.size.height); }			
						 completion:^(BOOL success){ }];
		
	} else if (mainContentView.frame.origin.x!=0.0) {
		[UIView animateWithDuration:0.3 animations:^{
			mainContentView.frame = CGRectMake(0.0, mainContentView.frame.origin.y, mainContentView.frame.size.width, mainContentView.frame.size.height); }			
						 completion:^(BOOL success){  }];
	}	
}



-(void) goToPage:(NSUInteger) pageNumber animated:(BOOL) animated {
    
    NSLog(@"pageNumber:%d",pageNumber);
    
	if (pageNumber>numberOfPages || pageNumber==0) { NSLog(@"error: no such page to go to"); return; }
    
    float offsetToGoTo = (pageStartPositions[pageNumber-1] * self.zoomScale);
    if (self.zoomScale<1.0) {
        offsetToGoTo = offsetToGoTo - self.frame.size.height/2.0 + 1.0; // so that page to be displayed in the middle of the screen     
    }
    
	[self setContentOffset:CGPointMake(self.contentOffset.x, offsetToGoTo) animated:animated];
}





-(int) getCurrentPageNumberDisplayed {
	if (willDeallocateNow==YES) { return 0; }
	//which page has the most of the screen in this case.
	int currentPageDisplayed = 0;
	for (int i=0; i<numberOfPages; i++) {
		float zoomIndependentOffset = (self.contentOffset.y+self.frame.size.height/2.0) / self.zoomScale;
        currentPageDisplayed = i+1;
		if ( (zoomIndependentOffset >= pageStartPositions[i])  && (zoomIndependentOffset < pageStartPositions[i+1]) ) {  break; }
	}		
	return currentPageDisplayed;
}



-(void) goNextPage { //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    
    if (isScrollingNow==YES) { return; }
    
    int currentPage = [self getCurrentPageNumberDisplayed];    
    if (currentPage+1>numberOfPages) {
        [self goToPage:1 animated:YES];
        return;
    }    
    
    float currentOffset = pageStartPositions[currentPage-1]*self.zoomScale;
    float nextPageOffset = pageStartPositions[currentPage]*self.zoomScale;
    float offsetToToMove = abs(nextPageOffset-currentOffset);
    [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y+offsetToToMove) animated:YES];
}


-(void) goPreviousPage {

    if (isScrollingNow==YES) { return; }
    
    int currentPage = [self getCurrentPageNumberDisplayed];    
    if (currentPage-1<=0) {
        [self goToPage:numberOfPages animated:YES];
        return;
    }
    
    float currentOffset = pageStartPositions[currentPage-1]*self.zoomScale;
    float prevPageOffset = pageStartPositions[currentPage-2]*self.zoomScale;    
    float offsetToToMove = abs(currentOffset-prevPageOffset);
    [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y-offsetToToMove) animated:YES];
}



-(PDFPageView*) pageViewThatContainsPosition:(CGPoint) position { //position from self
    CGPoint positionInMainContainer = [self convertPoint:position toView:mainContentView];
    for (PDFPageView *currentPage in pagesArray) {
        
        if (CGRectContainsPoint(currentPage.frame, positionInMainContainer) ) {
            return currentPage;
            break;
        }
    }
    return nil;
}




#pragma mark -
#pragma mark ScrollView delegates

-(void) scrollViewDidZoom:(UIScrollView *)scrollView {
//    NSLog(@" scrollViewDidZoom: ");
}


-(void) scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
//	NSRange pagesRange = [self currentRangeDisplayedInScrollView];
//	[self updateCurrentRangeFromRange:pagesRange]; looks like not needed anymore+++++++++++++++++++++++++++
	[self centerTheContent];
    
    isScrollingNow = NO;
    
    //fucking added+++++++++++++++++++
    [PDFDocDelegate pdfDocumentScrollView:self didZoomToScale:scale withView:view];
    /*
    PDFPageView *currentPageView = [self getCurrentPageViewDisplayed];
    [currentPageView setNeedsDisplay];
    
    CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
    [tiledLayer setNeedsDisplay];
     */
        
//    NSLog(@" mainContainer.frame=%@ ",NSStringFromCGRect(mainContentView.frame) );
//    PDFPageView *fPage = [self getPDFPageViewWithNumber:1];
//    NSLog(@" fPage.frame=%@", NSStringFromCGRect(fPage.frame) );
//    NSLog(@" contentOffset = %@", NSStringFromCGPoint(self.contentOffset) );
    
    
    for (PDFPageView *page in pagesArray) {
        [page.layer setNeedsDisplay];
    }
}


-(void) scrollViewDidScroll:(UIScrollView *) scrollView {   
//    NSLog(@" scrollViewDidScroll, contentOffset = %@ ", NSStringFromCGPoint(scrollView.contentOffset) );
    if (self.lockHorizontal==YES) {
        scrollView.contentOffset = CGPointMake(prevOffset.x, scrollView.contentOffset.y);
    }
    if (PDFDocDelegate!=nil && self!=nil) {
        [PDFDocDelegate pdfDocumentScrollView:self didScrollToPage:[self getCurrentPageNumberDisplayed]];
    }
    prevOffset = scrollView.contentOffset;
 
    isScrollingNow = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetScrollingFlag) object:nil];
    [self performSelector:@selector(resetScrollingFlag) withObject:nil afterDelay:0.3];

}

- (void)updateAllThis
{
    for (PDFPageView *page in pagesArray) {
        [page.layer setNeedsDisplay];
    }
}


-(void) resetScrollingFlag {
    isScrollingNow = NO;
}


-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    isScrollingNow = NO;
    
    for (PDFPageView *page in pagesArray) {
        [page.layer setNeedsDisplay];
    }
}


-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return mainContentView;
}


-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (decelerate==NO) {
//		NSRange pagesRange = [self currentRangeDisplayedInScrollView]; +++++++++++++++++
//		[self updateCurrentRangeFromRange:pagesRange];
	}
    isScrollingNow = NO;
}

//-----------------------------------------------------------------------------------------------------------------------------------------







-(NSRange) currentRangeDisplayedInScrollView {
	if (willDeallocateNow==YES) { return NSMakeRange(0, 0); }
	if ([pagesArray count]>0) {
		int topVisiblePageNumber = 0;
		int bottomVisiblePageNumber = self.numberOfPages; //0;
		float zoomIndependentOffset = self.contentOffset.y/self.zoomScale;
		for (int i=0; i<numberOfPages-1; i++) {
		
			if ( (zoomIndependentOffset >= pageStartPositions[i])  && (zoomIndependentOffset < pageStartPositions[i+1]) ) {
				topVisiblePageNumber = i+1;
			}
			
			if ( ( (zoomIndependentOffset+self.frame.size.height/self.zoomScale) >= pageStartPositions[i]) && ((zoomIndependentOffset+self.frame.size.height/self.zoomScale) < pageStartPositions[i+1])  ) {
				bottomVisiblePageNumber = i+1;
//                NSLog(@" pageStartPositions[i+1] = %f", pageStartPositions[i+1]);
				break;
			}
		}
        
//        NSLog(@"topVis = %d, bottomVis = %d, zoomIndependentOffset =%f", topVisiblePageNumber, bottomVisiblePageNumber, zoomIndependentOffset);
        
		return NSMakeRange( (NSUInteger)topVisiblePageNumber , (NSUInteger)(bottomVisiblePageNumber-topVisiblePageNumber) );
	}
	return NSMakeRange(0, 0);
}




-(void) updateCurrentRangeFromRange:(NSRange) pagesRange {
	if (willDeallocateNow==YES) { return; }
	int startPageToUdate = pagesRange.location-PAGES_TO_UPDATE_AROUND - 1;
	int endPageToUpdate  = pagesRange.location+pagesRange.length+PAGES_TO_UPDATE_AROUND;
	
	if (startPageToUdate<0) { startPageToUdate = 0; }
	if (endPageToUpdate<0) { startPageToUdate = 0; }
        
	rangeOfPagesToBeUpdated = NSMakeRange( (NSUInteger) startPageToUdate, (NSUInteger)abs(endPageToUpdate-startPageToUdate)  );
	
	for (int i=startPageToUdate; i<=endPageToUpdate; i++) {
		if (i>=[pagesArray count] || i<0) { continue; }
		PDFPageView *currentPage = [pagesArray objectAtIndex:i];
		[currentPage.layer setNeedsDisplay];
	}
}







// determined iPhone Device
- (NSString *) IphoneModel {
//    return [[GlobalDocumentTracker sharedInstance] deviceModel];
    return @"";
}



-(CGPDFDocumentRef) createPDFDocumentWithFilePath:(NSString *) filePath {
	if (filePath==nil || [filePath isEqualToString:@""]) { return NULL; }
	NSURL *fileURL = [NSURL fileURLWithPath:filePath];
	return CGPDFDocumentCreateWithURL((CFURLRef)fileURL);
}



-(CGPDFPageRef) getPDFPageWithNumber:(UInt32) pageNumber {
	if (pdfDocument==NULL || willDeallocateNow==YES) { return NULL; }
	return CGPDFDocumentGetPage(pdfDocument, pageNumber);
}



-(void) setCGPDFDocument:(CGPDFDocumentRef) CGPDFDoc {
	pdfDocument = CGPDFDocumentRetain(CGPDFDoc);
}



- (void)dealloc {
    
    
    self.docPath = nil;
    
    free(pageStartPositions);
    NSLog(@" PDFDocument DEALLOC");
    
    [super dealloc];
}

@end







/*
 
 int pageToGo = [self getCurrentPageNumberDisplayed]+1;
 
 //    [self goToPage:[self getCurrentPageNumberDisplayed]+1 animated:YES];
 
 
 if (pageToGo>numberOfPages || pageToGo==0) { NSLog(@"error: no such page to go to"); return; }
 
 
 float offsetToGoTo = (pageStartPositions[pageToGo-1] * self.zoomScale);
 if (self.zoomScale<1.0) {
 offsetToGoTo = offsetToGoTo  + 1.0; // so that page to be displayed in the middle of the screen     
 }
 
 [self setContentOffset:CGPointMake(self.contentOffset.x, offsetToGoTo) animated:YES];
 
 */

/*
 NSLog(@" goNextPage");
 int currentPageDisplayed = 0;
 for (int i=0; i<numberOfPages-1; i++) {
 float zoomIndependentOffset = (self.contentOffset.y+5.0) / self.zoomScale;
 if ( (zoomIndependentOffset >= pageStartPositions[i])  && (zoomIndependentOffset < pageStartPositions[i+1]) ) { currentPageDisplayed = i+1; break; }
 }	    
 
 NSLog(@" currentPageDisplayed = %d", currentPageDisplayed);
 
 [self goToPage:currentPageDisplayed+1 animated:YES];
 */


/*
 NSInteger currentPageDisplayed = [self getCurrentPageNumberDisplayed];
 NSInteger pageToGoTo = currentPageDisplayed+1;
 
 if ( pageToGoTo> self.numberOfPages || pageToGoTo==0) { NSLog(@"error: no such page to go to"); return; }
 float offsetToGoTo = (pageStartPositions[pageToGoTo-1] - self.frame.size.height/2.0) * self.zoomScale;
 [self setContentOffset:CGPointMake(self.contentOffset.x, offsetToGoTo) animated:YES];
 */

//    PDFPageView *currentPage = [self getCurrentPageViewDisplayed]; //// 
//[currentPage changeTileSize]; the fuck is this?




/*
 //    [self goToPage:[self getCurrentPageNumberDisplayed]-1 animated:YES];
 int pageToGo = [self getCurrentPageNumberDisplayed]+1;
 if (pageToGo>numberOfPages || pageToGo==0) { NSLog(@"error: no such page to go to"); return; }
 float offsetToGoTo = (pageStartPositions[pageToGo-1] * self.zoomScale);
 if (self.zoomScale<1.0) {
 offsetToGoTo = offsetToGoTo + 1.0; // so that page to be displayed in the middle of the screen     
 }
 [self setContentOffset:CGPointMake(self.contentOffset.x, offsetToGoTo) animated:YES];
 */


/*
 NSLog(@" goPreviousPage ");
 int currentPageDisplayed = 0;
 for (int i=0; i<numberOfPages; i++) {
 float zoomIndependentOffset = (self.contentOffset.y+5.0) / self.zoomScale;
 currentPageDisplayed = i+1;
 if ( (zoomIndependentOffset >= pageStartPositions[i])  && (zoomIndependentOffset < pageStartPositions[i+1]) ) { break; }
 }	    
 NSLog(@" currentPageDisplayed = %d", currentPageDisplayed);
 
 [self goToPage:currentPageDisplayed-1 animated:YES];   
 */








//    size_t size;
//	sysctlbyname("hw.machine", NULL, &size, NULL, 0);
//	char *machine = malloc(size);
//	sysctlbyname("hw.machine", machine, &size, NULL, 0);
//	NSString *platform = [NSString stringWithCString:machine encoding: NSUTF8StringEncoding];
//	free(machine);
//
////	NSLog(@" Platform = %@", platform);
//
//	if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
//	if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
//	if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
//	if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
//	if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
//	if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
//	if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
//	if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
//	if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
//	if ([platform isEqualToString:@"i386"])         return @"Simulator";
//	if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
//	if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3";
//	return platform;






//	if (needsUpdate==YES) {	CGContextDrawPDFPage(context, pdfPage); } else { NSLog(@" page isNotUpdated, pageN = %d", self.pageNumber); }
//	CGContextDrawPDFPage(context, pdfPage);

/* search results highlighting
 volatile PDFDocumentScrollView *parentDoc = (PDFDocumentScrollView *) parentDocument;
 if (parentDoc.getCurrentPageNumberDisplayed == self.pageNumber) {
 
 //        NSLog(@" page to update = %d", pageNumber);
 
 CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
 CGContextSetBlendMode(context, kCGBlendModeMultiply);
 
 PDFDisplayViewController *viewController = (PDFDisplayViewController *) parentDoc.parentObject;
 Scanner *scanner = viewController.pdfScanner;
 
 //        NSLog(@" scanner.keyword = %@", scanner.keyword);
 
 for (Selection *currentSelection in scanner.selections)
 {
 NSLog(@" drawing for currentSelection = %@, transform = %@", NSStringFromCGRect(currentSelection.frame), NSStringFromCGAffineTransform(currentSelection.transform));
 CGContextSaveGState(context);
 CGContextConcatCTM(context, currentSelection.transform);
 CGContextFillRect(context, currentSelection.frame);
 CGContextRestoreGState(context);
 }
 }
 */







//            sizeDrawn = [text drawAtPoint:positionInMainContainer forWidth:frame.size.width withFont:zoomDependingFont minFontSize:zoomDependingFont.pointSize actualFontSize:&actualFontSize lineBreakMode:NSLineBreakByWordWrapping baselineAdjustment:UIBaselineAdjustmentAlignCenters];






/* working option
 CGContextSetTextDrawingMode(context,kCGTextFill);
 CGContextSetRGBFillColor(context, 1, 0, 0, 1);
 const char *text = "Test Annotation.";
 CGContextSelectFont(context, "Arial", 24, kCGEncodingMacRoman);
 CGContextShowTextAtPoint(context, 0, 0, text, strlen(text) );
 */




/* working option
 UIGraphicsPushContext(context);
 
 NSString *text = @"\
 \
 \
 asend.";
 UIFont *font = [UIFont systemFontOfSize:24];
 CGSize pageSize = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox).size;
 
 CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1);
 
 CGSize sizeDrawn;
 CGFloat actualFontSize = font.pointSize;
 //    sizeDrawn = [text drawAtPoint:CGPointMake(0, 0) forWidth:pageSize.width withFont:font minFontSize:10.0 actualFontSize:&actualFontSize lineBreakMode:NSLineBreakByClipping baselineAdjustment:UIBaselineAdjustmentAlignCenters];
 
 //or
 
 sizeDrawn = [text drawInRect:CGRectMake(0, 0, 100, 150) withFont:font lineBreakMode:NSLineBreakByWordWrapping];
 
 NSLog(@" size drawn = %@", NSStringFromCGSize(sizeDrawn) );
 NSLog(@" pageSize = %@", NSStringFromCGSize(pageSize));
 UIGraphicsPopContext();
 //    */




//                const CGPoint points[8] = {
//                    CGPointMake(pdfPageTextFrame.origin.x+cornerWidth, pdfPageTextFrame.origin.y), CGPointMake(pdfPageTextFrame.origin.x+sizeDrawn.width-cornerWidth, pdfPageTextFrame.origin.y),
//                    CGPointMake(pdfPageTextFrame.origin.x, pdfPageTextFrame.origin.y+cornerWidth/2.0), CGPointMake(pdfPageTextFrame.origin.x, pdfPageTextFrame.origin.y+sizeDrawn.height-cornerWidth),
//                    CGPointMake(pdfPageTextFrame.origin.x+cornerWidth, pdfPageTextFrame.origin.y+sizeDrawn.height), CGPointMake(pdfPageTextFrame.origin.x+sizeDrawn.width-cornerWidth, pdfPageTextFrame.origin.y+sizeDrawn.height),
//                    CGPointMake(pdfPageTextFrame.origin.x+sizeDrawn.width, pdfPageTextFrame.origin.y+cornerWidth/2.0), CGPointMake(pdfPageTextFrame.origin.x+sizeDrawn.width, pdfPageTextFrame.origin.y+sizeDrawn.height-cornerWidth/2.0)



//                };
//                CGContextStrokeLineSegments(context, points, 8);




//                CGContextDrawImage(context, CGRectMake(pdfPageTextFrame.origin.x-cornerWidth/2.0, pdfPageTextFrame.origin.y-cornerWidth/2.0, cornerWidth, cornerWidth), [annotationCornerImage CGImage]); // left up
//
//                CGContextDrawImage(context, CGRectMake(pdfPageTextFrame.origin.x-cornerWidth/2.0, pdfPageTextFrame.origin.y+sizeDrawn.height-cornerWidth/2.0, cornerWidth, cornerWidth), [annotationCornerImage CGImage]); // left down
//
//                CGContextDrawImage(context, CGRectMake(pdfPageTextFrame.origin.x+sizeDrawn.width-cornerWidth/2.0, pdfPageTextFrame.origin.y-cornerWidth/2.0, cornerWidth, cornerWidth), [annotationCornerImage CGImage]); // right up
//
//                CGContextDrawImage(context, CGRectMake(pdfPageTextFrame.origin.x+sizeDrawn.width-cornerWidth/2.0, pdfPageTextFrame.origin.y+sizeDrawn.height-cornerWidth/2.0, cornerWidth, cornerWidth), [annotationCornerImage CGImage]); // right down




//
//
//                CGContextAddArc(context, pdfPageTextFrame.origin.x-cornerWidth/2.0, pdfPageTextFrame.origin.y+sizeDrawn.height-cornerWidth/2.0,  cornerWidth, 0, M_PI*2, 1);
//
//                CGContextDrawLinearGradient(context, gradient, CGPointMake(pdfPageTextFrame.origin.x-cornerWidth/2.0, pdfPageTextFrame.origin.y+sizeDrawn.height-cornerWidth/2.0-cornerWidth*2), CGPointMake(pdfPageTextFrame.origin.x-cornerWidth/2.0, pdfPageTextFrame.origin.y-cornerWidth/2.0+cornerWidth*2), kCGGradientDrawsAfterEndLocation);
//



//
//
//
//
//    for (UInt32 i=1; i<=[self numberOfPages]; i++) {
//        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//
//        CGPDFPageRef currentPage = CGPDFDocumentGetPage(CGPDFDoc, i);
//        CGRect pageRect = CGPDFPageGetBoxRect(currentPage, kCGPDFMediaBox);
//        UIGraphicsBeginPDFPageWithInfo(pageRect, nil);
//
//        CGContextRef currentContext = UIGraphicsGetCurrentContext();
//
//        //        NSLog(@" pageRect = %@", NSStringFromCGRect(pageRect));
//
//        CGContextTranslateCTM(currentContext, 0, pageRect.size.height);
//        CGContextScaleCTM(currentContext, 1.0, -1.0);
//
//        CGContextDrawPDFPage (currentContext, currentPage);
//
//        if (pageToAnnotate.pageNumber==i) {
//            CGContextScaleCTM(currentContext, 1.0, -1.0);
//            CGContextTranslateCTM(currentContext, 0, -pageRect.size.height);
//            NSLog(@" MUST ANNOTATE THIS PAGE, %ld", i);
//
//
//            CGFloat red, green, blue, alpha;
//            BOOL canBeConverted = [color getRed:&red green:&green blue:&blue alpha:&alpha];
//            //            NSLog(@" CAN BE = %d red = %f, green = %f, blue = %f", canBeConverted, red, green, blue);
//
//            if (canBeConverted==YES) {
//                CGContextSetRGBFillColor(currentContext, red, green, blue, alpha);
//            } else {
//                CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);
//            }
//
//
//            CGPoint positionInCurrentPage = [[self getPDFPageViewWithNumber:i] convertPoint:positionInMainContainer fromView:mainContentView];
//            CGSize sizeDrawn;
//            sizeDrawn = [text drawInRect:CGRectMake(positionInCurrentPage.x, positionInCurrentPage.y, frame.size.width/self.zoomScale, frame.size.height/self.zoomScale) withFont:zoomDependingFont lineBreakMode:NSLineBreakByWordWrapping];
//
//        }
//        [pool drain];
//    }
//
//
//
//
//



//annotations:


//for test reasons
//-(void) annotateWithText:(NSString*) text inFrame:(CGRect) frame withFont:(UIFont *) font withColor:(UIColor *) color withPointSize:(CGFloat) pointSize {
//
//    CGPoint positionInMainContainer = [self convertPoint:frame.origin toView:mainContentView];
//    PDFPageView *pageToAnnotate = nil;
//
//    NSLog(@" positionInMainContainer = %@", NSStringFromCGPoint(positionInMainContainer));
//
//    for (PDFPageView *currentPage in pagesArray) {
//
//        if (CGRectContainsPoint(currentPage.frame, positionInMainContainer) ) {
//            NSLog(@" FOUND PAGE = %d", currentPage.pageNumber);
//            pageToAnnotate = currentPage;
//            break;
//        }
//    }
//
//
//    NSString *tempFileName = @"tempFileName.pdf";
//    NSString *filePath = [[[GlobalDocumentTracker sharedInstance] documentsDirectoryPath] stringByAppendingPathComponent:tempFileName];
//
//    CGPDFDocumentRef CGPDFDoc = [self getCurrentCGPDFDocument];
//    CGPDFPageRef fistPage = CGPDFDocumentGetPage(CGPDFDoc, 0);
//    CGRect pageRect = CGPDFPageGetBoxRect(fistPage, kCGPDFMediaBox);
//
//    UIFont *zoomDependingFont = [UIFont fontWithName:font.fontName size:(font.pointSize/self.zoomScale)];
//
//    UIGraphicsBeginPDFContextToFile(filePath, CGRectMake(0, 0, pageRect.size.width, pageRect.size.height), nil);
//
//    for (UInt32 i=1; i<=[self numberOfPages]; i++) {
//        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//
//        CGPDFPageRef currentPage = CGPDFDocumentGetPage(CGPDFDoc, i);
//        CGRect pageRect = CGPDFPageGetBoxRect(currentPage, kCGPDFMediaBox);
//        UIGraphicsBeginPDFPageWithInfo(pageRect, nil);
//
//        CGContextRef currentContext = UIGraphicsGetCurrentContext();
//
////        NSLog(@" pageRect = %@", NSStringFromCGRect(pageRect));
//
//        CGContextTranslateCTM(currentContext, 0, pageRect.size.height);
//        CGContextScaleCTM(currentContext, 1.0, -1.0);
//
//        CGContextDrawPDFPage (currentContext, currentPage);
//
//        if (pageToAnnotate.pageNumber==i) {
//            CGContextScaleCTM(currentContext, 1.0, -1.0);
//            CGContextTranslateCTM(currentContext, 0, -pageRect.size.height);
//            NSLog(@" MUST ANNOTATE THIS PAGE, %ld", i);
//
//
//            CGFloat red, green, blue, alpha;
//            BOOL canBeConverted = [color getRed:&red green:&green blue:&blue alpha:&alpha];
////            NSLog(@" CAN BE = %d red = %f, green = %f, blue = %f", canBeConverted, red, green, blue);
//
//            if (canBeConverted==YES) {
//                CGContextSetRGBFillColor(currentContext, red, green, blue, alpha);
//            } else {
//                CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);
//            }
//
//
//            CGPoint positionInCurrentPage = [[self getPDFPageViewWithNumber:i] convertPoint:positionInMainContainer fromView:mainContentView];
//            CGSize sizeDrawn;
//            sizeDrawn = [text drawInRect:CGRectMake(positionInCurrentPage.x, positionInCurrentPage.y, frame.size.width/self.zoomScale, frame.size.height/self.zoomScale) withFont:zoomDependingFont lineBreakMode:NSLineBreakByWordWrapping];
//
//        }
//        [pool drain];
//    }
//
//    NSLog(@" FINISHED");
//    UIGraphicsEndPDFContext();
//}







//
//
//-(void) annotateWithText:(NSString*) text inPosition:(CGPoint) point {
//
//    NSLog(@" annotateWithText - %@ ", text);
//    CGPoint positionInMainContainer = [self convertPoint:point toView:mainContentView];
////    NSLog(@" position in Scroll view = %@", NSStringFromCGPoint(point) );
////    NSLog(@" positionInMainContainer = %@", NSStringFromCGPoint(positionInMainContainer));
//
//
//    PDFPageView *pageToAnnotate = nil;
//    for (PDFPageView *currentPage in pagesArray) {
//
//        if (CGRectContainsPoint(currentPage.frame, positionInMainContainer) ) {
//            NSLog(@" FOUND PAGE = %d", currentPage.pageNumber);
//            pageToAnnotate = currentPage;
//            break;
//        }
//    }
//
//
//    /* working option
//     CGContextSetTextDrawingMode(context,kCGTextFill);
//     CGContextSetRGBFillColor(context, 1, 0, 0, 1);
//     const char *text = "Test Annotation.";
//     CGContextSelectFont(context, "Arial", 24, kCGEncodingMacRoman);
//     CGContextShowTextAtPoint(context, 0, 0, text, strlen(text) );
//     */
//
//
//
//    /* working option
//     UIGraphicsPushContext(context);
//
//     NSString *text = @"\
//     \
//     \
//     asend.";
//     UIFont *font = [UIFont systemFontOfSize:24];
//     CGSize pageSize = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox).size;
//
//     CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1);
//
//     CGSize sizeDrawn;
//     CGFloat actualFontSize = font.pointSize;
//     //    sizeDrawn = [text drawAtPoint:CGPointMake(0, 0) forWidth:pageSize.width withFont:font minFontSize:10.0 actualFontSize:&actualFontSize lineBreakMode:NSLineBreakByClipping baselineAdjustment:UIBaselineAdjustmentAlignCenters];
//
//     //or
//
//     sizeDrawn = [text drawInRect:CGRectMake(0, 0, 100, 150) withFont:font lineBreakMode:NSLineBreakByWordWrapping];
//
//     NSLog(@" size drawn = %@", NSStringFromCGSize(sizeDrawn) );
//     NSLog(@" pageSize = %@", NSStringFromCGSize(pageSize));
//     UIGraphicsPopContext();
//     //    */
//
//
//
//
//
//
////    UIGraphicsBeginPDFContextToFile([self getTempPDFFileName], paperSize, nil);
////
////    UIGraphicsBeginPDFPageWithInfo(paperSize, nil);
////
////    CGContextRef currentContext = UIGraphicsGetCurrentContext();
////
////    // flip context so page is right way up
////    CGContextTranslateCTM(currentContext, 0, paperSize.size.height);
////    CGContextScaleCTM(currentContext, 1.0, -1.0);
////
////    CGPDFPageRef page = CGPDFDocumentGetPage (document, 1); // grab page 1 of the PDF
////
////    CGContextDrawPDFPage (currentContext, page); // draw page 1 into graphics context
////
////    // flip context so annotations are right way up
////    CGContextScaleCTM(currentContext, 1.0, -1.0);
////    CGContextTranslateCTM(currentContext, 0, -paperSize.size.height);
////
////    [@"Example annotation" drawInRect:CGRectMake(100.0, 100.0, 200.0, 40.0) withFont:[UIFont systemFontOfSize:18.0]];
////
////    UIGraphicsEndPDFContext();
////
////    CGPDFDocumentRelease (document);
//
//
//
//
//    NSString *tempFileName = @"tempFileName.pdf";
//    NSString *filePath = [[[GlobalDocumentTracker sharedInstance] documentsDirectoryPath] stringByAppendingPathComponent:tempFileName];
//
//
//    NSURL *URL = [NSURL fileURLWithPath: [[[GlobalDocumentTracker sharedInstance] documentsDirectoryPath] stringByAppendingPathComponent:@"test.pdf"] ];
//
//    CGPDFDocumentRef CGPDFDoc = [self getCurrentCGPDFDocument]; // CGPDFDocumentCreateWithURL((CFURLRef)URL); //[self getCurrentCGPDFDocument];
//    CGPDFPageRef fistPage = CGPDFDocumentGetPage(CGPDFDoc, 0);
//    CGRect pageRect = CGPDFPageGetBoxRect(fistPage, kCGPDFMediaBox);
//
//    UIGraphicsBeginPDFContextToFile(filePath, CGRectMake(0, 0, pageRect.size.width, pageRect.size.height), nil);
//
//
////    CGSize pageSize = CGPDFPageGetBoxRect([pageToAnnotate getCGPDFPage], kCGPDFMediaBox).size;
////    UIGraphicsBeginPDFContextToFile(filePath, CGRectMake(0, 0, pageRect.size.width, pageRect.size.height), nil);
//
//
////    UInt32 tempNumber = CGPDFDocumentGetNumberOfPages(CGPDFDoc);
////    NSLog(@" tempNumber = %ld", tempNumber);
//
//
//    NSLog(@" pageToAnnotate = %d", pageToAnnotate.pageNumber);
//
//    for (UInt32 i=1; i<=[self numberOfPages]; i++) {
//
////        NSLog(@"\n\n PROCCESSIN PAGE %ld", i);
//
//        CGPDFPageRef currentPage = CGPDFDocumentGetPage(CGPDFDoc, i);
//        CGRect pageRect = CGPDFPageGetBoxRect(currentPage, kCGPDFMediaBox);
//        UIGraphicsBeginPDFPageWithInfo(pageRect, nil);
//
//        CGContextRef currentContext = UIGraphicsGetCurrentContext();
//
////        NSLog(@" pageRect = %@", NSStringFromCGRect(pageRect));
//
//        CGContextTranslateCTM(currentContext, 0, pageRect.size.height);
//        CGContextScaleCTM(currentContext, 1.0, -1.0);
//
//        CGContextDrawPDFPage (currentContext, currentPage);
//
//
//        if (/*pageToAnnotate.pageNumber==i*/i==3) {
//            CGContextScaleCTM(currentContext, 1.0, -1.0);
//            CGContextTranslateCTM(currentContext, 0, -pageRect.size.height);
//            NSLog(@" MUST ANNOTATE THIS PAGE ");
//            //will annote here
//
//
//
//            NSString *text = @"Example annotation Example annotation end.";
//            UIFont *font = [UIFont systemFontOfSize:24];
//            CGSize pageSize = pageRect.size;
//
//            CGContextSetRGBFillColor(currentContext, 1.0, 0.0, 0.0, 1);
//
//            CGSize sizeDrawn;
//            CGFloat actualFontSize = font.pointSize;
//            sizeDrawn = [text drawAtPoint:CGPointMake(0, 0) forWidth:pageSize.width withFont:font minFontSize:10.0 actualFontSize:&actualFontSize lineBreakMode:NSLineBreakByClipping baselineAdjustment:UIBaselineAdjustmentAlignCenters];
//            NSLog(@" size drawn = %@", NSStringFromCGSize(sizeDrawn) );
//        }
//    }
//
//    UIGraphicsEndPDFContext();
//}
//




//========================================================================================================


//    PDFPageView *pageView = [self getPDFPageViewWithNumber:pageNum];
//    CGRect pageRectInScrollView = [pageView.superview convertRect:pageView.frame toView:self];
//
//    //scale
//    CGFloat scaleFactor = MIN(rect.size.width/pageRectInScrollView.size.width, rect.size.height/pageRectInScrollView.size.height);
//    NSLog(@" sssscaleFactor=%f",scaleFactor);
//    [self setZoomScale:scaleFactor*self.zoomScale animated:animated];
//
//    //move
//    float offsetToGoTo = (pageStartPositions[pageNum-1] * self.zoomScale);
//	[self setContentOffset:CGPointMake(self.contentOffset.x, offsetToGoTo) animated:animated];




//                        firstPoint = CGPointMake( (firstPoint.x-self.superview.frame.origin.x)*scaleFactor, (firstPoint.y-self.superview.frame.origin.y) *scaleFactor );
//                        firstPoint = CGPointMake( (firstPoint.x-1.0)*scaleFactor, (firstPoint.y-1.0) *scaleFactor );
//                        firstPoint = [parentDoc convertPoint:firstPoint toView:self];
//                        firstPoint = CGPointMake(firstPoint.x/parentDoc.zoomScale, firstPoint.y/parentDoc.zoomScale);



//                        point = [scrollViewDoc convertPoint:point toView:self];
//                            point = CGPointMake( (point.x-self.superview.frame.origin.x)*scaleFactor, (point.y-self.superview.frame.origin.y)*scaleFactor );
//                            point = CGPointMake( (point.x-1.0)*scaleFactor, (point.y-1.0)*scaleFactor );
//                            point = [parentDoc convertPoint:point toView:self];
//                            point = CGPointMake(point.x/parentDoc.zoomScale, point.y/parentDoc.zoomScale);


//                CGFloat scaleFactor = MAX(self.bounds.size.width/parentDoc.frame.size.width, self.bounds.size.height/parentDoc.frame.size.height);