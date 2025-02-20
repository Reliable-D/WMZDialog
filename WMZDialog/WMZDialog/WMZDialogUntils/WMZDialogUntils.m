//
//  WMZDialogUntils.m
//  WMZDialog
//
//  Created by wmz on 2019/6/5.
//  Copyright © 2019年 wmz. All rights reserved.
//

#import "WMZDialogUntils.h"

@implementation WMZDialogUntils

+ (UIViewController *)getCurrentVC{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    return currentVC;
}

+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC{
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        rootVC = [rootVC presentedViewController];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        currentVC = rootVC;
    }
    return currentVC;
}

+ (CGSize)sizeForTextView:(CGSize)constraint
                     text:(NSString *)text
                     font:(UIFont*)font{
    CGRect rect = CGRectZero;
    if([text isKindOfClass:NSAttributedString.class]){
        rect = [(NSAttributedString*)text boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    }else if([text isKindOfClass:NSString.class] && text.length){
        rect = [text boundingRectWithSize:constraint
                                  options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                               attributes:@{NSFontAttributeName: font}
                                  context:nil];
    }
    return rect.size;
}

+ (void)setCornerView:(UIView *)view
                radio:(CGSize)radio
           rectCorner:(UIRectCorner)rectCorner{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:rectCorner cornerRadii:radio];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

+ (NSBundle*)getMainBundle{
    NSBundle* bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[WMZDialogUntils class]] pathForResource:@"WMZDialog" ofType:@"bundle"]];
    return bundle;
}

@end

static NSString *WMZDialogPopLayerKey = @"WMZDialogPopLayerKey";
static NSString *WMZDialogPopMaskName = @"WMZDialogPopMaskName";
@implementation UIView(DialogPop)
-(void)addArrowBorderAt:(DiaDirection)direction
                 offset:(CGFloat)offset
             rectCorner:(DialogRectCorner)corner
                  width:(CGFloat)width
                 height:(CGFloat)height
           cornerRadius:(CGFloat)cornerRadius
            borderWidth:(CGFloat)borderWidth
            borderColor:(UIColor *)borderColor
             angleRadio:(CGFloat)angleRadio{
    [self removeWMZDialogPop];
    CGFloat normalCornerRadius = cornerRadius;
    //只有一个mask层
    CAShapeLayer *mask = [[CAShapeLayer alloc] init];
    mask.name = WMZDialogPopMaskName;
    mask.frame = self.bounds;
    self.layer.mask = mask;
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    CGFloat minX = 0, minY = 0, maxX = self.frame.size.width, maxY = self.frame.size.height;
    CGFloat bgWith = angleRadio*2.5;
    if (direction == directionUp) {
        minY = height;
    }else if (direction == directionright){
        maxX -= height;
    }else if (direction == directionLeft){
        minX += height;
    }else if (direction == directionDowm){
        maxY -= height;
    }
    //上边
    [path moveToPoint:CGPointMake(minX+cornerRadius, minY)];
    if (direction == directionUp) {
        [path addLineToPoint:CGPointMake(offset-width/2, minY)];
        if (angleRadio) {
            [path addArcWithCenter:CGPointMake(offset, minY - bgWith) radius:angleRadio startAngle:M_PI_4 * 5 endAngle:M_PI_4*7 clockwise:YES];
        }else{
            [path addLineToPoint:CGPointMake(offset, 2)];
        }
        [path addLineToPoint:CGPointMake(offset+width/2, minY)];
    }
    [path addLineToPoint:CGPointMake(maxX-cornerRadius, minY)];
    //右上角
    if (cornerRadius>0) {
        if (!(corner&DialogRectCornerTopRight)) {
            cornerRadius = 0;
        }
         [path addArcWithCenter:CGPointMake(maxX-cornerRadius, minY+cornerRadius) radius:cornerRadius startAngle:-M_PI_2 endAngle:0 clockwise:YES];
    }
    cornerRadius =  normalCornerRadius;
    //右边
    if (direction == directionright) {
        [path addLineToPoint:CGPointMake(maxX, offset-width/2)];
        if (angleRadio) {
            [path addArcWithCenter:CGPointMake(maxX + height, offset) radius:angleRadio startAngle:M_PI_4*3 endAngle:M_PI_4*5 clockwise:YES];
        }else{
            [path addLineToPoint:CGPointMake(maxX+height, offset)];
        }
        [path addLineToPoint:CGPointMake(maxX, offset+width/2)];
    }
    [path addLineToPoint:CGPointMake(maxX, maxY-cornerRadius)];
    //右下角
    if (cornerRadius>0) {
        if (!(corner&DialogRectCornerBottomRight)) {
            cornerRadius = 0;
        }
        [path addArcWithCenter:CGPointMake(maxX-cornerRadius, maxY-cornerRadius) radius:cornerRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    }
    cornerRadius =  normalCornerRadius;
    //下边
    if (direction == directionDowm) {
        [path addLineToPoint:CGPointMake(offset-width/2, maxY)];
        if (angleRadio) {
            [path addArcWithCenter:CGPointMake(offset, maxY + bgWith) radius:angleRadio startAngle:M_PI_4*3 endAngle:M_PI_4 clockwise:NO];
        }else{
            [path addLineToPoint:CGPointMake(offset, maxY+height)];
        }
        [path addLineToPoint:CGPointMake(offset+width/2, maxY)];
    }
    [path addLineToPoint:CGPointMake(minX+cornerRadius, maxY)];
    //左下角
    if (cornerRadius>0) {
        if (!(corner&DialogRectCornerBottomLeft)) {
            cornerRadius = 0;
        }
        [path addArcWithCenter:CGPointMake(minX+cornerRadius, maxY-cornerRadius) radius:cornerRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    }
    cornerRadius =  normalCornerRadius;
    //右边
    if (direction == directionLeft) {
        [path addLineToPoint:CGPointMake(minX, offset-width/2)];
        if (angleRadio) {
            [path addArcWithCenter:CGPointMake(minX - height, offset) radius:angleRadio startAngle:M_PI_4*3 endAngle:M_PI_4*5 clockwise:YES];
        }else{
            [path addLineToPoint:CGPointMake(minX-height, offset)];
        }
        [path addLineToPoint:CGPointMake(minX, offset+width/2)];
    }
    [path addLineToPoint:CGPointMake(minX, minY+cornerRadius)];
    //右下角
    if (cornerRadius>0) {
        if (!(corner&DialogRectCornerTopLeft)) {
            cornerRadius = 0;
        }
        [path addArcWithCenter:CGPointMake(minX+cornerRadius, minY+cornerRadius) radius:cornerRadius startAngle:M_PI endAngle:M_PI_2*3 clockwise:YES];
    }
    cornerRadius =  normalCornerRadius;
    mask.path = [path CGPath];
    if (borderWidth>0) {
        CAShapeLayer *border = [[CAShapeLayer alloc] init];
        border.path = [path CGPath];
        border.strokeColor = borderColor.CGColor;
        border.lineWidth = borderWidth*2;
        border.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:border];
        
        [self markWMZDialogPop:border];
    }
    
}

-(void)markWMZDialogPop:(CALayer *)layer{
    objc_setAssociatedObject(self, &WMZDialogPopLayerKey, layer, OBJC_ASSOCIATION_RETAIN);
}
 
-(void)removeWMZDialogPop{
    if ([self.layer.mask.name isEqualToString:WMZDialogPopMaskName]) {
        self.layer.mask = nil;
    }
    CAShapeLayer *oldLayer = objc_getAssociatedObject(self, &WMZDialogPopLayerKey);
    if (oldLayer) [oldLayer removeFromSuperlayer];
}

@end

@implementation WMZDialogTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self = [super initWithFrame:frame style:style]) {
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.estimatedRowHeight = 100;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            self.estimatedSectionFooterHeight = 0.01;
            self.estimatedSectionHeaderHeight = 0.01;
        }
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 150000
         if (@available(iOS 15.0, *)) {
             self.sectionHeaderTopPadding = 0;
         }
        #endif
        self.scrollsToTop = NO;
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    if (self.wOpenScrollClose&&
        self.contentOffset.y <= 0 &&
        [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        if (self.wCardPresent) {
            UIPanGestureRecognizer *pan = (UIPanGestureRecognizer*)otherGestureRecognizer;
            CGPoint translation = [pan translationInView:pan.view];
            CGFloat absX = fabs(translation.x);
            CGFloat absY = fabs(translation.y);
            if (MAX(absX, absY) >= 1){  /// 设置滑动有效距离
                if (absY > absX) return !(translation.y < 0);
            }
        }
        return YES;
    }
    return NO;
}

@end

@implementation WMZDialogButton

- (void)setHighlighted:(BOOL)highlighted{}

@end

@implementation WMZDialogShareView

- (instancetype)initWithText:(NSString*)text
                       image:(NSString*)image
                       block:(ShareViewSelect)block
                         tag:(NSInteger)tag{
    if (self = [super init]) {
        self.block = block;
        self.backgroundColor = UIColor.clearColor;
        self.layer.masksToBounds = YES;
        self.userInteractionEnabled = YES;
        self.tag = tag;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageAction:)];
        [self addGestureRecognizer:tap];
        
        [self addSubview:self.imageIV];
        self.imageIV.image = [UIImage imageNamed:image];
        
        [self addSubview:self.titleLB];
        self.titleLB.text = text;
    }
    return self;
}

- (UIImageView *)imageIV{
    if (!_imageIV) {
        _imageIV = [UIImageView new];
        _imageIV.contentMode = UIViewContentModeScaleAspectFill;
        _imageIV.layer.masksToBounds = YES;
    }
    return _imageIV;
}

- (UILabel *)titleLB{
    if (!_titleLB) {
        _titleLB = [UILabel new];
        _titleLB.textAlignment = NSTextAlignmentCenter;
        _titleLB.font = [UIFont systemFontOfSize:13.0f];
        _titleLB.userInteractionEnabled = NO;
    }
    return _titleLB;
}

- (void)imageAction:(UITapGestureRecognizer*)tap{
    if (self.block) self.block(self.tag,self.model?:self.titleLB.text);
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!self.changeFrame) {
        CGFloat percentImage = 0.5;
        self.imageIV.frame = CGRectMake((self.frame.size.width - self.frame.size.height * percentImage) / 2,5, self.frame.size.height * percentImage, self.frame.size.height * percentImage);
        self.imageIV.layer.cornerRadius = (self.frame.size.height * 0.5) / 2;
        self.titleLB.frame = CGRectMake(10 * 0.5, CGRectGetMaxY(self.imageIV.frame) + 5, self.frame.size.width - 10, self.frame.size.height * (1 - percentImage) - 10 * 2);
    }
}

@end

@class WMZCalanderModel;
//24节气只有(1901 - 2050)之间为准确的节气
const  int START_YEAR =1901;
const  int END_YEAR  =2050;
static int32_t gLunarHolDay[]={
0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,  //1901

0X96,0XA4, 0X96,0X96, 0X97,0X87, 0X79,0X79, 0X79,0X69, 0X78,0X78,  //1902

0X96,0XA5, 0X87,0X96, 0X87,0X87, 0X79,0X69, 0X69,0X69, 0X78,0X78,  //1903

0X86,0XA5, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X78,0X87,  //1904

0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,  //1905

0X96,0XA4, 0X96,0X96, 0X97,0X97, 0X79,0X79, 0X79,0X69, 0X78,0X78,  //1906

0X96,0XA5, 0X87,0X96, 0X87,0X87, 0X79,0X69, 0X69,0X69, 0X78,0X78,  //1907

0X86,0XA5, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,  //1908

0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,  //1909

0X96,0XA4, 0X96,0X96, 0X97,0X97, 0X79,0X79, 0X79,0X69, 0X78,0X78,  //1910

0X96,0XA5, 0X87,0X96, 0X87,0X87, 0X79,0X69, 0X69,0X69, 0X78,0X78,  //1911

0X86,0XA5, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,  //1912

0X95,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,  //1913

0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X79,0X79, 0X79,0X69, 0X78,0X78,  //1914

0X96,0XA5, 0X97,0X96, 0X97,0X87, 0X79,0X79, 0X69,0X69, 0X78,0X78,  //1915

0X96,0XA5, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X77,0X87,  //1916

0X95,0XB4, 0X96,0XA6, 0X96,0X97, 0X78,0X79, 0X78,0X69, 0X78,0X87,  //1917

0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X79,0X79, 0X79,0X69, 0X78,0X77,  //1918

0X96,0XA5, 0X97,0X96, 0X97,0X87, 0X79,0X79, 0X69,0X69, 0X78,0X78,  //1919

0X96,0XA5, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X77,0X87,  //1920

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X78,0X79, 0X78,0X69, 0X78,0X87,  //1921

0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X79,0X79, 0X79,0X69, 0X78,0X77,  //1922

0X96,0XA4, 0X96,0X96, 0X97,0X87, 0X79,0X79, 0X69,0X69, 0X78,0X78,  //1923

0X96,0XA5, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X77,0X87,  //1924

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X78,0X79, 0X78,0X69, 0X78,0X87,  //1925

0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,  //1926

0X96,0XA4, 0X96,0X96, 0X97,0X87, 0X79,0X79, 0X79,0X69, 0X78,0X78,  //1927

0X96,0XA5, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,  //1928

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X77,0X87,  //1929

0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,  //1930

0X96,0XA4, 0X96,0X96, 0X97,0X87, 0X79,0X79, 0X79,0X69, 0X78,0X78,  //1931

0X96,0XA5, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,  //1932

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,  //1933

0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,  //1934

0X96,0XA4, 0X96,0X96, 0X97,0X97, 0X79,0X79, 0X79,0X69, 0X78,0X78,  //1935

0X96,0XA5, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,  //1936

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,  //1937

0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,  //1938

0X96,0XA4, 0X96,0X96, 0X97,0X97, 0X79,0X79, 0X79,0X69, 0X78,0X78,  //1939

0X96,0XA5, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,  //1940

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,  //1941

0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,  //1942

0X96,0XA4, 0X96,0X96, 0X97,0X97, 0X79,0X79, 0X79,0X69, 0X78,0X78,  //1943

0X96,0XA5, 0X96,0XA5, 0XA6,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,  //1944

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X77,0X87,  //1945

0X95,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X78,0X69, 0X78,0X77,  //1946

0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X79,0X79, 0X79,0X69, 0X78,0X78,  //1947

0X96,0XA5, 0XA6,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,  //1948

0XA5,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X79, 0X78,0X79, 0X77,0X87,  //1949

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X78,0X79, 0X78,0X69, 0X78,0X77,  //1950

0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X79,0X79, 0X79,0X69, 0X78,0X78,  //1951

0X96,0XA5, 0XA6,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,  //1952

0XA5,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X77,0X87,  //1953

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X78,0X79, 0X78,0X68, 0X78,0X87,  //1954

0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,  //1955

0X96,0XA5, 0XA5,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,  //1956

0XA5,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X77,0X87,  //1957

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,  //1958

0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,  //1959

0X96,0XA4, 0XA5,0XA5, 0XA6,0X96, 0X88,0X88, 0X88,0X78, 0X87,0X87,  //1960

0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,  //1961

0X96,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,  //1962

0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,  //1963

0X96,0XA4, 0XA5,0XA5, 0XA6,0X96, 0X88,0X88, 0X88,0X78, 0X87,0X87,  //1964

0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,  //1965

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,  //1966

0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,  //1967

0X96,0XA4, 0XA5,0XA5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,  //1968

0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,  //1969

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,  //1970

0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X79,0X69, 0X78,0X77,  //1971

0X96,0XA4, 0XA5,0XA5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,  //1972

0XA5,0XB5, 0X96,0XA5, 0XA6,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,  //1973

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,  //1974

0X96,0XB4, 0X96,0XA6, 0X97,0X97, 0X78,0X79, 0X78,0X69, 0X78,0X77,  //1975

0X96,0XA4, 0XA5,0XB5, 0XA6,0XA6, 0X88,0X89, 0X88,0X78, 0X87,0X87,  //1976

0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,  //1977

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X78,0X87,  //1978

0X96,0XB4, 0X96,0XA6, 0X96,0X97, 0X78,0X79, 0X78,0X69, 0X78,0X77,  //1979

0X96,0XA4, 0XA5,0XB5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,  //1980

0XA5,0XB4, 0X96,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X77,0X87,  //1981

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X77,0X87,  //1982

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X78,0X79, 0X78,0X69, 0X78,0X77,  //1983

0X96,0XB4, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X87,  //1984

0XA5,0XB4, 0XA6,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,  //1985

0XA5,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X77,0X87,  //1986

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X79, 0X78,0X69, 0X78,0X87,  //1987

0X96,0XB4, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X86,  //1988

0XA5,0XB4, 0XA5,0XA5, 0XA6,0X96, 0X88,0X88, 0X88,0X78, 0X87,0X87,  //1989

0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X79, 0X77,0X87,  //1990

0X95,0XB4, 0X96,0XA5, 0X86,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,  //1991

0X96,0XB4, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X86,  //1992

0XA5,0XB3, 0XA5,0XA5, 0XA6,0X96, 0X88,0X88, 0X88,0X78, 0X87,0X87,  //1993

0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,  //1994

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X76, 0X78,0X69, 0X78,0X87,  //1995

0X96,0XB4, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X86,  //1996

0XA5,0XB3, 0XA5,0XA5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,  //1997

0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,  //1998

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,  //1999

0X96,0XB4, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X86,  //2000

0XA5,0XB3, 0XA5,0XA5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,  //2001

0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,  //2002

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,  //2003

0X96,0XB4, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X86,  //2004

0XA5,0XB3, 0XA5,0XA5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,  //2005

0XA5,0XB4, 0X96,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,  //2006

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X69, 0X78,0X87,  //2007

0X96,0XB4, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X87,0X78, 0X87,0X86,  //2008

0XA5,0XB3, 0XA5,0XB5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,  //2009

0XA5,0XB4, 0X96,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,  //2010

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X78,0X87,  //2011

0X96,0XB4, 0XA5,0XB5, 0XA5,0XA6, 0X87,0X88, 0X87,0X78, 0X87,0X86,  //2012

0XA5,0XB3, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X87,  //2013

0XA5,0XB4, 0X96,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,  //2014

0X95,0XB4, 0X96,0XA5, 0X96,0X97, 0X88,0X78, 0X78,0X79, 0X77,0X87,  //2015

0X95,0XB4, 0XA5,0XB4, 0XA5,0XA6, 0X87,0X88, 0X87,0X78, 0X87,0X86,  //2016

0XA5,0XC3, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X87,  //2017

0XA5,0XB4, 0XA6,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,  //2018

0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X79, 0X77,0X87,  //2019

0X95,0XB4, 0XA5,0XB4, 0XA5,0XA6, 0X97,0X87, 0X87,0X78, 0X87,0X86,  //2020

0XA5,0XC3, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X86,  //2021

0XA5,0XB4, 0XA5,0XA5, 0XA6,0X96, 0X88,0X88, 0X88,0X78, 0X87,0X87,  //2022

0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X79, 0X77,0X87,  //2023

0X95,0XB4, 0XA5,0XB4, 0XA5,0XA6, 0X97,0X87, 0X87,0X78, 0X87,0X96,  //2024

0XA5,0XC3, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X86,  //2025

0XA5,0XB3, 0XA5,0XA5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,  //2026

0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,  //2027

0X95,0XB4, 0XA5,0XB4, 0XA5,0XA6, 0X97,0X87, 0X87,0X78, 0X87,0X96,  //2028

0XA5,0XC3, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X86,  //2029

0XA5,0XB3, 0XA5,0XA5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,  //2030

0XA5,0XB4, 0X96,0XA5, 0X96,0X96, 0X88,0X78, 0X78,0X78, 0X87,0X87,  //2031

0X95,0XB4, 0XA5,0XB4, 0XA5,0XA6, 0X97,0X87, 0X87,0X78, 0X87,0X96,  //2032

0XA5,0XC3, 0XA5,0XB5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X86,  //2033

0XA5,0XB3, 0XA5,0XA5, 0XA6,0XA6, 0X88,0X78, 0X88,0X78, 0X87,0X87,  //2034

0XA5,0XB4, 0X96,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,  //2035

0X95,0XB4, 0XA5,0XB4, 0XA5,0XA6, 0X97,0X87, 0X87,0X78, 0X87,0X96,  //2036

0XA5,0XC3, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X86,  //2037

0XA5,0XB3, 0XA5,0XA5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,  //2038

0XA5,0XB4, 0X96,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,  //2039

0X95,0XB4, 0XA5,0XB4, 0XA5,0XA6, 0X97,0X87, 0X87,0X78, 0X87,0X96,  //2040

0XA5,0XC3, 0XA5,0XB5, 0XA5,0XA6, 0X87,0X88, 0X87,0X78, 0X87,0X86,  //2041

0XA5,0XB3, 0XA5,0XB5, 0XA6,0XA6, 0X88,0X88, 0X88,0X78, 0X87,0X87,  //2042

0XA5,0XB4, 0X96,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,  //2043

0X95,0XB4, 0XA5,0XB4, 0XA5,0XA6, 0X97,0X87, 0X87,0X88, 0X87,0X96,  //2044

0XA5,0XC3, 0XA5,0XB4, 0XA5,0XA6, 0X87,0X88, 0X87,0X78, 0X87,0X86,  //2045

0XA5,0XB3, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X88,0X78, 0X87,0X87,  //2046

0XA5,0XB4, 0X96,0XA5, 0XA6,0X96, 0X88,0X88, 0X78,0X78, 0X87,0X87,  //2047

0X95,0XB4, 0XA5,0XB4, 0XA5,0XA5, 0X97,0X87, 0X87,0X88, 0X86,0X96,  //2048

0XA4,0XC3, 0XA5,0XA5, 0XA5,0XA6, 0X97,0X87, 0X87,0X78, 0X87,0X86,  //2049

0XA5,0XC3, 0XA5,0XB5, 0XA6,0XA6, 0X87,0X88, 0X78,0X78, 0X87,0X87    //2050

};

@implementation NSDate (WMZCalendarDate)

+ (NSInteger)day:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return components.day;
}

+ (NSInteger)month:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return components.month;
}

+ (NSInteger)year:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return components.year;
}

+ (NSInteger)firstWeekdayInThisMonth:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:1];
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [calendar dateFromComponents:comp];
    NSUInteger firstWeekday = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:firstDayOfMonthDate];
    return firstWeekday - 1;
}

+ (NSInteger)totaldaysInMonth:(NSDate *)date{
    NSRange daysInLastMonth = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return daysInLastMonth.length;
}

+ (int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *oneDayStr = [dateFormatter stringFromDate:oneDay];
    NSString *anotherDayStr = [dateFormatter stringFromDate:anotherDay];
    NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
    NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];
    NSComparisonResult result = [dateA compare:dateB];
    
    if (result == NSOrderedDescending) {
        return 1;
    }
    else if (result == NSOrderedAscending){
        return -1;
    }
    return 0;
}

+ (NSDictionary*)getChineseCalendarWithDate:(NSDate*)dateTemp Year:(NSInteger)myYear Month:(NSInteger)myMonth Day:(NSInteger)myDay{
   
   NSArray *chineseYears = [NSArray arrayWithObjects:
                        @"甲子", @"乙丑", @"丙寅", @"丁卯", @"戊辰", @"己巳", @"庚午", @"辛未", @"壬申", @"癸酉",
                        @"甲戌", @"乙亥", @"丙子", @"丁丑", @"戊寅",   @"己卯", @"庚辰", @"辛己", @"壬午", @"癸未",
                        @"甲申", @"乙酉", @"丙戌", @"丁亥", @"戊子", @"己丑", @"庚寅", @"辛卯", @"壬辰", @"癸巳",
                        @"甲午", @"乙未", @"丙申", @"丁酉", @"戊戌", @"己亥", @"庚子", @"辛丑", @"壬寅", @"癸丑",
                        @"甲辰", @"乙巳", @"丙午", @"丁未", @"戊申", @"己酉", @"庚戌", @"辛亥", @"壬子", @"癸丑",
                        @"甲寅", @"乙卯", @"丙辰", @"丁巳", @"戊午", @"己未", @"庚申", @"辛酉", @"壬戌", @"癸亥", nil];

   NSArray *chineseMonths=[NSArray arrayWithObjects:
                       @"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月",
                       @"九月", @"十月", @"冬月", @"腊月", nil];


   NSArray *chineseDays=[NSArray arrayWithObjects:
                     @"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",
                     @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",
                     @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十", nil];
   NSCalendar *localeCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
   unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
   NSDateComponents *localeComp = [localeCalendar components:unitFlags fromDate:dateTemp];
   NSString *y_str = [chineseYears objectAtIndex:localeComp.year-1];
   NSString *m_str = [chineseMonths objectAtIndex:localeComp.month-1];
   NSString *d_str = [chineseDays objectAtIndex:localeComp.day-1];
   NSString *chineseCal_str =[NSString stringWithFormat: @"%@年%@%@",y_str,m_str,d_str];
   NSDictionary *chineseHoliDay = [NSDictionary dictionaryWithObjectsAndKeys:
      @"春节", @"正月初一",
      @"除夕", @"腊月三十",
      @"元宵节", @"正月十五",
      @"端午节", @"五月初五",
      @"七夕", @"七月初七",
      @"中元", @"七月十五",
      @"中秋节", @"八月十五",
      @"重阳节", @"九月初九",
      @"腊八", @"腊月初八",
      @"小年", @"腊月廿四",
      nil];
      
    NSDictionary *chineseDay = @{
              @"1-1":@"元旦节",
              @"2-14":@"情人节",
              @"3-8":@"妇女节",
              @"3-12":@"植树节",
              @"4-1":@"愚人节",
              @"5-1":@"劳动节",
              @"5-4":@"青年节",
              @"6-1":@"儿童节",
              @"8-1":@"建军节",
              @"7-1":@"建党节",
              @"9-10":@"教师节",
              @"10-1":@"国庆节",
              @"11-26":@"感恩节",
              @"12-24":@"平安夜",
              @"12-25":@"圣诞节",
      };

      
    NSArray *myChineseDays = [NSArray arrayWithObjects:
      @"小寒",@"大寒",@"立春",@"雨水",@"惊蛰",@"春分",
      @"清明",@"谷雨",@"立夏",@"小满",@"芒种",@"夏至",
      @"小暑",@"大暑",@"立秋",@"处暑",@"白露",@"秋分",
      @"寒露",@"霜降",@"立冬",@"小雪",@"大雪",@"冬至",nil];
    
    NSString *str = [NSString stringWithFormat:@"%@%@",m_str,d_str];
    NSString *holday = chineseHoliDay[str];
    if (holday) {
        return @{@"name":holday,@"detail":chineseCal_str,@"holday":@(YES)};
    }else{
        NSString *tmpStr = [NSString stringWithFormat:@"%ld-%ld",(long)myMonth,(long)myDay];
        NSString *fixholday = chineseDay[tmpStr];
        if (fixholday) {
            return @{@"name":fixholday,@"detail":chineseCal_str,@"holday":@(YES)};
        }
    }
    long array_index = (myYear -START_YEAR)*12+myMonth -1 ;
    int64_t flag =gLunarHolDay[array_index];
    int64_t day;
    if(myDay <15)
    day = 15 - ((flag>>4)&0x0f);
    else
    day = ((flag)&0x0f)+15;
    long index = -1;
    if(myDay == day){
       index = (myMonth-1) *2 + (myDay>15?1: 0);
    }
    if ( index >=0  && index < [chineseDays count] ) {
        [myChineseDays objectAtIndex:index];
        return @{@"name":[myChineseDays objectAtIndex:index],@"detail":chineseCal_str,@"holday":@(YES)};
    }
    return @{@"name":d_str,@"detail":chineseCal_str,@"holday":@(NO)};;
}

+ (BOOL)isInSameDay:(NSDate*)date1 time2:(NSDate*)date2{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;

    NSDateComponents *nowCmps = [calendar components:unit fromDate:date1];
    NSDateComponents *selfCmps = [calendar components:unit fromDate:date2];

    return nowCmps.day == selfCmps.day && nowCmps.month == selfCmps.month && nowCmps.year == selfCmps.year;
}

@end
