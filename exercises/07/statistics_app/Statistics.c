/* 
Course: Real time systems 2020
Brief: Statistics aplication for irqgen module stats reading
Author: Juho Pyykkönen
Author: Trinh Gia Huy
*/
#include <stdio.h>
#include <signal.h>
#include <string.h>
#include <stdlib.h>


#define ROW_LENGTH 60       // characters per row
#define IRQ_LINES 16        // irq lines count in irqgen

#define INPUT_FILE "/dev/irqgen"

// flag for stdin read loop active
int read_inputs = 1;    

//row counter for readed rows
int row = 0;

// input file operator
FILE *fp;

//data stcture for storing the data in final form
struct irq_data{
    int line_number;
    int number_of_events;
    double total_latency;
    double worst_latency;
};

// index of array represent the line number
struct irq_data irq_data_array[IRQ_LINES];


//SIGINT signal handler
void sig_handler(int signum){
    read_inputs = 0;
}


int main(int argc, char **argv)
{



    // default values to irq_data_array
    for(int i=0; i<IRQ_LINES; i++){
        irq_data_array[i].line_number = -1;
        irq_data_array[i].total_latency = -1;
        irq_data_array[i].number_of_events = -1;
        irq_data_array[i].worst_latency=-1;
    }
    
    signal(SIGINT, sig_handler);
    

    fp = fopen(INPUT_FILE, "r");
    if(fp == NULL) {
      perror("Error opening file");
      return(-1);
    }


    //readding input
    char *retval;

    while(read_inputs){

        char input[ROW_LENGTH];

         // some data read
         if( fgets(input,ROW_LENGTH,fp) != NULL){
            
            char *pcb;

            pcb = strtok (input,",");

            int g = 0;

            int luku;

            // storing the variable after converting from string to int
            int int_array[2];        

            while (pcb != NULL)
            {
                luku = atoi(pcb);

                // check atoi success and drop timestamp from data
                if (luku != 0 || g<2){
                    int_array[g] = luku;
                    g++;
                }
                pcb = strtok (NULL, ",");
            }

            int line_nbr = int_array[0];
            int latency = int_array[1];

            // set line number
            if (irq_data_array[line_nbr].line_number == -1){
                irq_data_array[line_nbr].line_number = line_nbr;
            }

            // set events number counter
            if (irq_data_array[line_nbr].number_of_events == -1){
                irq_data_array[line_nbr].number_of_events = 1;

            } else {
                irq_data_array[line_nbr].number_of_events++;
            }

            // set total latency
            if (irq_data_array[line_nbr].total_latency == -1){
                irq_data_array[line_nbr].total_latency = latency;

            } else {
                irq_data_array[line_nbr].total_latency += latency;
            }

            // set worst latency
            if (irq_data_array[line_nbr].worst_latency == -1){
                irq_data_array[line_nbr].worst_latency = latency;
            } else if (latency > irq_data_array[line_nbr].worst_latency){
                irq_data_array[line_nbr].worst_latency = latency;
            } 
  
             
        }
    }

    fclose(fp);

    

    // final formal printing

    // variables for the last lines "total" print
    int tot_events = 0;
    double tot_latency = 0;
    double tot_w_latency = 0;

    // printing the statitics
    for (int i=0;i<IRQ_LINES ; i++){
        if (irq_data_array[i].line_number != -1){

            double average_latency = irq_data_array[i].total_latency/irq_data_array[i].number_of_events;

            printf("%d,", irq_data_array[i].line_number);
            printf("%d,", irq_data_array[i].number_of_events);
            printf("%g,", average_latency);
            printf("%g \n", irq_data_array[i].worst_latency);
            
            // saving essentials for the "total" part
            tot_events += irq_data_array[i].number_of_events;
            tot_latency += irq_data_array[i].total_latency;
            if (irq_data_array[i].worst_latency > tot_w_latency){
                tot_w_latency = irq_data_array[i].worst_latency;
            }
        }
    }

    // calculatin the "tota" part and printig them
    double total_avg_latency = tot_latency/tot_events;
    printf("%d,", -1);
    printf("%d,", tot_events);
    printf("%g,", total_avg_latency);
    printf("%g \n", tot_w_latency);

    return(0);
}
