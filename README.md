iTunes Top 50
===========================


Simple iOS application that does the following:

* Parses the [iTunes RSS feed](http://itunes.apple.com/us/rss/topsongs/limit=50/xml) and asynchronously loads the contents of the feed and displays it as a scrolling list that correctly utilizes the space of the device screen.
* Displays the content in all orientations.
* Each song is represented with an image on the left, the title of the song to the right with the artist name below it. To the right of the artist name, display the price.
* Contains a *Refresh* button in the upper right corner of the navigation bar which will query the RSS feed and refresh the screen.
* Gives the user feedback about loading items by displaying the typical loading indicator for the RSS feed and loading images.
* Selecting an item opens the iTunes Store link for the RSS feed item.


![Alt text](screenshot-sm-portrait.png?raw=true "iTunes Top 50")

![Alt text](screenshot-sm-landscape.png?raw=true "iTunes Top 50 - Landscape mode")


Notes about the implementation
-------------------------------

* The App can be displayed in all orientations, including upside down.
* The feed is loaded and parsed asynchronously.  AFNetworking's AFHTTPRequestOperation is used to make the call to the server.
* The cache is disabled while debugging.
* When parsing the XML, only the needed information is stored, ignoring all other information that is not used by the App.
* Auto layout is used to correctly utilize the space of the screen.  Also, if the text is too long, it will shrink a bit to try to display as much as it can.
* While the images are loading, an iTunes logo is displayed as the cover for the album/song.
* The images are also loaded asynchronously.  AFNetworking's UIImageView+AFNetworking category is used to achieve this.
* The screen contains a *Refresh* button, and during debugging a *Clear* button is added in the upper left corner.
* The application gives feedback about loading items by displaying the typical indicator on the status bar, the title of the view also changes to *Loading Top Songs...* while the XML is loading.
* The app will open the iTunes store when the user taps on an item.  The idea was to open the link on a webView, but since all the links in the feed are iTunes links, the iTunes store is automatically opened (Depending on the link, some songs/albums won't be loaded by the iTunes app).
    * To show what was tried to accomplish, the view with the webView is kept on the project's Storyboard and the the code that would show that view is commented out. Instead, the link is opened directly.  The user is able to go back to the app where he/she last left off without fetching the feed again.
* A launch image was added so that it looks like the app loads faster.  Also, an app icon was added for aesthetic purposes.


Dependencies
-------------------------------
* [AFNetworking](https://github.com/AFNetworking/AFNetworking)
* iOS 7