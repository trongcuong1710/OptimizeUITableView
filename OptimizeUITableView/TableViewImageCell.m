//
//  TableViewImageCell.m
//  OptimizeUITableView
//
//  Created by Doan Cuong on 9/8/14.
//  Copyright (c) 2014 Doan Cuong. All rights reserved.
//

#import "TableViewImageCell.h"

@implementation TableViewImageCell {
    int offsetX;
    int offsetY;
    int height;
    UIImageView *imageView;
    UIButton *realoadButton;
    NSURLRequest *urlRequest;
    UIProgressView *progressView;
    AFHTTPRequestOperation *operation;
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject);
    void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error);
    void (^progressBlock)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
    }
    return self;
}

-(id)initWithStyleAndFilePath:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
                     filePath:(NSString *)imagePath
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        // Initialization code
        self->offsetX = 5;
        self->offsetY = 5;
        self->height = 500;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self addObserver:self forKeyPath:@"imagePath" options:NSKeyValueObservingOptionNew context:nil];
        
        [self createImageView];
        
        __unsafe_unretained typeof(self) weakSelf = self;
        
        self->successBlock = ^(AFHTTPRequestOperation *operation, id responseObject)
        {
            weakSelf->imageView.image = [UIImage imageWithData:responseObject];
            [weakSelf->progressView removeFromSuperview];
        };
        
        self->failureBlock = ^(AFHTTPRequestOperation *operation, NSError *error)
        {
            [weakSelf createReloadButton];
            [weakSelf->progressView removeFromSuperview];
        };
        
        self->progressBlock = ^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead)
        {
            if (weakSelf->progressView == nil)
            {
                [weakSelf createProgressView];
            }
            
            double progress = (double)totalBytesRead / (double)totalBytesExpectedToRead;
            
            [weakSelf->progressView setProgress:progress animated:YES];
        };
        
        self.imagePath = [imagePath mutableCopy];
    }
    
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    int width = self.bounds.size.width - 10;
    int height = self->height - 10;
    
    CGRect rectangle = CGRectMake(self->offsetX, self->offsetY, width, height);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rectangle cornerRadius:5.0f];
    bezierPath.lineWidth = 1.0f;
    [[UIColor blackColor] setStroke];
    [bezierPath stroke];
}

-(void)createImageView
{
    int width = self.bounds.size.width - 16;
    int height = self->height - 16;
    
    CGRect rect = CGRectMake(self->offsetX + 3, self->offsetY + 3, width, height);
    
    self->imageView = [[UIImageView alloc] initWithFrame:rect];
    self->imageView.contentMode = UIViewContentModeScaleAspectFill;
    self->imageView.clipsToBounds = YES;
    //self->imageView.backgroundColor = [UIColor blackColor];
    
    [self addSubview:imageView];
}

-(void)createReloadButton
{
    int width = 100;
    int height = 100;
    int x = self.bounds.size.width / 2 - width / 2;
    int y = self->height / 2 - height / 2;
    
    CGRect rectangle = CGRectMake(x, y, width, height);
    
    self->realoadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    self->realoadButton.backgroundColor = [UIColor whiteColor];
    
    //self->realoadButton.titleLabel.textColor = [UIColor blackColor];
    
    self->realoadButton.frame = rectangle;
    
    [self->realoadButton setTitle:@"Reload" forState:UIControlStateNormal];
    
    [self addSubview:self->realoadButton];
    
    [self->realoadButton addTarget:self action:@selector(reloadButtonTouch) forControlEvents:UIControlEventTouchUpInside];
}

-(void)createProgressView
{
    int width = self.bounds.size.width - 12;
    int height = 5;
    
    CGRect rectangle = CGRectMake(self->offsetX + 1, self->offsetY + 1, width, height);
    
    self->progressView = [[UIProgressView alloc] initWithFrame:rectangle];
    
    [self addSubview:self->progressView];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.imagePath == nil)
        return;
    
    [self loadImage];
}

-(void)reloadButtonTouch
{
    [self loadImage];
    [self->realoadButton removeFromSuperview];
}

-(void)loadImage
{
    self->urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.imagePath]];
    self->operation = [[AFHTTPRequestOperation alloc] initWithRequest:self->urlRequest];
    [self->operation setCompletionBlockWithSuccess:self->successBlock failure:self->failureBlock];
    [self->operation setDownloadProgressBlock:self->progressBlock];
    [self->operation start];
}

-(void)prepareForReuse
{
    [self->operation cancel];
    self->imageView.image = nil;
    self.imagePath = nil;
    self->operation = nil;
    self->urlRequest = nil;
    
    if (self->realoadButton != nil)
    {
        [self->realoadButton removeFromSuperview];
        self->realoadButton = nil;
    }
    
    if (self->progressView != nil)
    {
        [self->progressView removeFromSuperview];
        self->progressView = nil;
    }
}

@end
