/*------------------------------------------------------------------------------
 *
 *  Copyright (C) 2003 Open Microscopy Environment
 *      Massachusetts Institute of Technology,
 *      National Institutes of Health,
 *      University of Dundee
 *
 *
 *
 *    This library is free software; you can redistribute it and/or
 *    modify it under the terms of the GNU Lesser General Public
 *    License as published by the Free Software Foundation; either
 *    version 2.1 of the License, or (at your option) any later version.
 *
 *    This library is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *    Lesser General Public License for more details.
 *
 *    You should have received a copy of the GNU Lesser General Public
 *    License along with this library; if not, write to the Free Software
 *    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *------------------------------------------------------------------------------
 */




/*------------------------------------------------------------------------------
 *
 * Written by:	Ilya G. Goldberg <igg@nih.gov>   1/2004
 * 
 *------------------------------------------------------------------------------
 */
#ifdef HAVE_CONFIG_H
#include <config.h>
#endif  /* HAVE_CONFIG_H */

#include <stdio.h>
#include <stdlib.h>
#include <sys/errno.h>
#include <string.h> 
#include <pic.h>
#include <filt.h>
#include <zoom.h>
#include "composite.h"
#include "Pixels.h"
#include "OMEIS_Error.h"
#include "cgi.h"

#define THUMBNAIL_SIZE 50

int DoCompositeZoom (CompositeSpec *myComposite, char setThumb, char **param);

int DoThumb (OID ID, FILE *thumbnail, ome_dim sizeX, ome_dim sizeY) {
    size_t  nIO;
    char    buf[4096];

    ThumbnailHeader  header;
    CompositeSpec    composite;

    if (!fread(&header,sizeof(ThumbnailHeader),1,thumbnail)) {
        OMEIS_DoError ("Could not read thumbnail header: %s", strerror (errno));
        return (-1);
    }

    if (header.signature != OMEIS_THUMB_SIGNATURE) {
        OMEIS_DoError ("Thumb signature is invalid.");
        return (-1);
    }

    if (sizeX > 0 && sizeY > 0) {
        memset(&composite, 0, sizeof(CompositeSpec));

        if (!(composite.thePixels = GetPixelsRep (ID,'r',bigEndian())) ) {
            OMEIS_DoError ("GetPixelsRep failed");
            return (-1);
        }

        switch (header.version) {
        case OMEIS_THUMB_SIMPLE_COMPOSITING:
            composite.theZ = header.composite.simple.theZ;
            composite.theT = header.composite.simple.theT;
            composite.sizeX = sizeX;
            composite.sizeY = sizeY;
            composite.isRGB = header.composite.simple.isRGB;
            memcpy(composite.RGBAGr,
                   header.composite.simple.RGBAGr,
                   sizeof(channelSpecType)*5);
            strcpy (composite.format,"jpeg");
            composite.stream = stdout;
            composite.x0 = composite.y0 = 0;
			composite.x1 = composite.thePixels->head->dx - 1;
			composite.y1 = composite.thePixels->head->dy - 1;
        }

        return (DoCompositeZoom(&composite, 0, NULL));
    } else {
        if (fseek(thumbnail,header.thumbnail_offset,SEEK_SET)) {
  	        OMEIS_DoError ("Could not seek to thumbnail data: %s", strerror (errno));
            return (-1);
        }

        HTTP_ResultType ("image/jpeg");
        while ((nIO = fread(buf,1,sizeof(buf),thumbnail)) > 0)
            if ( fwrite(buf,nIO,1,stdout ) != 1) break;

        return 0;
    }
}

int DoComposite (PixelsRep *myPixels, int theZ, int theT, char **param) {
char *theParam;
char setThumb=0;
char defaultFormat[] = "jpeg", *theFormat = defaultFormat;
levelBasisType levelBasis=FIXED_BASIS;
char isRGB=0, doSave=0;
channelSpecType *theChannel;
int i;
double sizeRatio;

CompositeSpec theComposite;

	memset(&theComposite, 0, sizeof(CompositeSpec));

	if (! myPixels) {
		OMEIS_DoError ("Uh, passing NULL for myPixels?");
		return (-1);
	}
	if ( (theZ < 0 || theT < 0) ||
		(theZ >= myPixels->head->dz ) ||
		(theT >= myPixels->head->dt ) ) {
			OMEIS_DoError ("Malformed coordinates (Z,T).  (%d,%d) must be >= (0,0) and < (%d,%d)",
				theZ,theT,myPixels->head->dz,myPixels->head->dt);
			return (-1);
	}
	theComposite.theZ = theZ;
	theComposite.theT = theT;

	theComposite.x0 = theComposite.y0 = 0;
	theComposite.x1 = myPixels->head->dx - 1;
	theComposite.y1 = myPixels->head->dy - 1;
	
	if ( (theParam = get_param (param,"SetThumb")) )
		setThumb=1;
	else if ( (theParam = get_lc_param (param,"Format")) && strlen (theParam) )
		theFormat = theParam;

	theComposite.sizeX = myPixels->head->dx;
	theComposite.sizeY = myPixels->head->dy;
	/*
	 Channel specification goes like so:
	 RedChannel = channel,blkLevel,whtLevel,gamma
	 ...
	 GrayChannel = channel,blkLevel,whtLevel,gamma
	 note that gamma is not implemented as of 1/04 (== 1.0).
	 LevelBasis is a separate parameter with the following values:
	 geomean, mean, fixed.  fixed is the default if LevelBasis is not specified.
	 The blkLevel and whtLevel values are either 
	 geomean + blkLevel*geosigma or mean + blkLevel*sigma or just blkLevel.
	*/
	if ( (theParam = get_lc_param (param,"LevelBasis")) ) {
		if (! strcmp (theParam,"geomean")) levelBasis=GEOMEAN_BASIS;
		else if (! strcmp (theParam,"mean")) levelBasis=MEAN_BASIS;
		else levelBasis=FIXED_BASIS;
	}

	if ( (theParam = get_param (param,"RedChannel")) ) {
		theChannel = &(theComposite.RGBAGr[0]);
		sscanf (theParam,"%d,%f,%f,%f",
			&(theChannel->channel),&(theChannel->black),&(theChannel->white),&(theChannel->gamma));
		theChannel->isOn = isRGB = 1;
		theChannel->basis = levelBasis;
		theChannel->time = theT;
	}	

	if ( (theParam = get_param (param,"GreenChannel")) ) {
		theChannel = &(theComposite.RGBAGr[1]);
		sscanf (theParam,"%d,%f,%f,%f",
			&(theChannel->channel),&(theChannel->black),&(theChannel->white),&(theChannel->gamma));
		theChannel->isOn = isRGB = 1;
		theChannel->basis = levelBasis;
		theChannel->time = theT;
	}	

	if ( (theParam = get_param (param,"BlueChannel")) ) {
		theChannel = &(theComposite.RGBAGr[2]);
		sscanf (theParam,"%d,%f,%f,%f",
			&(theChannel->channel),&(theChannel->black),&(theChannel->white),&(theChannel->gamma));
		theChannel->isOn = isRGB = 1;
		theChannel->basis = levelBasis;
		theChannel->time = theT;
	}	

	if ( (theParam = get_param (param,"AlphaChannel")) ) {
		theChannel = &(theComposite.RGBAGr[3]);
		sscanf (theParam,"%d,%f,%f,%f",
			&(theChannel->channel),&(theChannel->black),&(theChannel->white),&(theChannel->gamma));
		theChannel->basis = levelBasis;
		theChannel->time = theT;
	}

	if ( (theParam = get_param (param,"GrayChannel")) ) {
		theChannel = &(theComposite.RGBAGr[4]);
		sscanf (theParam,"%d,%f,%f,%f",
			&(theChannel->channel),&(theChannel->black),&(theChannel->white),&(theChannel->gamma));
		theChannel->isOn = 1;
		theChannel->basis = levelBasis;
		theChannel->time = theT;
	}

	if ( (theParam = get_param (param,"ROI")) ) {
		sscanf (theParam,"%d,%d,%d,%d",
			&(theComposite.x0),&(theComposite.y0),
			&(theComposite.x1),&(theComposite.y1));
		if (theComposite.x0 >= myPixels->head->dx  || theComposite.x0 < 0 )
			theComposite.x0 = 0;
		if (theComposite.y0 >= myPixels->head->dy  || theComposite.y0 < 0 )
			theComposite.y0 = 0;
		if (theComposite.x1 >= myPixels->head->dx  || theComposite.x1 < 0 )
			theComposite.x1 = myPixels->head->dx - 1;
		if (theComposite.y1 >= myPixels->head->dy  || theComposite.y1 < 0 )
			theComposite.y1 = myPixels->head->dy - 1;
		if (theComposite.x0 > theComposite.x1)
			theComposite.x0 = 0;
		if (theComposite.y0 > theComposite.y1)
			theComposite.y0 = 0;
		theComposite.sizeX = (theComposite.x1 - theComposite.x0) + 1;
		theComposite.sizeY = (theComposite.y1 - theComposite.y0) + 1;
	}

	if ( (theParam = get_param (param,"Size")) ) {
		sscanf (theParam,"%d,%d",&(theComposite.sizeX),&(theComposite.sizeY));
	}
	
	theComposite.isRGB = isRGB;

	for (i=0;i<5;i++) {
		fixChannelSpec (myPixels, &(theComposite.RGBAGr[i]) );
		if (! theComposite.RGBAGr[i].isFixed) {
			OMEIS_DoError ("Could not fix ChannelSpec!");
			return (-1);
		}
	}

	theComposite.thePixels = myPixels;
	theComposite.stream = stdout;
	strncpy (theComposite.format, theFormat, 32);
/*
	This isn't working, and the left-over code is in compositeIM.c
	DoCompositeIM   (&theComposite, param);
*/
	/* Force uniform thumbnail size */
	if( setThumb ) {
		sizeRatio = (double) myPixels->head->dx / myPixels->head->dy;
		theComposite.sizeX = ( sizeRatio > 1 ? THUMBNAIL_SIZE : THUMBNAIL_SIZE * sizeRatio );
		theComposite.sizeY = ( sizeRatio < 1 ? THUMBNAIL_SIZE : THUMBNAIL_SIZE / sizeRatio );
	}
	
	return (DoCompositeZoom (&theComposite, setThumb, param));
}


/*
  Might try implementing this with native libjpeg calls if not doing zooming.
  Or just let DoCompositeZoom take care of it all.
int DoCompositeJPEG (CompositeSpec *myComposite, char setThumb, char **param) {
	return (0);
}
*/


#define FILTER_DEFAULT "triangle"
#define WINDOW_DEFAULT "blackman"

int DoCompositeZoom (CompositeSpec *myComposite, char setThumb, char **param) {
Pic *ome_pic, *out_pic;
char *out_name, mime_type[256];
char *xfiltname = FILTER_DEFAULT, *yfiltname = 0;
char *xwindowname = 0, *ywindowname = 0;
char *fileName;
int  square=1, intscale=0;
double xsupp = -1., ysupp = -1.;
double xblur = -1., yblur = -1.;
Window_box ome_win, out_win;
Filt *xfilt, *yfilt, xf, yf;

FILE *thumbnail;
ThumbnailHeader  thumbHeader;

/*
Continuous coordinates aren't implemented
Mapping m;
*/

    memset(&thumbHeader, 0, sizeof(ThumbnailHeader));

    ome_win.x0 = out_win.x0 = PIC_UNDEFINED;
    ome_win.x1 = out_win.x1 = PIC_UNDEFINED;

	out_name = myComposite->thePixels->path_thumb;

	if ( !(ome_pic = pic_open_dev ("omeis",(char *)myComposite, "r")) ) {
		OMEIS_DoError ("Could not open input Pic (%s)",myComposite->thePixels->path_rep);
		return (-1);
	}

	if (setThumb) {
		strcpy (myComposite->format,"jpeg");

        thumbHeader.signature = OMEIS_THUMB_SIGNATURE;
        thumbHeader.version = OMEIS_THUMB_SIMPLE_COMPOSITING;
        thumbHeader.thumbnail_offset = sizeof(ThumbnailHeader);
        thumbHeader.composite.simple.theZ = myComposite->theZ;
        thumbHeader.composite.simple.theT = myComposite->theT;
        thumbHeader.composite.simple.sizeX = myComposite->sizeX;
        thumbHeader.composite.simple.sizeY = myComposite->sizeY;
        thumbHeader.composite.simple.isRGB = myComposite->isRGB;

        memcpy(thumbHeader.composite.simple.RGBAGr,
               myComposite->RGBAGr,
               sizeof(channelSpecType)*5);

        if (!(thumbnail = fopen(out_name,"w"))) {
			OMEIS_DoError ("Could not open output Pic for thumbnail %s: %s",out_name, strerror (errno));
			return (-1);
        }

        if (!fwrite(&thumbHeader,sizeof(ThumbnailHeader),1,thumbnail)) {
            fclose(thumbnail);
			OMEIS_DoError ("Could not write thumbnail header %s: %s",out_name, strerror (errno));
			return (-1);
        }

		if ( !(out_pic = pic_open_stream ("jpeg", thumbnail, out_name, "w")) ) {
			OMEIS_DoError ("Could not open output Pic for thumbnail %s",out_name);
			return (-1);
		}
	} else {
		strcat (out_name,myComposite->format);
		if ( !(out_pic = pic_open_stream (myComposite->format, stdout, out_name, "w")) ) {
			OMEIS_DoError ("Could not open output Pic for streaming (%s format)",myComposite->format);
			return (-1);
		}
	}

	
	if (myComposite->isRGB) pic_set_nchan (out_pic,3);
	else pic_set_nchan (out_pic,1);
	
	out_win.x0 = 0;
	out_win.y0 = 0;
	out_win.x1 = out_win.x0 + myComposite->sizeX - 1;
	out_win.y1 = out_win.y0 + myComposite->sizeY - 1;

	/*
	  The following is pretty much straight out of zoom_main.c
	*/
	if (ome_win.x0==PIC_UNDEFINED) pic_get_window(ome_pic, (void *)&ome_win);
	/*
	 * nx and ny uninitialized at this point
	 */
	if (!yfiltname) yfiltname = xfiltname;
	xfilt = filt_find(xfiltname);
	yfilt = filt_find(yfiltname);
	if (!xfilt || !yfilt) {
		OMEIS_DoError ("can't find filters %s and %s\n",
		xfiltname, yfiltname);
		return (-1);
	}

	/* copy the filters before modifying them */
	xf = *xfilt; xfilt = &xf;
	yf = *yfilt; yfilt = &yf;
	if (xsupp>=0.) xfilt->supp = xsupp;
	if (xsupp>=0. && ysupp<0.) ysupp = xsupp;
	if (ysupp>=0.) yfilt->supp = ysupp;
	if (xblur>=0.) xfilt->blur = xblur;
	if (xblur>=0. && yblur<0.) yblur = xblur;
	if (yblur>=0.) yfilt->blur = yblur;
	
	if (!ywindowname) ywindowname = xwindowname;
	if (xwindowname || xfilt->windowme) {
		if (!xwindowname) xwindowname = WINDOW_DEFAULT;
			xfilt = filt_window(xfilt, xwindowname);
	}
	if (ywindowname || yfilt->windowme) {
		if (!ywindowname) ywindowname = WINDOW_DEFAULT;
			yfilt = filt_window(yfilt, ywindowname);
	}

	if ( param != NULL && (fileName = get_param (param,"Save")) && getenv("REQUEST_METHOD") && !setThumb) {
		fprintf (stdout,"Content-Disposition: attachment; filename=\"%s.%s\"\r\n",fileName,myComposite->format);
		HTTP_ResultType ("application/octet-stream");
	} else if (!setThumb){
		strcpy (mime_type,"image/");
		strncat (mime_type,myComposite->format,200);
		HTTP_ResultType (mime_type);
	} else if (setThumb){
		HTTP_ResultType ("text/plain");
	}

	zoom_opt(ome_pic, &ome_win, out_pic, &out_win, xfilt, yfilt, square, intscale);

    pic_close(ome_pic);
    pic_close(out_pic);

	return (0);
}
