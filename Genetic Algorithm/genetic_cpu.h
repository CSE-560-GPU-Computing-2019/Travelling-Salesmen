#ifndef __GENETIC_CPU_H__
#define __GENETIC_CPU_H__

#include "grid.h"


void mutate(Town* child, int* rand_nums);
void crossover(Town** parents, Town* child, int cities, int cross_over);
void execute(float prob_mutation, float prob_crossover, int population,int max_gen, Grid* grid, int seed);
void selection(Grid* pop, int population, Town** parents, float* rand_nums);

#endif