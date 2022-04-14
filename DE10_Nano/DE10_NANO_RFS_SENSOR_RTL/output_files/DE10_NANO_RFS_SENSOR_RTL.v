// Copyright (C) 2017  Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License 
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel FPGA IP License Agreement, or other applicable license
// agreement, including, without limitation, that your use is for
// the sole purpose of programming logic devices manufactured by
// Intel and sold by Intel or its authorized distributors.  Please
// refer to the applicable agreement for further details.

module DE10_NANO_RFS_SENSOR_RTL
(
// {ALTERA_ARGS_BEGIN} DO NOT REMOVE THIS LINE!

	BT_KEY,
	BT_UART_RX,
	BT_UART_TX,
	FPGA_CLK1_50,
	FPGA_CLK2_50,
	FPGA_CLK3_50,
	KEY,
	LED,
	LSENSOR_INT,
	LSENSOR_SCL,
	LSENSOR_SDA,
	MPU_AD0_SDO,
	MPU_CS_n,
	MPU_FSYNC,
	MPU_INT,
	MPU_SCL_SCLK,
	MPU_SDA_SDI,
	RH_TEMP_DRDY_n,
	RH_TEMP_I2C_SCL,
	RH_TEMP_I2C_SDA,
	SW,
	TMD_D,
	UART2USB_CTS,
	UART2USB_RTS,
	UART2USB_RX,
	UART2USB_TX,
	WIFI_EN,
	WIFI_RST_n,
	WIFI_UART0_CTS,
	WIFI_UART0_RTS,
	WIFI_UART0_RX,
	WIFI_UART0_TX,
	WIFI_UART1_RX,
	altera_reserved_tck,
	altera_reserved_tdi,
	altera_reserved_tdo,
	altera_reserved_tms,
	GPIO
// {ALTERA_ARGS_END} DO NOT REMOVE THIS LINE!

);

// {ALTERA_IO_BEGIN} DO NOT REMOVE THIS LINE!
inout			BT_KEY;
input			BT_UART_RX;
output			BT_UART_TX;
input			FPGA_CLK1_50;
input			FPGA_CLK2_50;
input			FPGA_CLK3_50;
input	[1:0]	KEY;
output	[7:0]	LED;
input			LSENSOR_INT;
inout			LSENSOR_SCL;
inout			LSENSOR_SDA;
output			MPU_AD0_SDO;
output			MPU_CS_n;
output			MPU_FSYNC;
input			MPU_INT;
inout			MPU_SCL_SCLK;
inout			MPU_SDA_SDI;
input			RH_TEMP_DRDY_n;
inout			RH_TEMP_I2C_SCL;
inout			RH_TEMP_I2C_SDA;
input	[3:0]	SW;
inout	[7:0]	TMD_D;
input			UART2USB_CTS;
output			UART2USB_RTS;
input			UART2USB_RX;
output			UART2USB_TX;
output			WIFI_EN;
output			WIFI_RST_n;
input			WIFI_UART0_CTS;
output			WIFI_UART0_RTS;
input			WIFI_UART0_RX;
output			WIFI_UART0_TX;
input			WIFI_UART1_RX;
input			altera_reserved_tck;
input			altera_reserved_tdi;
output			altera_reserved_tdo;
input			altera_reserved_tms;
input	[0:35]	GPIO;

// {ALTERA_IO_END} DO NOT REMOVE THIS LINE!
// {ALTERA_MODULE_BEGIN} DO NOT REMOVE THIS LINE!
// {ALTERA_MODULE_END} DO NOT REMOVE THIS LINE!
endmodule
