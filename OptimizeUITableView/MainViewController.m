//
//  MainViewController.m
//  OptimizeUITableView
//
//  Created by Doan Cuong on 9/9/14.
//  Copyright (c) 2014 Doan Cuong. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
{
    NSMutableString *suffixURL;
    AFHTTPRequestOperation *operation;
    NSURLRequest *urlRequest;
    NSMutableArray *sourceArray;
    UIActivityIndicatorView *indicator;
    UITableView *tableView;
    int currentRowIndex;
    void (^successBlock)(AFHTTPRequestOperation *operation, id responseObject);
    void (^failureBlock)(AFHTTPRequestOperation *operation, NSError *error);
}

static NSString *const baseURL = @"http://infinigag.eu01.aws.af.cm/trending/";


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init
{
    self = [super init];
    
    if (self)
    {
        //custom initialization
        self->sourceArray = [[NSMutableArray alloc] init];
        
        self->suffixURL = [NSMutableString stringWithString:@"0"];
        
        __unsafe_unretained typeof(self) weakself = self;
        
        self->successBlock = ^(AFHTTPRequestOperation *operation, id responseObject)
        {
            [weakself stopIndicator];
            NSDictionary *pagingDictionary = responseObject[@"paging"];
            weakself->suffixURL = [NSMutableString stringWithString:pagingDictionary[@"next"]];
            
            NSArray *dataDictionary = responseObject[@"data"];
            
            [weakself->sourceArray addObject:@"error_link"];
            
            for (NSDictionary *key in dataDictionary)
            {
                  NSDictionary *imageDictionary = key[@"images"];
                  [weakself->sourceArray addObject:imageDictionary[@"large"]];
            }
            
            [weakself->tableView reloadData];
            
            if (weakself->currentRowIndex != 0)
                [weakself->tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:weakself->currentRowIndex + 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        };
        
        self->failureBlock = ^(AFHTTPRequestOperation *operation, NSError *error)
        {
            [weakself stopIndicator];
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Connection Error!" message:@"Can not request data from server. Please check your network connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];
        };
        
        [self createTableView];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self requestData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)requestData
{
    self->urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseURL, self->suffixURL]]];
    self->operation = [[AFHTTPRequestOperation alloc] initWithRequest:self->urlRequest];
    [self->operation setCompletionBlockWithSuccess:self->successBlock failure:self->failureBlock];
    self->operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    self->operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [self->operation start];
    
    [self showIndicator];
}

-(void)showIndicator
{
    [self.view setUserInteractionEnabled:NO];
    self->indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self->indicator.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
    [self.view addSubview:self->indicator];
    [self->indicator startAnimating];
}

-(void)stopIndicator
{
    [self->indicator removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
}

-(void)createTableView
{
    CGRect tableViewFrame;
    
    NSString *version = [[UIDevice currentDevice] systemVersion];
    int ver = [version intValue];
    
    if (ver < 7)
    {
        tableViewFrame = self.view.bounds;
    }
    else
    {
        tableViewFrame = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height - 20);
    }
    
    self->tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
    self->tableView.dataSource = self;
    self->tableView.delegate = self;
    self->tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self->tableView.backgroundColor = [UIColor whiteColor];
    self->tableView.rowHeight = 500;
    
    [self.view addSubview:self->tableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self->sourceArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"imageCell";
    
    TableViewImageCell *cell = [self->tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
        cell = [[TableViewImageCell alloc] initWithStyleAndFilePath:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier filePath:[self->sourceArray objectAtIndex:indexPath.row]];
    else
        cell.imagePath = [self->sourceArray objectAtIndex:indexPath.row];
    
    self->currentRowIndex = indexPath.row;
    
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
     CGFloat currentOffset = scrollView.contentOffset.y;
     CGFloat maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;

     // Change 10.0 to adjust the distance from bottom
     if (currentOffset == maximumOffset)
     {
         [self requestData];
     }

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
