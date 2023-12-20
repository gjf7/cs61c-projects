/************************************************************************
**
** NAME:        imageloader.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Dan Garcia  -  University of California at Berkeley
**              Copyright (C) Dan Garcia, 2020. All rights reserved.
**              Justin Yokota - Starter Code
**				YOUR NAME HERE
**
**
** DATE:        2020-08-15
**
**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <string.h>
#include "imageloader.h"

// Opens a .ppm P3 image file, and constructs an Image object.
// You may find the function fscanf useful.
// Make sure that you close the file with fclose before returning.
Image *readData(char *filename)
{
	// YOUR CODE HERE
	Image *ret = malloc(sizeof(Image));
	if (ret == NULL)
	{
		allocation_failed();
		return NULL;
	}

	FILE *fp = fopen(filename, "r");
	if (fp == NULL)
	{
		fprintf(stderr, "Error opening file");
		free(ret);
		return NULL;
	}

	char format[3];
	if (fscanf(fp, "%2s", format) != 1 || strcmp(format, "P3") != 0)
	{
		fprintf(stderr, "Error: wrong format of file");
		fclose(fp);
		free(ret);
		return NULL;
	}

	if (fscanf(fp, "%d %d", &ret->cols, &ret->rows) != 2)
	{
		fprintf(stderr, "Error: Unable to read the number of rows and columns.\n");
		fclose(fp);
		free(ret);
		return NULL;
	}

	int max_value;
	if (fscanf(fp, "%d", &max_value) != 1 || max_value != 255)
	{
		printf("filename is an ASCII PPM file (type P3) with maximum value 255.\n");
		fclose(fp);
		free(ret);
		return NULL;
	}

	ret->image = malloc(ret->rows * sizeof(Color *));
	if (ret->image == NULL)
	{
		free(ret);
		fclose(fp);
		allocation_failed();
		return NULL;
	}

	for (int i = 0; i < ret->rows; i++)
	{
		ret->image[i] = malloc(ret->cols * sizeof(Color));
		if (ret->image[i] == NULL)
		{
			for (int k = 0; k < i; k++)
			{
				free(ret->image[k]);
			}
			allocation_failed();
			fclose(fp);
			free(ret->image);
			free(ret);
			return NULL;
		}

		for (int j = 0; j < ret->cols; j++)
		{
			Color *color = &ret->image[i][j];
			if (fscanf(fp, "%hhu %hhu %hhu", &color->R, &color->G, &color->B) != 3)
			{
				for (int k = 0; k < i; k++)
				{
					free(ret->image[k]);
				}
				fprintf(stderr, "incorrect PPM format");
				fclose(fp);
				free(ret->image);
				free(ret);
				return NULL;
			}
		}
	}
	fclose(fp);
	return ret;
}

// Given an image, prints to stdout (e.g. with printf) a .ppm P3 file with the image's data.
void writeData(Image *image)
{
	// YOUR CODE HERE
	printf("P3\n");
	printf("%d %d\n", image->cols, image->rows);
	printf("255\n");
	Color **colors = image->image;
	for (int i = 0; i < image->rows; i++)
	{
		for (int j = 0; j < image->cols; j++)
		{
			Color color = colors[i][j];
			printf("%3hhu %3hhu %3hhu", color.R, color.G, color.B);
			if (j != image->cols - 1)
			{
				printf("   ");
			}
		}
		printf("\n");
	}
}

// Frees an image
void freeImage(Image *image)
{
	// YOUR CODE HERE
	for (int i = 0; i < image->rows; i++)
	{
		free(image->image[i]);
	}
	free(image->image);
	free(image);
}

static void allocation_failed()
{
	fprintf(stderr, "Out of memory.\n");
}
