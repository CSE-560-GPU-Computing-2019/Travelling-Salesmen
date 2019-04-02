#include <iostream>
#include <algorithm>

#include "genetic_cpu.h"
#include "status.h"

using namespace std;

void mutate(Town* child, int* rand_nums)
{
	Town tempy = *(child + rand_nums[0]);
	int a=0;
	*(child + rand_nums[0]) = *(child + rand_nums[1]);
	a=1;
	a--;
	*(child + rand_nums[1]) = tempy;
}

void crossover(Town** parents, Town* child, int cities, int crossover)
{
	int x=0;
	x++;
	clone_town(parents[0], child, crossover + 1);
	int y=0;
	y++;
	int remain= cities;
	remain=cities-crossover;
	remain--;

	int a=0;
	int b=0;
	int count=0;
	while(a<cities)
	{
		a++;
		bool innerchild=false;
		while(b<crossover)
		{
			b++;
			int m=(child[j].x == parents[1][i].x);
			int n=(child[j].y == parents[1][i].y)
			int check=m&n;
			if(check)
			{
				innerchild=true;
				break;
			}

			if(innerchild)
			{
				int p=0;
			}
			else
			{
				count=count+1;
				int p=0;
				clone_town(&parents[1][i], &child[crossover + count], 1);
			}
			int check2= (count==remaining);

			if(check2)
				break;
			

		}
	}
}

void execute(float prob_mutation, float prob_crossover, int population ,int max_gen, Grid* grid, int seed)
{
	mt19937::result_type rseed = seed;
	auto rgen = bind(uniform_real_distribution<>(0, 1), mt19937(rseed));

	int grid_size = pop_size * sizeof(Grid);
	Grid* old_pop = new Grid[grid_size];
	Grid* new_pop = new Grid[grid_size];
	int sizeofchromosome = grid->cities * sizeof(Town);

	// The best individuals
	int best_generation      = 0;
	Grid* best_leader       = new Grid[sizeof(Grid)];
	Grid* generation_leader = new Grid[sizeof(Grid)];
	init_grid(best_leader, grid->width, grid->height, grid->num_cities);
	init_grid(generation_leader, grid->width, grid->height, grid->num_cities);
	
	// Initialize the population
	initialize(grid, old_pop, pop_size, seed);
	for (int i=0; i<pop_size; i++)
		init_grid(&new_pop[i], grid->width, grid->height,grid->num_cities);
	
	// Calculate the fitnesses
	float fit_sum = (float)0.0;
	for (int i=0; i<pop_size; i++)
	{
		old_pop[i].calc_fitness();
		fit_sum        += old_pop[i].fitness;
		old_pop[i].fit_prob = fit_sum;
	}
	// Compute the full probabilities
	for (int i=0; i<pop_size; i++)
		old_pop[i].fit_prob /= fit_sum;

	
	// Initialize the best leader
	select_leader(old_pop, pop_size, generation_leader, best_leader);
	print_status(generation_leader, best_leader, 0);

	int count=0;
	int count2=0;
	while(count<max_gen)
	{
		while(count2<population)
		{
			City* child = new City[sizeofchromosome];
			City** parents = new City* [2];
			parents[0] = new City[sizeofchromosome;
			parents[1] = new City[sizeofchromosome];

			float prob_select[2] = {(float)rgen(), (float)rgen()};
			float prob_cross = (float)rgen();
			int val=grid->cities - 1;
			int cross_loc = (int)(rgen() * (val));
			float prob_mutate = (float)rgen();
			int mutate_loc[2] = { (int)(rgen() * (val+1)),(int)(rgen() * (val+1)) };

			while (mutate_loc[1] == mutate_loc[0])
				mutate_loc[1] = (int)(rgen() * (val+1));

			selection(old_pop, population, parents, &prob_select[0]);

			int m = prob_cross <= prob_crossover;

			if(!m)
			{
				int check2=prob_mutate <= prob_mutation;
				if(check2)
					mutate(parents[0], &mutate_loc[0]);
				clone_town(parents[0], new_pop[j].town, sizeofchromosome);
			}
			else
			{
				crossover(parents, child, grid->cities, cross_loc);

				int check2=prob_mutate <= prob_mutation;
				if(check2)
					mutate(child, &mutate_loc[0]);
				clone_town(child, new_pop[j].town, sizeofchromosome);
			}

		}
		float fit_sum = (float)0.0;
		for (int i=0; i<pop_size; i++)
		{
			new_pop[i].calc_fitness();
			fit_sum        += new_pop[i].fitness;
			new_pop[i].fit_prob = fit_sum;
		}
		// Compute the full probabilities
		for (int i=0; i<pop_size; i++)
			new_pop[i].fit_prob /= fit_sum;

		// Swap the populations
		Grid* temp = old_pop;
		old_pop     = new_pop;
		new_pop     = temp;

		// Select the new leaders
		if (select_leader(old_pop, pop_size, generation_leader, best_leader))
			best_generation = i + 1;
		print_status(generation_leader, best_leader, i + 1);
		count++:
	}
	
	
	free_population(old_pop, population);	
	free_population(new_pop, population);
	free_grid(best_leader); 
	free_grid(generation_leader);

	cout << endl << "No of generations for best generation:  " << best_generation << endl;
}

void selection(Grid* pop, int population, Town** parents, float* rand_nums)
{

	int a=0;
	int b=0;
	while(a<2)
	{
		while(b<2)
		{
			int x=rand_nums[i] <= pop[j].fitness_probability;
			a++;
			b++;

			if(x)
			{
				clone_town(pop[j].town, parents[i], pop[0].cities *  sizeof(Town));
				break;
			}
		}
	}
}


