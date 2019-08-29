#!/usr/bin/env python

'''
Author: Yotam Gingold <yotam (strudel) yotamgingold.com>
License: Public Domain [CC0](http://creativecommons.org/publicdomain/zero/1.0/)
Description: Creates the simplest possible static HTML image gallery for a set of images. Just the images with CSS max-width, max-height, and padding. Thumbnails optional.
URL: https://gist.github.com/yig/1bab9c01806625237f1656e44667dd9a/
'''

from __future__ import division, print_function
import os, sys
import argparse
import subprocess
import re


head = '''<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" type="text/css" href="/style.css">
</head>
<body>
<div class="photos">'''

tail = '''</div>
</body>
</html>'''

each = '''<img alt="%(name)s" src="%(thumbnail)s">'''
each = '''<div><a href="%(name)s">''' + each + '''</a></div>'''

def positive_int( arg ):
    pint = int( arg )
    if pint <= 0:
        raise argparse.ArgumentTypeError( "%s is not a positive integer" % arg )
    return pint

parser = argparse.ArgumentParser( description = 'Create the simplest possible image gallery html page.' )
parser.add_argument( '--outpath', type = str, default = 'index.html', help = 'The path to save the image gallery html page.' )
parser.add_argument( '--title', type = str, default = 'Image Gallery', help = 'The path to save the image gallery html page.' )
parser.add_argument( '--max-width', type = str, default = '500', help = 'The CSS size to use as the max-width of each image. Default is 500px. You can also use "auto".' )
parser.add_argument( '--max-height', type = str, default = '500', help = 'The CSS size to use as the max-height of each image. Default is 500px. You can also use "auto".' )
parser.add_argument( '--no-thumbnails', dest = 'generate_thumbnails', action = 'store_false', default = True, help = 'Whether to use full size images everywhere and skip thumbnail generation.' )
parser.add_argument( '--thumbnail-long-edge', type = positive_int, default = '500', help = 'The size of the thumbnails to generate as the number of pixels in the long edge.' )
parser.add_argument( '--padding', type = str, default = '10px', help = 'The CSS padding parameter for each image. Default is 10px. You can also specify a series of four values for separate top right bottom left.' )
parser.add_argument( '--no-sort', dest = 'sort', action = 'store_false', default = True, help = "Whether to naturally sort filenames (whole numbers in filenames sort according to value)." )
parser.add_argument( 'image_paths', type = str, nargs = '+', help = 'The paths to the images.' )

args = parser.parse_args()

imgs = args.image_paths
if args.sort:
    ## From: http://stackoverflow.com/questions/4836710/does-python-have-a-built-in-function-for-string-natural-sort/18415320#18415320
    def natural_sort(l): 
        convert = lambda text: int(text) if text.isdigit() else text.lower() 
        alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ] 
        return sorted(l, key = alphanum_key)
    imgs = natural_sort( imgs )

if os.path.exists(args.outpath):
    print( "ERROR: File exists, won't clobber:", args.outpath, file = sys.stderr )
    sys.exit(-1)

if args.generate_thumbnails:
    thumbdir = os.path.join( os.path.split( args.outpath )[0], 'thumbnails' )
    ## Make it if it doesn't exist.
    if not os.path.exists( thumbdir ):
        os.makedirs( thumbdir )
    if not os.path.isdir( thumbdir ):
        print("ERROR: Unable to create thumbnail directory:", thumbdir, file = sys.stderr)
        sys.exit(-1)
    
    ## For calling 'convert'
    
    def save_thumbnail_of_image_to_path(image_path, thumbnail_path):
        ## Resize the image to a maximum of edge-by-edge.
        ## There is an argument: "-define jpeg:size=2*edge x 2*edge"
        ## that could speed things up, but I don't know how to call it without
        ## knowing the aspect ratio.
        ## http://www.imagemagick.org/Usage/formats/#jpg_read
        if os.path.exists(thumbnail_path):
            print("WARNING: Thumbnail image already exists, not regenerating:", thumbnail_path, file = sys.stderr)
            return
        
        video = 0
        orig_path = image_path
        ## If the image_path points to a video file, ask for the first frame.
        if os.path.splitext(image_path)[1].lower() in ('.mp4', '.m4v', '.mov'):
            print("Video encountered; generating thumbnail to the first frame:", image_path, file = sys.stderr)
            image_path = image_path + '[0]'
            video = 1
        
#        cmd = ['convert', '-auto-orient', '-define', 'registry:temporary-path=/home/abf/tmp', image_path, '-quality', '85', '-thumbnail', '%(edge)sx%(edge)s>' % { 'edge': args.thumbnail_long_edge }, thumbnail_path]
        cmd = ['convert', '-auto-orient', '-define', 'registry:temporary-path=/home/abf/tmp', image_path, '-quality', '85', '-thumbnail', '%(width)s>' % { 'width': args.max_width }, thumbnail_path]
        print('Generating:', thumbnail_path)
        print(' '.join(cmd))
        subprocess.call(cmd)

        cmd = ['exiftool', '-overwrite_original_in_place', '-tagsFromFile', orig_path, '-gps:all', '-CreateDate', '-DateTimeOriginal', '-Make', '-Model', thumbnail_path]
        print('Copying EXIF to thumbnail:', thumbnail_path)
        print(' '.join(cmd))
        subprocess.call(cmd)

        if video:
            cmd = ['composite', '-gravity', 'center', '../../files/play.png', thumbnail_path, thumbnail_path]
            print('Adding play button to video:', thumbnail_path)
            subprocess.call(cmd)

def get_argv():
    ## Save the arguments used to call this script.
    
    ## Simplest:
    # return ' '.join( sys.argv )
    
    ## Fancier:
    argv = list(sys.argv)
    ## Drop the absolute path from argv0.
    argv[0] = os.path.split(argv[0])[1]
    ## Put quotes around arguments with funny characters.
    unsafe = re.compile(r'[^-a-zA-Z0-9_./]')
    argv = [("'" + arg + "'") if unsafe.search(arg) else arg for arg in argv]
    argv = ' '.join(argv)
    return argv

with open(args.outpath, 'wb') as out:
    print(head, file = out)
    
    for img in imgs:
        ## Make a thumbnail.
        if args.generate_thumbnails:
            thumbnail_ext = 'jpg'
            if os.path.splitext(img)[1].lower() in ('.png'):
                thumbnail_ext = 'png'
              
            thumbnail = os.path.join(thumbdir, os.path.splitext(os.path.split(img)[1])[0] + '.' + thumbnail_ext)
            save_thumbnail_of_image_to_path( img, thumbnail )
        print(each % {'name': img, 'thumbnail': (thumbnail if args.generate_thumbnails else img) }, file = out)
    
    print(tail, file = out)
