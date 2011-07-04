FilesDownloader
==================

FilesDownloader is a simple class, that uses NSURLConnection to download array of files from source path.

FilesDownloader is used in [iTraceur](http://itunes.apple.com/us/app/itraceur-parkour-freerunning/id374163905?mt=8 "AppStore Link") for downloading video cutscenes from the internet.
CCVideoPlayer is fully compatible with FilesDownloader: it plays files from Cached directory, where FilesDownloader left them after downloading.

FilesDownloader consists of:

1. **SingleFileDownloader** class, which downloads one file
2. **FilesDownloader class**, which uses many SingleFileDownloader to examine files sizes and download them. 
It also gives user knowledge of how many percents of all files are downloaded.


Test features
-------------
FilesDownloaderTest shows how to use FilesDownloader for downloading sprites from internet.   
DownloadLayer is designed as a very simple super class for downloading different stuff, so it should be pretty easy for you to create your own Download Scene, based on this class.

Locks issues on Mac
-------------
Sometimes it's possible to FilesDownloader block the CCDirector's runLoop.   
It happens when you use CCDirectorDisplayLink with CC_DIRECTOR_MAC_USE_DISPLAY_LINK_THREAD = 1 (the default one) on Mac OS X.   
So no frames will be rendered and fps counter will not change, until download finishes.   
To avoid this behavior - use main (or other than CCDirector#runningThread) thread for invoking FilesDownloader#start / FilesDownloader#cancel:   

    #ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
        [_downloader performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
    #else
        [_downloader start];
    #endif

Issues
------------

1. No redirect support, any redirect will lead to connection error.
1. It's possible to restart download, when everything is downloaded. This will lead to infinite loop. 
Test shows how to avoid this (See FilesDownloaderTestLayer.m:184)

Despite these issues, FilesDownloader is very stable and works perfect with direct links.


