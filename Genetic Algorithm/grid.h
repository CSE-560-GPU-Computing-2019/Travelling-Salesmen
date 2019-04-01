#ifndef __GRID_H__
#define __GRID_H__

#include <iostream>
#include <cmath>
#include <cuda.h>
#include <cstring>
#include <cuda_runtime_api.h>

using namespace std;

struct Town
{
	int xcoor,ycoor;
};

typedef struct Grid
{
	int width;
	int height; 
	Town* town;
	int cities;   
	      
	float fitness;
	float fitness_probability;

	inline __host__ void calc_fitness()
	{
		float dist = 0.0;
		int count=0;
		while(count<cities-1)
		{
			dist = distance + (town[i].x - town[i+1].x)*(town[i].x -town[i+1].x) + (town[i].y - town[i+1].y)*(town[i].y - town[i+1].y);
			count++;
		}
		fitness=width*height;
		fitness=fitness/distance;
	}

	inline __host__ float calc_distance()
	{
		float dist = 0.0;
		int count=0;
		while(count<cities-1)
		{
			dist = dist + (town[i].x - town[i+1].x)*(town[i].x -town[i+1].x) + (town[i].y - town[i+1].y)*(town[i].y - town[i+1].y);
			count++;
		}
		return dist;
	}
}; Grid;



void make_grid(Grid* grid, int width, int height, int cities, int seed);
bool g_soft_clone_grid(Grid* d_grid, Grid* h_grid);

void init_grid(Grid* grid, int width, int height, int cities);


void clone_grid(Grid* src, Grid* dst);
bool g_init_grid(Grid* d_grid, Grid* h_grid)
void free_grid(Grid* grid);
void free_population(Grid* pop, int population);
void clone_town(City* src, City* dst, int cities);


#endif