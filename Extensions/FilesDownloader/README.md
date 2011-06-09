FilesDownloader
==================

FilesDownloader is a simple class, that uses NSURLConnection to download array of files from source path.
Tested on iOS 3+, should also work on Mac.

FilesDownloader is used in [iTraceur](http://itunes.apple.com/us/app/itraceur-parkour-freerunning/id374163905?mt=8 "AppStore Link") for downloading video cutscenes from internet.
[CCVideoPlayer](https://github.com/psineur/CCVideoPlayer "GitHub Repo") is fully compatible with FilesDownloader: it plays files from Cached directory, where FilesDownloader downloads them.

FilesDownloader consists of:

1. FileDownloader class, which downloads one file
2. FilesDownloader class, which uses many FileDownloader's to examine files sizes and download them. 
It also gives user knowledge of how many percents of all files are downloaded.


Demo features
-------------
This repo contains iOS XCode project, that shows how to use FilesDownloader for downloading sprites from internet.
DownloadLayer is designed as a very simple super class for downloading different stuff, so it's pretty for you to create your own Download Scene, based on this class.

Issues
------------
1. Confusing class naming
2. Needs to be tested on Mac, some #ifdef should be removed to enable work on Mac.
3. No redirect support, any redirect will lead to error
4. It's possible to restart download, when everything is downloaded. This will lead to infinite loop. 
Demo app shows how to avoid this (See DownloadLayer.m)

Despite all these issues, FilesDownloader is very stable and works perfect with direct links.


Contribution
--------------
Feel free to use, ask, comment, fork, pull request or do whatever you want ;)

