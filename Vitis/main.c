#include "xparameters.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "xil_types.h"
#include <stdint.h>
#include <stdio.h>

//#define XPAR_INFERENCE_ENGINE_0_S00_AXI_BASEADDR 0x43C00000
//#define XPAR_INFERENCE_ENGINE_0_S00_AXI_HIGHADDR 0x43C0FFFF

int main()
{
	uint32_t output_ready = 0;
	uint32_t outtie0 = 0;
	uint32_t outtie1 = 0;

	uint32_t input_1_0;
	uint32_t input_3_2;
	uint32_t input_5_4;

	/*
	 * logic [(NUMBER_INPUTS96*16)-1:0] in_neuron_values = {slv_reg3,slv_reg2,slv_reg1};
     * logic [(NUMBER_OUTPUT_NEURONS96*16)-1:0] outtie;
     * logic [1:0] loaded_in;
     * logic output_ready;
	 *
	 *.in_ready96(slv_reg0[0]),
	 *.in_neuron_values96(in_neuron_values),
	 *.loaded_in96(slv_reg6[1:0]),
	 *.outtie96(outtie),
	 *.output_ready96(slv_reg6[2])
	 */

	Xil_Out32(XPAR_INFERENCE_ENGINE_0_S00_AXI_BASEADDR+4, 0xA95DA949); // inputs 0 and 1
	input_1_0 = Xil_In32(XPAR_INFERENCE_ENGINE_0_S00_AXI_BASEADDR+4);

	//printf("input_1_0 = 0x%08x\n\n\r",input_1_0);

	Xil_Out32(XPAR_INFERENCE_ENGINE_0_S00_AXI_BASEADDR+8, 0x14199FC8); // inputs 2 and 3
	Xil_Out32(XPAR_INFERENCE_ENGINE_0_S00_AXI_BASEADDR+12, 0x00000000);// inputs 4 and 5

	Xil_Out32(XPAR_INFERENCE_ENGINE_0_S00_AXI_BASEADDR, 0xFFFFFFFF); // inputs 0 and 1
	//usleep(1);
	Xil_Out32(XPAR_INFERENCE_ENGINE_0_S00_AXI_BASEADDR, 0x00000000);

	while(1)
	{
		output_ready = Xil_In32(XPAR_INFERENCE_ENGINE_0_S00_AXI_BASEADDR+24);

		xil_printf("output_ready = 0x%08x\n\n\r",output_ready);


		if(output_ready & 1 << 2)
		{
			//xil_printf("output_ready = 0x%08x\n\n\r",output_ready);

			//usleep()

			outtie0 = Xil_In32(XPAR_INFERENCE_ENGINE_0_S00_AXI_BASEADDR+16);
			outtie1 = Xil_In32(XPAR_INFERENCE_ENGINE_0_S00_AXI_BASEADDR+20);

			xil_printf("outtie0 = 0x%08x\n\n\r", outtie0);
			xil_printf("outtie1 = 0x%08x\n\n\r", outtie1);

			//return 0;
		    break;
		}

	}

	return 0;
}
