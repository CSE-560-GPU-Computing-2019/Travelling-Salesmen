#include <ctime>
#include <iostream>
#include <string.h>
#include <sstream>
#include <cstring>
#include <string>
#include <cstdio>
#include "common.h"
#include "ga_cpu.h"

using namespace std;

int main()
{
	int cities=29;
	int population=100000;
	int generations=150;
	int width=10000;
	int height=10000;
	int grid_seed = 12438955;
	int ga_seed = 87651111;
	float prob_mutation  = (float)0.15; 
	float prob_crossover = (float)0.8;  

	Grid* grid = new Grid[sizeof(Grid)];
	make_grid(grid,width,height, cities, grid_seed);

	execute(prob_mutation, prob_crossover, population, generations, grid, ga_seed);

	free_grid(grid);

	return 0;
}
