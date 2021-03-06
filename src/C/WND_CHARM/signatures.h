/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                                                               */
/*    Copyright (C) 2007 Open Microscopy Environment                             */
/*         Massachusetts Institue of Technology,                                 */
/*         National Institutes of Health,                                        */
/*         University of Dundee                                                  */
/*                                                                               */
/*                                                                               */
/*                                                                               */
/*    This library is free software; you can redistribute it and/or              */
/*    modify it under the terms of the GNU Lesser General Public                 */
/*    License as published by the Free Software Foundation; either               */
/*    version 2.1 of the License, or (at your option) any later version.         */
/*                                                                               */
/*    This library is distributed in the hope that it will be useful,            */
/*    but WITHOUT ANY WARRANTY; without even the implied warranty of             */
/*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU          */
/*    Lesser General Public License for more details.                            */
/*                                                                               */
/*    You should have received a copy of the GNU Lesser General Public           */
/*    License along with this library; if not, write to the Free Software        */
/*    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA  */
/*                                                                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                                                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* Written by:  Lior Shamir <shamirl [at] mail [dot] nih [dot] gov>              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


#ifndef signaturesH
#define signaturesH
//---------------------------------------------------------------------------

#include <stdio.h>

#include "cmatrix.h"
//#include "TrainingSet.h"

#define MAX_SIGNATURE_NUM 4000
#define SIGNATURE_NAME_LENGTH 80
#define IMAGE_PATH_LENGTH 256

//typedef struct
//{
//  double data[MAX_SIGNATURE_NUM];                   /* signature values                          */
//  unsigned short sample_class;                      /* the class of the sample                   */
//  char full_path[256];                              /* optional - full path the the image file   */
//}sample;

struct signature
{
  public:
//   char name[SIGNATURE_NAME_LENGTH];
   double value;
};

class signatures
{
  private:
    int IsNeeded(long start_index, long group_length);  /* check if the group of signatures is needed */
  public:
    signature data[MAX_SIGNATURE_NUM];
    unsigned short sample_class;                    /* the class of the sample */
	double interpolated_value;
    long count;
    char full_path[IMAGE_PATH_LENGTH];              /* optional - full path the the image file   */
	void *NamesTrainingSet;             /* the training set in which this set of signatures belongs - is assigned so that the signature names will be added */
    void *ScoresTrainingSet;            /* a pointer to a training set with computed Fisher scores (to avoid computing 0-scored signatures)                 */
    signatures();                       /* constructor */
    signatures *duplicate();            /* create an identical signature vector object */
//    signatures(sample *one_sample, int sigs_count);
    void Add(char *name, double value);
    void Clear();
    void compute(ImageMatrix *matrix, int compute_colors);
    void CompGroupA(ImageMatrix *matrix, char *transform_label);
    void CompGroupB(ImageMatrix *matrix, char *transform_label);
    void CompGroupC(ImageMatrix *matrix, char *transform_label);
    void CompGroupD(ImageMatrix *matrix, char *transform_label);
    void ComputeGroups(ImageMatrix *matrix, int compute_colors);
    void normalize(void *TrainSet);                /* normalize the signatures based on the values of the training set */
    void ComputeFromDouble(double *data, int height, int width, int compute_color);  /* compute the feature values from an array of doubles */
    FILE *FileOpen(char *path, int tile_x, int tile_y);
    void FileClose(FILE *value_file);
    int SaveToFile(FILE *value_file,int save_feature_names);
    int LoadFromFile(char *filename);
};

#endif


