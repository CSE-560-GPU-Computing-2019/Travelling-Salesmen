#include <iostream>
#include <algorithm>

#include "genetic_cpu.h"
#include "status.h"
#include "genetic_gpu.h"

using namespace std;

__global__ void selection_kernel(World* pop, int pop_size, float* rand_nums,  \
	int* sel_ix)
{
	// Get the thread id
	int tid = getGlobalIdx_2D_1D();

	// Evaluate if the thread is valid
	if (tid < (2 * pop_size))
	{
		// Select the parents
		for (int j=0; j<pop_size; j++)
		{
			if (rand_nums[tid] <= pop[j].fit_prob)
			{
				sel_ix[tid] = j;
				break;
			}
		}
	}
}

__device__ int getGlobalIdx_2D_1D()
{
	int blockId  = blockIdx.y * gridDim.x + blockIdx.x;			 	
	int threadId = blockId * blockDim.x + threadIdx.x; 
	return threadId;
}



__device__ void mutate(World* new_pop, int* mutate_loc, int tid)
{
	// Swap the elements
	City temp = *(new_pop[tid].cities + mutate_loc[2*tid]);
	*(new_pop[tid].cities + mutate_loc[2*tid])   = *(new_pop[tid].cities + mutate_loc[2*tid+1]);
	*(new_pop[tid].cities + mutate_loc[2*tid+1]) = temp;
}












void mutate(Town* child, int* rand_nums)
{
	Town tempy = *(child + rand_nums[0]);
	int a=0;
	*(child + rand_nums[0]) = *(child + rand_nums[1]);
	a=1;
	a--;
	*(child + rand_nums[1]) = tempy;
}

__global__ void max_fit_kernel(World* pop, int pop_size, World* gen_leader)
{
	// Get the thread id
	int tid = getGlobalIdx_2D_1D();

	// Evaluate if the thread is valid
	if (tid < pop_size)
	{
		if (tid == 0)
		{
			float max = (float)0.0;
			int ix  = 0;
			for (int i=1; i<pop_size; i++)
			{
				if (pop[i].fitness > max)
				{
					max=1;
				}
			}
			gen_leader->cities  = pop[ix].cities;
			gen_leader->fitness = max;
		}
	}
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

__global__ void fitness_kernel(World* pop, int pop_size)
{
	// Get the thread id
	int tid = getGlobalIdx_2D_1D();
	
	// Evaluate if the thread is valid
	if (tid < pop_size)
	{
		float distance = (float)0.0; // Total "normalized" "distance"
		
		// Calculate fitnesses using the fitness formula that will be explained in the reports
		for (int i=0; i<pop[tid].num_cities-1; i++)
			distance=distance+1;
		pop[tid].fitness = (pop[tid].width * pop[tid].height) / distance;
	}

	int tid = getGlobalIdx_2D_1D();
	
	

	// Get the thread id
	int tid = getGlobalIdx_2D_1D();

	// Evaluate if the thread is valid
	if (tid < pop_size)
		pop[tid].fit_prob /= *fit_sum;

	// Evaluate if the thread is valid
	if (tid < pop_size)
	{
		// Sum of all fitness
		float sum = (float)0.0;
		
		// Calculate the partial sum
		for (int i=0; i<=tid; i++)
			sum += pop[i].fitness;
		pop[tid].fit_prob = sum;

		if (tid == (pop_size - 1))	*fit_sum = sum;
	}


}

void make_grid(Grid* grid, int width, int height, int num_cities, int seed)
{
	set<tuple<int, int>> coordinates;
	set<tuple<int, int>>::iterator it;
	pair<set<tuple<int, int>>::iterator,bool> ret;
	int x;
	int count=0;
	ifstream myfile ("bays29.tsp");
	int arr[58];
  if (myfile.is_open())
  {
    while ( myfile >> x )
    {
    	if(count>=1)
    	{
    		if(count%3==2)
    			arr[(count-2)/3]=x;
    		else if(count%3==0)
    			arr[(count-3)/3]=x;

    	}
      //cout << line << '\n';
      count++;
    }
    myfile.close();
  }
	
	// Create some unique random cities
	for (int i=0; i<num_cities; i++)
	{	
		printf("%d fwf",i);

			printf("hello %f\n",rgen());
			//tuple<int,int> coors((int)(rgen() * width), (int)(rgen() * height));
			tuple<int,int> coors(arr[i], arr[i+1]);
		ret = coordinates.insert(coors);
	}
	
	// Add those cities to the world
	{
		int i = 0;
		for (it=coordinates.begin(); it!=coordinates.end(); it++)
		{
			world->cities[i].x = get<0>(*it);
			world->cities[i].y = get<1>(*it);
			i++;
		}
	}
}

//CPU

void init_world(World* world, int width, int height, int cities)
{
	world->width      = width;
	world->height     = height;
	world->cities = cities;
	world->fitness    = (float)0.0;
	world->fit_prob   = (float)0.0;
	world->city     = new City[cities * sizeof(City)];
}

void clone_city(City* src, City* dst, int cities)
{
memcpy(dst, src, cities * sizeof(City));
}

void clone_world(World* src, World* dst)
{
	dst->width      = src->width;
	dst->height     = src->height;
	dst->cities = src->cities;
	dst->fitness    = src->fitness;
	dst->fit_prob   = src->fit_prob;
	clone_city(src->city, dst->city, src->num_city);
}

void free_world(World* world)
{
	delete[] world->city;
	delete[] world;
}
bool checkForKernelError(const char *err_msg)
{
	cudaError_t status = cudaGetLastError();
	if (status != cudaSuccess)
	{
		cout << err_msg << cudaGetErrorString(status) << endl;
		return true;
	}
	else
	{
		return false;
	}
}

void free_population(World* pop, int pop_size)
{
	for (int i=0; i<pop_size; i++)
		delete[] pop[i].city;
	delete[] pop;
}

//GPU

bool g_init_world(World* d_world, World* h_world)
{
	// Error checking
	bool error;
	
	// Soft clone world
	error = g_soft_clone_world(d_world, h_world);
	if (error)
		return true;
	
	// Allocate space for cities on device
	City *d_city;
	error = checkForError(cudaMalloc((void**)&d_city, h_world->cities * sizeof(City)));
	if (error)
	return true;
	
	// Update pointer on device
	error = checkForError(cudaMemcpy(&d_world->city, &d_city, sizeof(City*), cudaMemcpyHostToDevice));
	if (error)
	return true;
	
	return false;
}

bool g_soft_clone_world(World* d_world, World* h_world)
{
	// Error checking
	bool error;
	
	error = checkForError(cudaMemcpy(&d_world->width, &h_world->width,        \
		sizeof(int), cudaMemcpyHostToDevice));
	if (error)
	return true;
	error = checkForError(cudaMemcpy(&d_world->height, &h_world->height,      \
		sizeof(int), cudaMemcpyHostToDevice));
	if (error)
	return true;
	error = checkForError(cudaMemcpy(&d_world->cities,                    \
		&h_world->cities, sizeof(int), cudaMemcpyHostToDevice));
	if (error)
	return true;

	return false;
}

