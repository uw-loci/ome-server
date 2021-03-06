#include <stdio.h>
#include <string.h>

#include "mex.h"
#include "matrix.h"
#include "ome-Matlab.h" /* backwards compatiblity to mwSize/mwIndex */

#include "httpOMEIS.h"
#include "httpOMEISaux.h"

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[])
{
	OID ID;
	
	/* OMEIS data structures */
	omeis* is;
	pixHeader* head;
	
	/* MATLAB data structueres */
	mxArray *m_url, *m_sessionkey;
	mxArray *permute_inputs[2];
	mxArray *copy_input_array; /* we need a local copy so we can transpose it */
	
	char* url, *sessionkey;
	
	if (nrhs != 3)
		mexErrMsgTxt("\n [pix] = setPixels (is, ID, pixels)");
		
	if (!mxIsStruct(prhs[0]))
		mexErrMsgTxt("setPixels requires the first input to be the struct outputed"
					 " from openConnectionOMEIS\n");
					 
	if (!(m_url = mxGetField(prhs[0], 0, "url")))
		mexErrMsgTxt("setPixels requires the first input, OMEIS struct, to have field: url");
	if (!(m_sessionkey = mxGetField(prhs[0], 0, "sessionkey")))
		mexErrMsgTxt("setPixels requires the first input, OMEIS struct, to have field: sessionkey");
		
	if (!mxIsChar(m_url) || !mxIsChar(m_sessionkey))
		mexErrMsgTxt("OMEIS field aren't character array.\n");		
	
	if (!mxIsNumeric(prhs[1]))
		mexErrMsgTxt("setPixels requires the second input to be the PixelsID\n") ;
		
	ID = (OID) mxGetScalar(prhs[1]) ;
	
	url = mxArrayToString(m_url);
	sessionkey = mxArrayToString(m_sessionkey);

	is = openConnectionOMEIS (url, sessionkey);
	
	if (!(head = pixelsInfo (is, ID))){
		char err_str[128];
		sprintf(err_str, "PixelsID %llu or OMEIS URL '%s' is probably wrong\n", ID, is->url);		
		
		/* clean up */
		mxFree(url);
		mxFree(sessionkey);
		mxFree(is);
		
		mexErrMsgTxt(err_str);
	}
	
	/*
		In OMEIS Size_X corresponds to columns and Size_Y corresponds to rows.
		This is diametrically opposite to MATLAB's assumptions.
		hence we do
		"$matlab_var_name = permute($matlab_var_name, [2 1 3 4 5]);" 
		the hard way (groan)
	*/
	
	permute_inputs[0] = prhs[2]; /* permute_input isn't being modified so
									discarding the const qualifier is okay */
	permute_inputs[1] = mxCreateDoubleMatrix(1, 5, mxREAL);
 	mxGetPr(permute_inputs[1])[0] = 2;
 	mxGetPr(permute_inputs[1])[1] = 1;
 	mxGetPr(permute_inputs[1])[2] = 3;
 	mxGetPr(permute_inputs[1])[3] = 4;
 	mxGetPr(permute_inputs[1])[4] = 5;
 	
	/* mexCallMATLAB allocates memory for copy_input_array */
 	if (mexCallMATLAB(1, &copy_input_array, 2, permute_inputs, "permute")) {
		/* clean up */
		mxFree(url);
		mxFree(sessionkey);
		mxFree(head);
		mxFree(is);
		
 		char err_str[128];
		sprintf(err_str, "Couldn't permute the pixels to get them in MATLAB orientation");
		mexErrMsgTxt(err_str);
 	}
	
	
	/* check dimension and class check */
	const mwSize* dims = mxGetDimensions (copy_input_array);
	switch (mxGetNumberOfDimensions (copy_input_array)) {
		char err_str[128];
		case 5:
			if (head->dt != dims[4]) {
				sprintf (err_str, "5th Dimension (%d) of input array doesn't match OMEIS Pixels (%d).\n", dims[4], head->dt);
				mexErrMsgTxt(err_str);
			}
		case 4:
			if (head->dc != dims[3]) {
				sprintf (err_str, "4th Dimension (%d) of input array doesn't match OMEIS Pixels (%d).\n", dims[3], head->dc);
				mexErrMsgTxt(err_str);
			}
		case 3:
			if (head->dz != dims[2]){
				sprintf (err_str, "3th Dimension (%d) of input array doesn't match OMEIS Pixels (%d).\n", dims[2], head->dz);
				mexErrMsgTxt(err_str);
			}
		case 2:
			if (head->dy != dims[1]){
				sprintf (err_str, "Height (%d) of input array doesn't match OMEIS Pixels (%d).\n", dims[1], head->dy);
				mexErrMsgTxt(err_str);
			}
		case 1:
			if (head->dx != dims[0]){
				sprintf (err_str, "Width (%d) of input array doesn't match OMEIS Pixels (%d).\n", dims[0], head->dx);
				mexErrMsgTxt(err_str);
			}
			break;
		default:
			/* clean up */
			mxFree(url);
			mxFree(sessionkey);
			mxFree(head);
			mxFree(is);
			mxDestroyArray(copy_input_array);
					
			mexErrMsgTxt("Input Array must be 5D or less");
		break;
	}
	
	pixHeader tmp_head;
	CtoOMEISDatatype ((char*) mxGetClassName(copy_input_array), &tmp_head);
	
	if ( !samePixelType(&tmp_head, head)) {
		/* clean up */
		mxFree(url);
		mxFree(sessionkey);
		mxFree(head);
		mxFree(is);
		mxDestroyArray(copy_input_array);
		
		mexErrMsgTxt("Types of input array and Pixels don't match\n");
	}
	
	/* set the pixels */
	int pix = setPixels (is, ID, mxGetPr(copy_input_array));
	
	/* record number of pixels written */
	plhs[0] = mxCreateScalarDouble((double) pix);
	
	/* clean up */
	mxFree(url);
	mxFree(sessionkey);
	mxFree(head);
	mxFree(is);
	mxDestroyArray(copy_input_array);
}
