	
//--MPU9250 --SLAVE ADDRESS
parameter   [7:0] MPU9250_ADDRESS           =8'hd0;

//--AK8963 --SLAVE ADDRESS
parameter   [7:0] MAG_ADDRESS               =8'h18;


//--MPU9250 --REGISTER
parameter P_I2C_SLV0_ADDR    =8'h25;
parameter P_I2C_SLV0_REG     =8'h26;
parameter P_I2C_SLV0_CTRL    =8'h27;
parameter P_INT_PIN_CFG      =8'h37;
parameter P_INT_ENABLE       =8'h38;
parameter P_CONFIG           =8'h1A; 
parameter P_SMPLRT_DIV       =8'h19; 
parameter P_INT_STATUS       =8'h3A;
parameter P_WOM_THR          =8'h1f;
parameter P_ACCEL_CONFIG     =8'h1d;
parameter P_MOT_DETECT_CTRL  =8'h69;
parameter P_I2C_MST_STATUS   =8'h36; 
parameter P_ACCEL_XOUT_H     =8'h3B;
parameter P_ACCEL_XOUT_L     =8'h3C;
parameter P_ACCEL_YOUT_H     =8'h3D;
parameter P_ACCEL_YOUT_L     =8'h3E;
parameter P_ACCEL_ZOUT_H     =8'h3F;
parameter P_ACCEL_ZOUT_L     =8'h40;
parameter P_TEMP_OUT_H       =8'h41;
parameter P_TEMP_OUT_L       =8'h42;
parameter P_GYRO_XOUT_H      =8'h43;
parameter P_GYRO_XOUT_L      =8'h44;
parameter P_GYRO_YOUT_H      =8'h45;
parameter P_GYRO_YOUT_L      =8'h46;
parameter P_GYRO_ZOUT_H      =8'h47;
parameter P_GYRO_ZOUT_L      =8'h48;
parameter P_I2C_SLV0_DO  = 8'h63 ; 
parameter P_MPUREG_PWR_MGMT_1    =8'h6B;
parameter P_MPUREG_PWR_MGMT_2    =8'h6c;
parameter P_MPUREG_CONFIG        =8'h1A;						 
parameter P_MPUREG_GYRO_CONFIG   =8'h1B;						 
parameter P_MPUREG_ACCEL_CONFIG  =8'h1c;						 
parameter P_MPUREG_ACCEL_CONFIG_2=8'h1d;						 
parameter P_MPUREG_INT_PIN_CFG   =8'h37;						 
parameter P_MPUREG_USER_CTRL     =8'h6A;						 
parameter P_MPUREG_I2C_MST_CTRL  =8'h24;						 
parameter P_MPUREG_I2C_SLV0_ADDR =8'h25;						 
parameter P_MPUREG_I2C_SLV0_REG  =8'h26;						 
parameter P_MPUREG_I2C_SLV0_DO   =8'h63;						 
parameter P_MPUREG_I2C_SLV0_CTRL =8'h27;
parameter P_MPUREG_EXT_SENS_DATA_00    =8'h49;
parameter P_MPUREG_EXT_SENS_DATA_01    =8'h4A;
parameter P_MPUREG_EXT_SENS_DATA_02    =8'h4B;
parameter P_MPUREG_EXT_SENS_DATA_03    =8'h4C;
parameter P_MPUREG_EXT_SENS_DATA_04    =8'h4D;
parameter P_MPUREG_EXT_SENS_DATA_05    =8'h4E;
parameter P_MPUREG_EXT_SENS_DATA_06    =8'h4F;
parameter P_MPUREG_EXT_SENS_DATA_07    =8'h50;
parameter P_MPUREG_EXT_SENS_DATA_08    =8'h51;
parameter P_MPUREG_EXT_SENS_DATA_09    =8'h52;
parameter P_MPUREG_EXT_SENS_DATA_10    =8'h53;
parameter P_MPUREG_EXT_SENS_DATA_11    =8'h54;
parameter P_MPUREG_EXT_SENS_DATA_12    =8'h55;
parameter P_MPUREG_EXT_SENS_DATA_13    =8'h56;
parameter P_MPUREG_EXT_SENS_DATA_14    =8'h57;
parameter P_MPUREG_EXT_SENS_DATA_15    =8'h58;
parameter P_MPUREG_EXT_SENS_DATA_16    =8'h59;
parameter P_MPUREG_EXT_SENS_DATA_17    =8'h5A;
parameter P_MPUREG_EXT_SENS_DATA_18    =8'h5B;
parameter P_MPUREG_EXT_SENS_DATA_19    =8'h5C;
parameter P_MPUREG_EXT_SENS_DATA_20    =8'h5D;
parameter P_MPUREG_EXT_SENS_DATA_21    =8'h5E;
parameter P_MPUREG_EXT_SENS_DATA_22    =8'h5F;
parameter P_MPUREG_EXT_SENS_DATA_23    =8'h60;


//--AK8963 --REGISTER
parameter P_CNTL1            = 8'h0a;
parameter P_CNTL2            = 8'h0b;
parameter P_WIA              = 8'h00;
parameter P_INFO             = 8'h01;
parameter P_ST1              = 8'h02;
parameter P_HXL              = 8'h03;
parameter P_HXH              = 8'h04;
parameter P_HYL              = 8'h05;
parameter P_HYH              = 8'h06;
parameter P_HZL              = 8'h07;
parameter P_HZH              = 8'h08;
parameter P_ST2              = 8'h09;
