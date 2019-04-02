#include<iostream>
#include<fstream>
#include<math.h>
#include<stdlib.h>
#include<time.h>

using namespace std;

const int CITIES=400;	
const int ANTS=400;		
const int Q=100;
const int ALPHA=1;
const int BETA=2; 
const int RHO=0.5; 
const int MAX_ITERATIONS=30;
const int WARP_SIZE=32;

int current_iteration=0;
int n_cities=0;

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

CITY_CLASS d_cities[CITIES];
ANT_CLASS d_ants[ANTS];
int best=999999;
float d_pheromones[CITIES][CITIES];
float d_distances[CITIES][CITIES];

void initialize_all_values()
{	
	for(int i=0;i<CITIES;i++)
	{
		for(int j=0;j<CITIES;j++)
		{
			d_distances[i][j]=0.0f;
			d_pheromones[i][j]=1.0f/n_cities;

			if(i!=j)
			{
				d_distances[i][j]=sqrt(powf(abs(d_cities[i].x-d_cities[j].x), 2)+powf(abs(d_cities[i].y-d_cities[j].y), 2));
			}
		}
	}
}

void initialize_solution()
{	
	for(int k=0;k<ANTS;k++)
	{
		int ran=rand();
		int j=ran%CITIES;
		d_ants[k].cur_city=j;
		for(int i=0;i<n_cities;i++)
		{
			d_ants[k].visited_cities[i]=0;
		}
		d_ants[k].visited_cities[j]=1;
		d_ants[k].tabu[0]=j;
		d_ants[k].path_length=0.0;
	}
}

double tau_update(int node1, int node2)
{
	double return_value=pow(d_pheromones[node1][node2], ALPHA)*pow((1.0/ d_distances[node1][node2]), BETA);
	return return_value;
}

int choose_next_city(int curr_city, int n_cities)
{	
	int i=d_ants[curr_city].cur_city;
	int j;
	double prod=0.0;

	for(j=0;j<n_cities;j++)
	{
		if(d_ants[curr_city].visited_cities[j]==0)
		{
			prod+=tau_update(i, j);
		}
	}
	
	while(1)
	{
		j++;
		if(j>=n_cities)
			j=0;
		if(d_ants[curr_city].visited_cities[j]==0)
		{
			double probability=tau_update(i, j)/prod;
			double x=((double)rand()/RAND_MAX);
			
			if(x<probability)
			{
				break;
			}
		}
	}
	
	return j;
}

void construct_solution()
{	
	int j;
	for(int s=1;s<n_cities;s++)
	{	
		for(int k=0;k<ANTS;k++)
		{
			int j=choose_next_city(k, n_cities);	
			d_ants[k].next_city=j;
			d_ants[k].visited_cities[j]=1;
			d_ants[k].tabu[s]=j;			
			d_ants[k].path_length+=d_distances[d_ants[k].cur_city][j];
			d_ants[k].cur_city=j;	
		}
	}
}

int main(int argc, char *argv[])
{	if (argc > 1){
		cout << "Reading File "<< argv[1]<<endl;
	}
	else{
		cout << "Usage:progname inputFileName" <<endl;
		return 1;
	}
	ifstream in;
    in.open(argv[1]);
	in>>n_cities;
	int num;
	for(int i=0;i<n_cities;i++)
	{
		in>>num;	
		in>>d_cities[i].x;
		in>>d_cities[i].y;
	}
	initialize_all_values();
	int MAX_ITERATIONS=30;
	for(;;)
	{   srand(time(NULL));
        initialize_solution();
		construct_solution();
		if(current_iteration<MAX_ITERATIONS){
		}
		else{
			break;
		}
	}
	return 0;
}

