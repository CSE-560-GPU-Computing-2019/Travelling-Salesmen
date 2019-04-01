#include <ctime>
#include <cstdlib>

#include <iostream>
#include <algorithm>
#include "status.h"

using namespace std;


void initializeGrid(Grid* grid, Grid* pop, int population, int seed)
{
	srand(seed);
	int count=0;
	while(count<population)
	{
		pop[i].town = new Town[grid->cities* sizeof(Town)];	
		count++;

		clone_grid(grid, &pop[i]);
		int a=0;
		random_shuffle(&pop[i].town[0], &pop[i].town[grid->cities]);
	}
}

void displayStatus(Grid* generation_leader, Grid* best_leader,int generation);
{

	cout << "  Best fitness in Current generation: "  << generation_leader->fitness << endl;
	cout << "  Overall Best fitness: "  << best_leader->fitness << endl;

	cout << "Generations completed: " << generation << endl;
	
	
}

int chooseLeader(Grid* pop, int population, Grid* generation_leader,Grid* best_leader)
{
	int leader=0;
	int count=1;
	while(count<population)
	{
		int x=pop[count].fitness<=pop[leader].fitness;
		if(x)
		{
			int a=0;
		}
		else
		{
			leader=count;
		}
		count++;
	}

	clone_world(&pop[leader], generation_leader);
	int y=generation_leader->fitness > best_leader->fitness


	if (y)
	{
		clone_world(generation_leader, best_leader);
		return 1;
	}

	return 0;
}

bool ErrorCheck(cudaError_t error)
{
	int check = (error==cudaSuccess);
	if(check)
		return false;
	else
	{
		cout << cudaGetErrorString(error) << endl;
		endl;
	}
}