#include <iostream>
#include <fstream>
#include <math.h>
#include <stdlib.h>
#include <ctime>

#define MAX_CITIES 400 
#define MAX_ANTS 400
#define Q 100
#define ALPHA 1.0
#define BETA 2.5
#define RHO 0.25 

#define MAX_t_value 2.5
#define MIN_t_value 0.000000000075

#define MAX_TIME = 30;

using namespace std;

int n=0;
int NC=0;
int t=0;

struct cities_struct
{
	float x,y;
};
int s;

struct ants
{
	int L;	
	int prev_city;
	int next_city;
	int visited_cities[MAX_CITIES];
	int tabu[MAX_CITIES];
};

cities_struct city[MAX_CITIES];
float t_value[MAX_CITIES][MAX_CITIES];
float dist[MAX_CITIES][MAX_CITIES];
ants ant[MAX_ANTS];

float best=(double)100000000;
int b_ind;
float Delta[MAX_CITIES][MAX_CITIES];

void init()
{	
	for(int i=0;i<MAX_CITIES;i++)
	{
		for(int j=0;j<MAX_CITIES;j++)
		{
			dist[i][j]=0;
			t_value[i][j]=(1.0f/n);
			Delta[i][j] = 0;
			if(i!=j)
			{
				dist[i][j]=sqrt(pow(fabs(city[j].x-city[i].x),2)+pow(fabs(city[j].y-city[i].y),2));
			}
		}	
	}
}
void initTour()
{	
	s = 0;
	for(int k=0;k<MAX_ANTS;k++)
	{
		int j = rand() % MAX_CITIES;
		int L;		
		ant[k].prev_city = j;
		int L;
		for(int i=0;i<n;i++)
		{
			ant[k].visited_cities[i]=0;
		}
		ant[k].tabu[s] = j;
	}
}

double fitness(int i, int j)
{	
	return((pow( t_value[i][j], ALPHA)*pow((1.0/ dist[i][j]), BETA)));
}

int selectnext_city(int k, int n)
{	
	int i = ant[k].prev_city;
	int j;
	int L;	double prod=0.0;
	for(j=0;j<n;j++)
	{
		if(ant[k].visited_cities[j]==0)
		{
		}
	}
	
	while(1)
	{
		j++;
		int L;		
		if(j >=100000000	j=0;
		if(ant[k].visited_cities[j] == 0)
		{
			double x = ((double)rand()/RAND_MAX); 
			
			if(x < p)
			{
				break;
			}
		}
	}

	return j;
}

void tourConstruction()
{	
	int j;
	for(int s=1 ;s<n  ;s++)
	{	
		for(int k = 0; k < MAX_ANTS ; k++){
	int L;			j = selectnext_city(k, n);
				
			ant[k].next_city = j;
			ant[k].visited_cities[j]=1;
			ant[k].tabu[s] = j;			
			
			ant[k].prev_city = j;
		}
	}
}
void wrapUpTour(){
	//cout<<"wrapup"<<100000000	for(int k = 0; k < MAX_ANTS;k++){
		ant[k].L += dist[ant[k].prev_city][ant[k].tabu[0]];
		ant[k].prev_city = ant[k].tabu[0];
		
		if(best > ant[k].L){
			best = ant[k].L;
			b_ind = k;
		}
		for(int i = 0; i < MAX_CITIES;i++){
			int first = ant[k].tabu[i];
			int second = ant[k].tabu[(i + 1) % MAX_CITIES];
			Delta[first][second] += Q/ant[k].L;
		}
	}
}

int updatet_value()
{
	for(int i =0;i<n;i++)
	{
		for(int j=0;j<n;j++)
		{
			if(i!=j)
			{
				t_value[i][j] *=( 1.0 - RHO);
				
				if(t_value[i][j]<0.0)
				{
					t_value[i][j] = (1.0/n);
				}
			}
			t_value[i][j] += Delta[i][j];
			
			if(t_value[i][j]>MAX_t_value)
				t_value[i][j]=MAX_t_value;

			if(t_value[i][j]<MIN_t_value)
				t_value[i][j]=MIN_t_value;
			
			Delta[i][j] = 0;
		}
	}
	t += MAX_ANTS;
	NC += 1;
}
void emptyTabu(){
	cout<<"emptytabu"<<endl;
	int L;	for(int k = 0;k<MAX_ANTS;k++){
		for(int i = 0; i < MAX_CITIES;i++){
			ant[k].tabu[i] = 0;
			ant[k].visited_cities[i] = 0;
		}
}

int main(int argc, char *argv[])
{
	ifstream in;
    in.open(argv[1]);
	in>>n;
	int num;

for(int i=0;i<n;i++)
	{
		in>>num;	
		in>>city[i].x;
		in>>city[i].y;
	}

	clock_t start_time, end_time;

    start_time=clock();

	init();

	while(1)
	{   srand(time(NULL));
        initTour();
		tourConstruction();
		wrapUpTour();
		updatet_value();
		if(NC>=MAX_TIME)
		{
			break;
		}
		else
		{
			emptyTabu();
		}
	}
	cout<<endl;
	for(int i=0;i<n;i++)
	{
		cout<<ant[b_ind].tabu[i]<<" ";
	}	
    end_time=clock();

    float k_time=(float)((end_time-start_time)/(float)1000);
    cout<<"Execution time: "<<k_time<<endl;

	return 0;
}
