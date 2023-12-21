/************************************************************************
**
** NAME:        gameoflife.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Justin Yokota - Starter Code
**				YOUR NAME HERE
**
**
** DATE:        2020-08-23
**
**************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include "imageloader.h"

// Return the nth bit of x.
// Assume 0 <= n <= 31
unsigned getBit(unsigned x,
								unsigned n)
{
	x = x >> n;
	return x & 1;
}

// Set the nth bit of the value of x to v.
// Assume 0 <= n <= 31, and v is 0 or 1
void setBit(unsigned *x,
						unsigned n,
						unsigned v)
{
	unsigned mask = ~(1 << n);
	*x = (*x & mask) | (v << n);
}

uint32_t getWrappedIndex(uint32_t index, uint32_t total)
{
	return (index + total) % total;
}

// Combines RGB color to a single uint32_t value
// Like 00000000 RRRRRRRR GGGGGGGG BBBBBBBB
uint32_t color2PackedColor(Color *color)
{
	return (((uint32_t)color->R << 16) | ((uint32_t)color->G << 8)) | (uint32_t)color->B;
}

Color *packedColor2Color(uint32_t packedColor)
{
	Color *ret = malloc(sizeof(Color));
	if (ret == NULL)
	{
		allocation_failed();
		return NULL;
	}
	ret->R = (packedColor >> 16) & 255;
	ret->G = (packedColor >> 8) & 255;
	ret->B = packedColor & 255;
	return ret;
}

// Determines what color the cell at the given row/col should be. This function allocates space for a new Color.
// Note that you will need to read the eight neighbors of the cell in question. The grid "wraps", so we treat the top row as adjacent to the bottom row
// and the left column as adjacent to the right column.
Color *evaluateOneCell(Image *image, int row, int col, uint32_t rule)
{
	// YOUR CODE HERE
	int topRowIndex = getWrappedIndex(row - 1, image->rows);
	int leftColIndex = getWrappedIndex(col - 1, image->cols);
	int bottomRowIndex = getWrappedIndex(row + 1, image->rows);
	int rightColIndex = getWrappedIndex(col + 1, image->cols);
	uint32_t top = color2PackedColor(&image->image[topRowIndex][col]);
	uint32_t left = color2PackedColor(&image->image[row][leftColIndex]);
	uint32_t bottom = color2PackedColor(&image->image[bottomRowIndex][col]);
	uint32_t right = color2PackedColor(&image->image[row][rightColIndex]);
	uint32_t topLeft = color2PackedColor(&image->image[topRowIndex][leftColIndex]);
	uint32_t topRight = color2PackedColor(&image->image[topRowIndex][rightColIndex]);
	uint32_t bottomLeft = color2PackedColor(&image->image[bottomRowIndex][leftColIndex]);
	uint32_t bottomRight = color2PackedColor(&image->image[bottomRowIndex][rightColIndex]);

	uint32_t packedColor = color2PackedColor(&image->image[row][col]);
	uint32_t newPackedColor = 0;
	for (int i = 0; i < 24; i++)
	{
		unsigned currentBit = getBit(packedColor, i);
		unsigned topBit = getBit(top, i);
		unsigned bottomBit = getBit(bottom, i);
		unsigned leftBit = i == 23 ? getBit(left, 0) : getBit(packedColor, i + 1);
		unsigned rightBit = i == 0 ? getBit(right, 23) : getBit(packedColor, i - 1);
		unsigned topLeftBit = i == 23 ? getBit(topLeft, 0) : getBit(top, i + 1);
		unsigned topRightBit = i == 0 ? getBit(topRight, 23) : getBit(top, i - 1);
		unsigned bottomLeftBit = i == 23 ? getBit(bottomLeft, 0) : getBit(bottom, i + 1);
		unsigned bottomRightBit = i == 0 ? getBit(bottomRight, 23) : getBit(bottom, i - 1);
		unsigned liveNeighborCount = topBit + bottomBit + leftBit + rightBit + topLeftBit + topRightBit + bottomLeftBit + bottomRightBit;
		if (getBit(currentBit == 0 ? rule : (rule >> 9), liveNeighborCount) == 1)
		{
			setBit(&newPackedColor, i, 1);
		}
	}
	return packedColor2Color(newPackedColor);
}

// The main body of Life; given an image and a rule, computes one iteration of the Game of Life.
// You should be able to copy most of this from steganography.c
Image *life(Image *image, uint32_t rule)
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
			Color *new_color = evaluateOneCell(image, i, j, rule);
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
Loads a .ppm from a file, computes the next iteration of the game of life, then prints to stdout the new image.

argc stores the number of arguments.
argv stores a list of arguments. Here is the expected input:
argv[0] will store the name of the program (this happens automatically).
argv[1] should contain a filename, containing a .ppm.
argv[2] should contain a hexadecimal number (such as 0x1808). Note that this will be a string.
You may find the function strtol useful for this conversion.
If the input is not correct, a malloc fails, or any other error occurs, you should exit with code -1.
Otherwise, you should return from main with code 0.
Make sure to free all memory before returning!

You may find it useful to copy the code from steganography.c, to start.
*/
int main(int argc, char **argv)
{
	// YOUR CODE HERE
	if (argc != 3)
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

	u_int32_t rule = (u_int32_t)strtol(argv[2], NULL, 16);
	Image *newImage = life(originalImage, rule);
	if (newImage == NULL)
	{
		exit(1);
	}

	writeData(newImage);
	return 0;
}
