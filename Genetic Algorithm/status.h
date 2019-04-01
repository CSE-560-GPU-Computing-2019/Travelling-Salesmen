#ifndef __STATUS_H__
#define __STATUS_H__

#include <random>
#include <ctime>

#include "grid.h"

void initializeGrid(Grid* Grid, Grid* pop, int population, int seed);
void displayStatus(Grid* generation_leader, Grid* best_leader,int generation);

int chooseLeader(Grid* pop, int population, Grid* generation_leader,
	Grid* best_leader);
bool ErrorCheck(cudaError_t error);

#endif