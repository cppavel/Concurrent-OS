
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include "cond.c"


int pnum;  // number updated when producer runs.
int csum;  // sum computed using pnum when consumer runs.

int (*pred)(int); // predicate indicating if pnum is to be consumed

pthread_mutex_t mutex;
pthread_cond_t ready_to_consume;
pthread_cond_t ready_to_produce;

int state; //ready to produce = 0, ready to consume = 1

int produceT() {
  scanf("%d",&pnum); // read a number from stdin
  state = 1; //ready to consume
  return pnum;
}

void *Produce(void *a) {
  int p;

  p=1;
  while (p) {
    printf("@P-READY\n");
    pthread_mutex_lock(&mutex);         //acquire lock

    while(state)
    {
        pthread_cond_wait(&ready_to_produce,&mutex);        //if not ready to produce, wait (sleep + unlock mutex)
    }

    p = produceT();
    printf("@PRODUCED %d\n",p);
    pthread_cond_signal(&ready_to_consume);                 //signal that ready to consume
    pthread_mutex_unlock(&mutex);                           //unlock mutex so that cond_wait can acquire lock again in other thread
  }
  printf("@P-EXIT\n");
  pthread_exit(NULL);
}


int consumeT() {
  if ( pred(pnum) ) { csum += pnum; }
  state = 0; //ready to produce
  return pnum;
}

void *Consume(void *a) {
  int p;

  p=1;
  while (p) {
      printf("@C-READY\n");
      pthread_mutex_lock(&mutex);           //acquire lock
      while(state!=1)
      {
          pthread_cond_wait(&ready_to_consume, &mutex); //wait before ready to consume (sleep + unlock mutex)
      }
      p = consumeT();
      printf("@CONSUMED %d\n",csum);
      pthread_cond_signal(&ready_to_produce);           //signal that can be produced
      pthread_mutex_unlock(&mutex);                     //unlock mutex so that wait in the other thread can lock it
  }
  printf("@C-EXIT\n");
  pthread_exit(NULL);
}


int main (int argc, const char * argv[]) {
  // the current number predicate
  static pthread_t prod,cons;
	long rc;

  pred = &cond1;
  if (argc>1) {
    if      (!strncmp(argv[1],"2",10)) { pred = &cond2; }
    else if (!strncmp(argv[1],"3",10)) { pred = &cond3; }
  }

  pthread_mutex_init(&mutex, NULL);
  pthread_cond_init (&ready_to_consume,NULL);
  pthread_cond_init(&ready_to_produce,NULL);


  state = 0;
  pnum = 999;
  csum=0;
  srand(time(0));

  printf("@P-CREATE\n");
 	rc = pthread_create(&prod,NULL,Produce,(void *)0);
	if (rc) {
			printf("@P-ERROR %ld\n",rc);
			exit(-1);
		}
  printf("@C-CREATE\n");
 	rc = pthread_create(&cons,NULL,Consume,(void *)0);
	if (rc) {
			printf("@C-ERROR %ld\n",rc);
			exit(-1);
		}

  printf("@P-JOIN\n");
  pthread_join( prod, NULL);
  printf("@C-JOIN\n");
  pthread_join( cons, NULL);


  printf("@CSUM=%d.\n",csum);

  pthread_mutex_destroy(&mutex);
  pthread_cond_destroy(&ready_to_consume);
  pthread_cond_destroy(&ready_to_produce);
  return 0;
}
