//
//  PDFDocumentView2.h
//  PDFPreview
//
//  Created by s11 s11 on 10/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>





#define COLOR_RED_VALUE_KEY         @"ColorRedValue"
#define COLOR_GREEN_VALUE_KEY       @"ColorGreenValue"
#define COLOR_BLUE_VALUE_KEY        @"ColorBlueValue"
#define COLOR_ALPHA_VALUE_KEY       @"ColorAlphaValue"




#define PDF_DOCUMENTS_ANNOTATION_COLLECTION @"PDFDocAnnotations"

//#define ANNOTATIONS_FOR_DOCUMENT_FILEPATH @"AnnotDocFilePath"
#define ANNOTATION_TEXT_ANNOTATION_ARRAY    @"TextAnnotationArray"
#define ANNOTATION_DRAW_ANNOTATION_ARRAY    @"DrawAnnotationArray"


//text annotations
#define TEXT_ANNOTATION_TEXT_STRING_KEY                     @"TATextString"
#define TEXT_ANNOTATION_SCROLLVIEW_TEXT_FRAME_STRING_KEY    @"TAScrollViewFrameString"
#define TEXT_ANNOTATION_PAGE_NUMBER_KEY                     @"TAPageNumber"             //starts with 1
#define TEXT_ANNOTATION_CGPDFPAGE_TEXT_FRAME_STRING_KEY     @"TACGPDFPageFrameString"
#define TEXT_ANNOTATION_FONTNAME_STRING_KEY                 @"TAFontnameString"
#define TEXT_ANNOTATION_COLOR_RGB_DICT_KEY                  @"TAColorRGBDict"
#define TEXT_ANNOTATION_POINTSIZE_NUMBER_KEY                @"TAPointSizeNumber"


//draw annotations
#define DRAW_ANNOTATION_PAGE_NUMBER_KEY                 @"DAPageNumber"
#define DRAW_ANNOTATION_CURVES_ARRAY_KEY                @"DACurvesArray"
#define DRAW_ANNOTATIONS_DRAW_MODE                      @"DADrawMode"

//mode
#define DRAW_MODE_SOLID_DRAWING                         @"DMSolidDrawing"
#define DRAW_MODE_MARK_DRAWING                          @"DMMarkDrawing"


#define CURVE_DESCRIPTION_POINTS_ARRAY                @"CAPointsArray"
#define CURVE_DESCRIPTION_WIDTH_VALUE                 @"CAWidthValue"
#define CURVE_DESCRIPTION_COLOR_RGB_DICT              @"CAColorRGBDict"
//#define CURVE_DESCRIPTION_CURVE_PAGE_NUMBER           @"CACurvePageNumber"


@class PDFDocumentScrollView;

@protocol PDFDocumentScrollViewDelegate 

-(void) pdfDocumentScrollView:(PDFDocumentScrollView *) pdfDocumentScrollView didScrollToPage:(NSInteger) currentPage;
-(void) pdfDocumentScrollView:(PDFDocumentScrollView *) pdfDocumentScrollView didZoomToScale:(float) scale withView:(UIView *) zoomedView; //fucking added+++++++++++++++++++


@end



@interface PDFPageView : UIView {
    
    
    //ANNOTATIONS =======================================================================
    
    NSMutableArray *textAnnotations;
    BOOL restrictArrayEnumeration;
    UIImage *annotationCornerImage;
    
    NSMutableArray *drawAnnotations;

    //DRAWING===========================
//    UIBezierPath *bezierPath;
    CGPoint firstPoint, secondPoint, currentPoint;

    //===================================================================================
    
    
    
    CGPDFPageRef pdfPage;
	int pageNumber;
	volatile BOOL willDeallocate, allowViewUpdate; // prevent updating when about to release
	
	volatile NSRange rangeOfPagesToBeUpdated;
	
    volatile id parentDocument;
    NSString *deviceModel;
	
	//	volatile BOOL testFlag;
}

@property (retain) volatile id parentDocument;
@property (assign) int pageNumber;
@property (assign) volatile BOOL allowViewUpdate;


//===================================================================================
//draw
-(void) addDrawAnnotationDict:(NSDictionary*) drawAnnotDict;

//text
-(void) addTextAnnotationsFromArray:(NSArray *) array;
-(void) addTextAnnotationDictionary:(NSDictionary*) dict;
-(void) replaceTextAnnotationsWithArray:(NSArray *) array;
-(void) removeFromUserDefaultsTextAnnotationDict:(NSDictionary *) dictToRemove;
-(void) removeAllTextAnnotations;
//===================================================================================

-(void) setCGPDFPage:(CGPDFPageRef) CGPDFPage;
-(CGPDFPageRef) getCGPDFPage;
-(id) initWithPosition:(CGPoint) position andPage:(CGPDFPageRef) PDFPage;
+ (Class) layerClass;
-(void) drawRect:(CGRect)rect;

-(BOOL) isThisPageInUpdateRange;

- (NSString *) IphoneModel;


-(void) changeTileSize;


@end







#define ANNOTATION_WAS_REMOVED_NOTIFICATION @"AnnotationRemovedNotif"

@interface PDFDocumentScrollView : UIScrollView <UIScrollViewDelegate> {

    
    //ANNOTATIONS =======================================================================
    
    BOOL shouldDrawRuntimeAnnotations;
    
//    NSMutableArray *documentAnnotationsArray;
    BOOL textAnnotationsRemoveMode;
    
    //DRAWING
    BOOL drawingModeON;
    UIColor *drawingColor;
    CGFloat drawingLineWidth;

    NSMutableArray *drawingAnnotationCurves;
    BOOL shouldCenterTheContent;
    BOOL drawAnnotationsRemoveMode;
    
    //===================================================================================
    
    NSString *docPath;
    

    id <PDFDocumentScrollViewDelegate> PDFDocDelegate;
	
    
    BOOL lockHorizontal;
    CGPoint prevOffset;
    
    
	volatile NSRange rangeOfPagesToBeUpdated;	
	float *pageStartPositions;
	UIView *mainContentView;
	
	
	NSString *deviceModel;
	
	UInt32 numberOfPages;
	CGPDFDocumentRef pdfDocument;
	NSMutableArray *pagesArray;
	UInt32 visiblePage;
    
    volatile BOOL willDeallocateNow;
    
    // temp---------------
    volatile id parentObject;
    
    BOOL isScrollingNow;
    
    
    UIBezierPath *temp_bezier;
    
}



@property (assign) BOOL drawAnnotationsRemoveMode;

@property (assign) BOOL shouldCenterTheContent;

@property (assign) BOOL shouldDrawRuntimeAnnotations;
@property (assign) BOOL drawingModeON;
@property (retain) UIColor *drawingColor;
@property (assign) CGFloat drawingLineWidth;


@property (retain) NSString *docPath;

@property (retain) id <PDFDocumentScrollViewDelegate> PDFDocDelegate;

@property (retain)  volatile id parentObject;
@property (readonly) volatile NSRange rangeOfPagesToBeUpdated;
@property (readonly) UInt32 numberOfPages;
@property (assign) volatile BOOL willDeallocateNow;
@property (assign)  BOOL lockHorizontal;


//ANNOTATION=====================================================================================================================
//drawing
-(BOOL) drawingModeON;
-(void) setDrawingModeON:(BOOL)value;
-(PDFPageView*) pageViewThatContainsPosition:(CGPoint) position; //position from self
-(void) addDrawAnnotationsWithDict:(NSDictionary*) drawAnnotDict;
-(void) removeFromUserDefaultsDrawAnnotationDict:(NSDictionary*) dictToRemove;
-(void) updateUserDefaultsWithDrawAnnotationDict:(NSDictionary *) drawAnnot;



//TEXT
-(BOOL) textAnnotationsRemoveMode;
-(void) setTextAnnotationsRemoveMode:(BOOL) value;
-(void) removeFromUserDefaultsTextAnnotationDict:(NSDictionary *) dictToRemove;


-(void) addTextAnnotationWithText:(NSString *) text insideScrollViewFrame: (CGRect) frame withFont:(UIFont *) font withColor:(UIColor *) color withPointSize:(CGFloat) pointSize;
-(void) annotateWithText:(NSString*) text inFrame:(CGRect) frame withFont:(UIFont *) font withColor:(UIColor *) color withPointSize:(CGFloat) pointSize;
//===============================================================================================================================

-(void) showPageViewWithNumber:(NSInteger) pageNum toFitInScrollViewRect:(CGRect) rect animated:(BOOL) animated outputPageRect:(CGRect*) pageRect;
-(void) setMainContentViewToZeroPosition;

//-(void) showPageViewWithNumber:(NSInteger) pageNum toFitInScrollViewRect:(CGRect) rect animated:(BOOL) animated;
-(void) goNextPage;
-(void) goPreviousPage;

-(PDFPageView *) getPDFPageViewWithNumber:(NSInteger) pageNumber;
-(void) showPoint:(CGPoint) position onThePageWithNumber:(NSInteger) pageNumber;
-(PDFPageView *) getCurrentPageViewDisplayed;
-(CGPDFPageRef) getCurrentCGPDFPageDisplayed;

-(CGPDFDocumentRef) getCurrentCGPDFDocument;
-(void) centerTheContent;

-(void) goToPage:(NSUInteger) pageNumber animated:(BOOL) animated;
-(int) getCurrentPageNumberDisplayed;

-(CGPDFDocumentRef) createPDFDocumentWithFilePath:(NSString *) filePath;
-(CGPDFPageRef) getPDFPageWithNumber:(UInt32) pageNumber;
-(void) setCGPDFDocument:(CGPDFDocumentRef) CGPDFDoc;

//- (id)initWithFrame:(CGRect)theFrame andDocument:(CGPDFDocumentRef) PDFDocument;
- (id)initWithFrame:(CGRect)theFrame andDocument:(CGPDFDocumentRef) PDFDocument documentPath:(NSString *) documentPath;




-(NSRange) currentRangeDisplayedInScrollView;
-(void) updateCurrentRangeFromRange:(NSRange) pagesRange;
- (NSString *) IphoneModel;

- (void)updateAllThis;

@end
