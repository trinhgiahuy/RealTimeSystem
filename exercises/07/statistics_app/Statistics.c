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
#define ARRAY_SIZE 8192     // maximun stored rows
#define IRQ_LINES 16        // irq lines count in irqgen

// flag for stdin read loop active
int read_inputs = 1;    

//row counter for readed rows
int row = 0;


//SIGINT signal handler
void sig_handler(int signum){
    read_inputs = 0;
}


int main(int argc, char **argv)
{
    
    signal(SIGINT, sig_handler);
    
    char data[ARRAY_SIZE][ROW_LENGTH];


    //readding input
    char *retval;

    while(read_inputs){

        char input[ROW_LENGTH];

        
         if( fgets(input,ROW_LENGTH,stdin) != NULL){
  
            if (row < ARRAY_SIZE){
                strcpy(data[row], input);
                row++; 
            }       
        }
    }

    
    //convertig chars in array to ints in array
    //using strtok-function to split char arrays from ","

    // array holding integer values
    /*
    [0] line number
    [1] latency
    [2] timestamp
    */
    int int_array[ARRAY_SIZE][3];

    for (int i = 0; i<row; i++){

        char *pcb;

        pcb = strtok (data[i],",");

        int g = 0;
        

        while (pcb != NULL)
        {
            int luku = atoi(pcb);

            // check atoi success and drop timestamp from data
            if (luku != 0 || g<2){
                int_array[i][g] = luku;
                g++;
            }
            pcb = strtok (NULL, ",");
        } 
    }

  
    //data stcture for storing the data in final form
    struct irq_data{
        int line_number;
        int number_of_events;
        double total_latency;
        double worst_latency;
    };

    // index of array represent the line number
    struct irq_data irq_data_array[IRQ_LINES];

    // default values to irq_data_array
    for(int i=0; i<IRQ_LINES; i++){
        irq_data_array[i].line_number = -1;
        irq_data_array[i].total_latency = -1;
        irq_data_array[i].number_of_events = -1;
        irq_data_array[i].worst_latency=-1;
    }



    // index throught int_array and parse data to struct-array
    for (int a = 0; a<row; a++){

        int rowdata[3];
        // copy array
        for(int i=0; i<3; i++){
             rowdata[i] = int_array[a][i]; 
        }  

        int line_nbr = rowdata[0];
        int latency = rowdata[1];

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
