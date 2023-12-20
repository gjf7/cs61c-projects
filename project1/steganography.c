/************************************************************************
**
** NAME:        steganography.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Dan Garcia  -  University of California at Berkeley
**              Copyright (C) Dan Garcia, 2020. All rights reserved.
**				Justin Yokota - Starter Code
**				YOUR NAME HERE
**
** DATE:        2020-08-23
**
**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include "imageloader.h"

// Determines what color the cell at the given row/col should be. This should not affect Image, and should allocate space for a new Color.
Color *evaluateOnePixel(Image *image, int row, int col)
{
	// YOUR CODE HERE
	Color *new_color = malloc(sizeof(Color));
	if (new_color == NULL)
	{
		allocation_failed();
		return NULL;
	}

	if ((image->image[row][col].B & 1) == 1)
	{
		new_color->R = new_color->G = new_color->B = 255;
	}
	else
	{

		new_color->R = new_color->G = new_color->B = 0;
	}
	return new_color;
}
// Given an image, creates a new image extracting the LSB of the B channel.
Image *steganography(Image *image)
{
	// YOUR CODE HERE
	Image *new_image = malloc(sizeof(Image));
	if (new_image == NULL)
	{
		allocation_failed();
		return NULL;
	}

	new_image->rows = image->rows;
	new_image->cols = image->cols;

	new_image->image = malloc(image->rows * sizeof(Color *));
	if (new_image->image == NULL)
	{
		free(new_image);
		allocation_failed();
		return NULL;
	}
	for (int i = 0; i < image->rows; i++)
	{
		new_image->image[i] = malloc(image->cols * sizeof(Color));
		if (new_image->image[i] == NULL)
		{
			for (int k = 0; k < i; k++)
			{
				free(new_image->image[k]);
			}
			free(new_image->image);
			free(new_image);
			allocation_failed();
			return NULL;
		}
		for (int j = 0; j < image->cols; j++)
		{
			Color *new_color = evaluateOnePixel(image, i, j);
			if (new_color != NULL)
			{
				new_image->image[i][j] = *new_color;
				free(new_color);
			}
			else
			{
				for (int k = 0; k <= i; k++)
				{
					free(new_image->image[k]);
				}
				free(new_image->image);
				free(new_image);
				return NULL;
			}
		}
	}
	return new_image;
}

/*
Loads a file of ppm P3 format from a file, and prints to stdout (e.g. with printf) a new image,
where each pixel is black if the LSB of the B channel is 0,
and white if the LSB of the B channel is 1.

argc stores the number of arguments.
argv stores a list of arguments. Here is the expected input:
argv[0] will store the name of the program (this happens automatically).
argv[1] should contain a filename, containing a file of ppm P3 format (not necessarily with .ppm file extension).
If the input is not correct, a malloc fails, or any other error occurs, you should exit with code -1.
Otherwise, you should return from main with code 0.
Make sure to free all memory before returning!
*/
int main(int argc, char **argv)
{
	// YOUR CODE HERE
	if (argc != 2)
	{
		printf("usage: %s filename\n", argv[1]);
		printf("filename is an ASCII PPM file (type P3) with maximum value 255.\n");
		exit(-1);
	}
	char *filename = argv[1];
	Image *originalImage = readData(filename);
	if (originalImage == NULL)
	{
		exit(1);
	}

	Image *newImage = steganography(originalImage);
	if (newImage == NULL)
	{
		exit(1);
	}

	writeData(newImage);
	return 0;
}
