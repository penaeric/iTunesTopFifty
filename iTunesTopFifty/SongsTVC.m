//
//  SongsTVC.m
//  iTunesTopFifty
//
//  Created by Eric Pena on 11/7/13.
//  Copyright (c) 2013 Eric Pena. All rights reserved.
//

#import "SongsTVC.h"
#import "Config.h"
#import "SongCell.h"
#import "WebVC.h"
#import "UIImageView+AFNetworking.h"

@interface SongsTVC () <NSXMLParserDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

@property (strong) NSXMLParser *parser;

/** Contains the complete response
 */
@property (strong) NSMutableArray *songs;

/** Current section being parsed
 */
@property (strong) NSMutableDictionary *currentDictionary;

// Properties used during the XML parsing
@property (strong) NSString *previousElementName;
@property (strong) NSString *elementName;
@property (strong) NSMutableString *outString;


@end



@implementation SongsTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
#ifdef DEBUG
    // Add a button to clear the view while debugging
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Clear"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(clearTableView)];
    self.navigationItem.leftBarButtonItem = clearButton;
#endif
    
    [self loadSongs];
}


- (IBAction)refreshButtonTapped:(id)sender
{
    [self loadSongs];
}


/** Clear the Table View, for debugging purposes
 */
- (void)clearTableView
{
    self.songs = nil;
    [self.tableView reloadData];
}


- (void)loadSongs
{
    // Disable the Refresh button
    self.refreshButton.enabled = NO;
    self.title = @"Loading Top Songs...";
    
    // Make an asynchronous call to the server
    NSURL *url = [NSURL URLWithString:[[Config sharedInstance] url]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFXMLParserResponseSerializer serializer];
    // We need to add this content type to be able to accept it and parse it
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/atom+xml"];
#ifdef DEBUG
    // Disable cache during debugging
    [operation setCacheResponseBlock:^NSCachedURLResponse *(NSURLConnection *connection, NSCachedURLResponse *cachedResponse) {
        return nil;
    }];
#endif
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Parse the XML
        self.songs = [NSMutableArray array];
        self.parser = [[NSXMLParser alloc] initWithData:operation.responseData];
        self.parser.delegate = self;
        self.parser.shouldProcessNamespaces = YES;
        [self.parser parse];
        
        // enable the Refresh button
        self.refreshButton.enabled = YES;
        self.title = @"Top Songs";
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        // In case of error, display it on a alert view
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Songs"
                                                            message:@"Please try again."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        
        NSLog(@"%@", [error localizedDescription]);
        
        // enable the Refresh button
        self.refreshButton.enabled = YES;
        self.title = @"Top Songs";
    }];
    
    [operation start];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Show the album's site
    if ([segue.identifier isEqualToString:@"Show Site"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        WebVC *vc = segue.destinationViewController;
        vc.url = self.songs[indexPath.row][@"url"];
        NSLog(@"%@", self.songs[indexPath.row][@"title"]);
        vc.title = self.songs[indexPath.row][@"title"];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.songs count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Set up the Cell
    static NSString *CellIdentifier = @"Cell";
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.artistNameLabel.text = self.songs[indexPath.row][@"artist"];
    cell.songTitleLabel.text = self.songs[indexPath.row][@"name"];
    cell.priceLabel.text = self.songs[indexPath.row][@"price"];
    
    // Asynchronously load the album's image
    __weak SongCell *weakCell = cell;
    
    [weakCell.imageView setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.songs[indexPath.row][@"images"][2]]]
                              placeholderImage:[UIImage imageNamed:@"loading"]
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           weakCell.imageView.image = image;
                                           weakCell.imageView.frame = CGRectMake(weakCell.imageView.frame.origin.x,
                                                                                 weakCell.imageView.frame.origin.y,
                                                                                 image.size.width,
                                                                                 image.size.height);
                                           [weakCell setNeedsLayout];
                                           
                                       } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                           NSLog(@"Error loading the image @ {%@} with Error: %@", self.songs[indexPath.row][@"images"][2], [error localizedDescription]);
                                       }];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Show webView
    // [self performSegueWithIdentifier:@"Show Site" sender:self];
    
    // Since webView opens the iTunes store, just open it directly
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.songs[indexPath.row][@"url"]]];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    // Keep track of the previous element before start constructing the new one
    self.previousElementName = self.elementName;
    
    if (qName) {
        self.elementName = qName;
    }
    
    // Create a dictionary for each entry
    if ([qName isEqualToString:@"entry"]) {
        self.currentDictionary = [NSMutableDictionary dictionary];
    }
    
    // Reset the out String that we build as we read the XML inside this tag
    self.outString = [NSMutableString string];
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (!self.elementName) {
        return;
    }
    
    [self.outString appendFormat:@"%@", string];
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // Add an 'entry'
    if ([qName isEqualToString:@"entry"]) {
        [self.songs addObject:self.currentDictionary];
        
        self.currentDictionary = nil;
    }
    // Save 'id' as 'url'
    else if ([qName isEqualToString:@"id"]) {
        [self.currentDictionary setObject:self.outString forKey:@"url"];
    }
    // Save 'title'
    else if ([qName isEqualToString:@"title"]) {
        [self.currentDictionary setObject:self.outString forKey:qName];
    }
    // Save 'name', there's a nested 'im:name' inside 'im:collection', we should ignore it
    else if ([qName isEqualToString:@"im:name"] && !self.currentDictionary[@"name"]) {
        [self.currentDictionary setObject:self.outString forKey:[qName substringFromIndex:3]];
    }
    // Save 'artist' and 'price'
    else if ([qName isEqualToString:@"im:artist"] || [qName isEqualToString:@"im:price"]) {
        [self.currentDictionary setObject:self.outString forKey:[qName substringFromIndex:3]];
    }
    // Save image links
    else if ([qName isEqualToString:@"im:image"]) {
        if (self.currentDictionary[@"images"]) {
            [self.currentDictionary[@"images"] addObject:self.outString];
        } else {
            [self.currentDictionary setObject:[NSMutableArray arrayWithObject:self.outString] forKey:@"images"];
        }
    }
    
    self.elementName = nil;
}


- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    // Reload the data once we have finished parsing the XML
    NSLog(@"Parser Did End Document %@", self.songs);
    [self.tableView reloadData];
}

@end
