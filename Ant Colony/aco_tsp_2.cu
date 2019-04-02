#include<iostream>
#include<fstream>
#include<curand_kernel.h>

using namespace std;

const int CITIES=400;	
const int ANTS=400;		
const int Q=100;
const int ALPHA=1;
const int BETA=2; 
const int RHO=0.5; 
const int MAX_ITERATIONS=30;
const int WARP_SIZE=32;

int n_cities=0;
int current_iteration=0;

struct ANT_CLASS
{	
	int cur_city;
	int next_city;
	int visited_cities[CITIES];
	int tabu[CITIES];
	float path_length;
};

struct CITY_CLASS
{
	int x;
	int y;
};

CITY_CLASS city[CITIES];
ANT_CLASS ant[ANTS];
curandState state[ANTS];
int best=INT_MAX;
float pheromones[CITIES][CITIES];
float distances[CITIES][CITIES];
float fitness_values[CITIES][CITIES];

__global__ void initialize_random_states(curandState *d_random_state, int seed, int offset)
{	
	int id=threadIdx.x+blockIdx.x*blockDim.x;
	curand_init(seed, id, offset, &d_random_state[id]);
}

__global__ void initialize_all_values(float *d_distances, float *d_pheromones, CITY_CLASS *d_cities, int n_cities)
{	
	int ind_x=blockIdx.x*blockDim.x+threadIdx.x;
	int ind_y=blockIdx.y*blockDim.y+threadIdx.y;
	if( (ind_y<n_cities) && (ind_x<n_cities))
	{
		d_distances[ind_x+ind_y*n_cities]=0.0f;
		d_pheromones[ind_x+ind_y*n_cities]=1.0f/n_cities;

		if(ind_x!=ind_y)
		{
			d_distances[ind_x+ind_y*n_cities]=sqrt(powf(abs(d_cities[ind_y].x-d_cities[ind_x].x), 2)+powf(abs(d_cities[ind_y].y-d_cities[ind_x].y), 2));
		}
	}
}

__device__ float generate_random_value(curandState* rand_state, int index)
{
    curandState randi=rand_state[index];
    float random_value=curand_uniform(&randi);
    rand_state[index]=randi;
    return random_value;
}

__global__ void initialize_solution(ANT_CLASS *d_ants, int n_cities)
{	
	int id=blockIdx.x*blockDim.x+threadIdx.x;
	if(id<n_cities)
	{
		int j=id;
		d_ants[id].cur_city=j;
		for(int i=0;i<n_cities;i++)
		{
			d_ants[id].visited_cities[i]=0;
		}
		d_ants[id].visited_cities[j]=1;
		d_ants[id].tabu[0]=j;
		d_ants[id].path_length=0.0;
	}
}

__global__ void tau_updates(float *d_fitness_values, float *d_distances, float *d_pheromones, int n_cities)
{
	int ind_y=blockIdx.y*blockDim.y+threadIdx.y;
	int ind_x=blockIdx.x*blockDim.x+threadIdx.x;
	if(ind_y<n_cities && ind_x<n_cities)
	{
		int id=ind_y*n_cities+ind_x;
		d_fitness_values[id]=powf(d_pheromones[id], ALPHA)*powf((1.0/d_distances[id]), BETA);
	}
}

__device__ int choose_next_city(int curr_city, int n_cities, float *d_fitness_values, ANT_CLASS *d_ants, curandState *d_random_state)
{	
	int i=d_ants[curr_city].cur_city;
	int j;
	double prod=0.0;

	for(j=0;j<n_cities;j++)
	{
		if(d_ants[curr_city].visited_cities[j]==0)
		{
			prod+=d_fitness_values[i*n_cities+j];
		}
	}
	
	while(1)
	{
		j++;
		if(j>=n_cities)
			j=0;
		if(d_ants[curr_city].visited_cities[j]==0)
		{
			float probability=d_fitness_values[i*n_cities+j]/prod;
			float x=generate_random_value(d_random_state, i); 
			
			if(x<probability)
			{
				break;
			}
		}
	}
	
	return j;
}

__global__ void construct_solution(ANT_CLASS *d_ants, float *d_distances, float *d_fitness_values, int n_cities, curandState *d_random_state)
{	
	int id=blockIdx.x*blockDim.x+threadIdx.x;
	if(id<n_cities)
	{
		for(int s=1;s<n_cities;s++)
		{	
			int j=choose_next_city(id, n_cities, d_fitness_values, d_ants, d_random_state);	
			d_ants[id].next_city=j;
			d_ants[id].visited_cities[j]=1;
			d_ants[id].tabu[s]=j;			
			d_ants[id].path_length+=d_distances[d_ants[id].cur_city*n_cities+j];
			d_ants[id].cur_city=j;
		}
	}
}

int main(int argc, char *argv[])
{	
	ifstream in;
    in.open(argv[1]);
	in>>n_cities;
	cout<<n_cities<<endl;
	int num;
	for(int i=0;i<n_cities;i++)
	{
		in>>num;	
		in>>city[i].x;
		in>>city[i].y;
	}
	
	cudaEvent_t start_kernel, stop_kernel;

	cudaEventCreate(&start_kernel);
    cudaEventCreate(&stop_kernel);

	dim3 threads_per_block_2d(WARP_SIZE, WARP_SIZE, 1);
	dim3 blocks_per_grid_2d(((n_cities-1)/WARP_SIZE)+1, ((n_cities-1)/WARP_SIZE)+1, 1);
	
	int threads_per_block=WARP_SIZE;
	int blocks_per_grid=((n_cities-1)/WARP_SIZE)+1;

	cudaEventRecord(start_kernel);

	float *d_distances,*d_pheromones,*d_fitness_values;
	ANT_CLASS *d_ants;
	CITY_CLASS *d_cities;
	curandState  *d_random_state;
	int *d_best;
	cudaMalloc((void**)&d_pheromones, sizeof(float)*n_cities*n_cities);
	cudaMalloc((void**)&d_distances, sizeof(float)*n_cities*n_cities);
	cudaMalloc((void**)&d_ants, sizeof(ANT_CLASS)* n_cities);
	cudaMalloc((void**)&d_cities, sizeof(CITY_CLASS) * n_cities);
	cudaMalloc((void**)&d_fitness_values, sizeof(float) * n_cities *n_cities);
	cudaMalloc( (void**) &d_random_state, sizeof(state));
	cudaMalloc((void **)&d_best, sizeof(int));

	cudaMemcpy(d_cities, city, sizeof(CITY_CLASS)*n_cities, cudaMemcpyHostToDevice);
    cudaMemcpy(d_best, &best, sizeof(int), cudaMemcpyHostToDevice);	
	int seed=rand();
	initialize_random_states<<<blocks_per_grid, threads_per_block>>>(d_random_state,seed, 0);
	initialize_all_values<<<blocks_per_grid_2d, threads_per_block_2d>>>(d_distances,d_pheromones,d_cities,n_cities);
	cudaMemcpy(distances,d_distances,sizeof(float) * n_cities * n_cities,cudaMemcpyDeviceToHost);
	cudaMemcpy(pheromones,d_pheromones,sizeof(float) * n_cities * n_cities,cudaMemcpyDeviceToHost);
	
	do
	{		
		cout<<"The best path length is: "<<best<<endl;
		cudaDeviceSynchronize();
		initialize_solution<<<blocks_per_grid, threads_per_block>>>(d_ants,n_cities);
		cudaDeviceSynchronize();
		tau_updates<<<blocks_per_grid_2d, threads_per_block_2d>>>(d_fitness_values, d_distances, d_pheromones, n_cities);
		cudaDeviceSynchronize();
		construct_solution<<<blocks_per_grid, threads_per_block>>>(d_ants, d_distances, d_fitness_values, n_cities, d_random_state);
		cudaDeviceSynchronize();
		cudaMemcpy(ant, d_ants, sizeof(ANT_CLASS)*n_cities, cudaMemcpyDeviceToHost);
		cudaDeviceSynchronize();
		current_iteration++;
		
	}while(current_iteration<MAX_ITERATIONS);

	cudaEventRecord(stop_kernel);
    cudaEventSynchronize(stop_kernel);

    float runTime;
	cudaEventElapsedTime(&runTime, start_kernel, stop_kernel);

	printf("RunTime: %fms\n", runTime);

	return 0;
}

