int latchPin = 8;  // Latch pin (STCP腳位)
int clockPin = 12; // Clock pin (SHCP腳位)
int dataPin = 11;  // Data pin (DS腳位)

#define Seg0   16
#define Seg1   17
#define Seg2   18
#define Seg3   19
#define Seg4   20
#define Seg5   21

int Data_User_A[16]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
int Data_User_B[16]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

int Temperature_User_A = 0;
int Temperature_User_B = 0;

int UnderPoint_User_A, Ones_Digit_User_A, Tens_Digit_User_A, UnderPoint_User_B, Ones_Digit_User_B, Tens_Digit_User_B;

int Seg_Control = 0;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  
  pinMode(22, INPUT);pinMode(23, INPUT);
  pinMode(24, INPUT);pinMode(25, INPUT);
  pinMode(26, INPUT);pinMode(27, INPUT);
  pinMode(28, INPUT);pinMode(29, INPUT);
  pinMode(30, INPUT);pinMode(31, INPUT);
  pinMode(32, INPUT);pinMode(33, INPUT);
  pinMode(34, INPUT);pinMode(35, INPUT);
  pinMode(36, INPUT);pinMode(37, INPUT);
  
  pinMode(38, INPUT);pinMode(39, INPUT);
  pinMode(40, INPUT);pinMode(41, INPUT);
  pinMode(42, INPUT);pinMode(43, INPUT);
  pinMode(44, INPUT);pinMode(45, INPUT);
  pinMode(46, INPUT);pinMode(47, INPUT);
  pinMode(48, INPUT);pinMode(49, INPUT);
  pinMode(50, INPUT);pinMode(51, INPUT);
  pinMode(52, INPUT);pinMode(53, INPUT);

  pinMode(3, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(3), ReadTemperature, RISING);

  pinMode(latchPin,OUTPUT);
  pinMode(clockPin,OUTPUT);
  pinMode(dataPin, OUTPUT);

  pinMode(Seg0, OUTPUT);
  pinMode(Seg1, OUTPUT);
  pinMode(Seg2, OUTPUT);
  pinMode(Seg3, OUTPUT);
  pinMode(Seg4, OUTPUT);
  pinMode(Seg5, OUTPUT);
}

void loop() {
  switch(Seg_Control) {
    case 0:
      digitalWrite(Seg0, LOW);
      digitalWrite(Seg1, HIGH);
      digitalWrite(Seg2, HIGH);
      digitalWrite(Seg3, HIGH);
      digitalWrite(Seg4, HIGH);
      digitalWrite(Seg5, HIGH);
      DataSend(Tens_Digit_User_B);
      Seg_Control++;
    break;
    case 1:
      digitalWrite(Seg0, HIGH);
      digitalWrite(Seg1, LOW);
      digitalWrite(Seg2, HIGH);
      digitalWrite(Seg3, HIGH);
      digitalWrite(Seg4, HIGH);
      digitalWrite(Seg5, HIGH);
      DataSend(Ones_Digit_User_B);
      Seg_Control++;
    break;
    case 2:
      digitalWrite(Seg0, HIGH);
      digitalWrite(Seg1, HIGH);
      digitalWrite(Seg2, LOW);
      digitalWrite(Seg3, HIGH);
      digitalWrite(Seg4, HIGH);
      digitalWrite(Seg5, HIGH);
      DataSend(UnderPoint_User_B);
      Seg_Control++;
    break;
    case 3:
      digitalWrite(Seg0, HIGH);
      digitalWrite(Seg1, HIGH);
      digitalWrite(Seg2, HIGH);
      digitalWrite(Seg3, LOW);
      digitalWrite(Seg4, HIGH);
      digitalWrite(Seg5, HIGH);
      DataSend(Tens_Digit_User_A);
      Seg_Control++;
    break;
    case 4:
      digitalWrite(Seg0, HIGH);
      digitalWrite(Seg1, HIGH);
      digitalWrite(Seg2, HIGH);
      digitalWrite(Seg3, HIGH);
      digitalWrite(Seg4, LOW);
      digitalWrite(Seg5, HIGH);
      DataSend(Ones_Digit_User_A);
      Seg_Control++;
    break;
    case 5:
      digitalWrite(Seg0, HIGH);
      digitalWrite(Seg1, HIGH);
      digitalWrite(Seg2, HIGH);
      digitalWrite(Seg3, HIGH);
      digitalWrite(Seg4, HIGH);
      digitalWrite(Seg5, LOW);
      DataSend(UnderPoint_User_A);
      Seg_Control = 0;
    break;
    default:
      Serial.println("Invalid number");
  }
}

void ReadTemperature() {
  Data_User_A[7] = digitalRead(22);
  Data_User_A[8] = digitalRead(24);Data_User_A[9] = digitalRead(26);
  Data_User_A[10] = digitalRead(28);Data_User_A[11] = digitalRead(30);
  Data_User_A[12] = digitalRead(32);Data_User_A[13] = digitalRead(24);
  Data_User_A[14] = digitalRead(36);Data_User_A[15] = digitalRead(38);

  Data_User_B[7] = digitalRead(23);
  Data_User_B[8] = digitalRead(25);Data_User_B[9] = digitalRead(27);
  Data_User_B[10] = digitalRead(29);Data_User_B[11] = digitalRead(31);
  Data_User_B[12] = digitalRead(33);Data_User_B[13] = digitalRead(35);
  Data_User_B[14] = digitalRead(37);Data_User_B[15] = digitalRead(39);
  
  Temperature_User_A =  Data_User_A[15] + 2*Data_User_A[14] + 4*Data_User_A[13] + 8*Data_User_A[12]\
                    + 16*Data_User_A[11] + 32*Data_User_A[10] + 64*Data_User_A[9] + 128*Data_User_A[8]\
                    + 256*Data_User_A[7];
  UnderPoint_User_A = Temperature_User_A%10;
  Ones_Digit_User_A = (Temperature_User_A/10)%10;
  Tens_Digit_User_A = (Temperature_User_A/100)%10;
  
  Temperature_User_B =  Data_User_B[15] + 2*Data_User_B[14] + 4*Data_User_B[13] + 8*Data_User_B[12]\
                    + 16*Data_User_B[11] + 32*Data_User_B[10] + 64*Data_User_B[9] + 128*Data_User_B[8]\
                    + 256*Data_User_B[7];
  UnderPoint_User_B = Temperature_User_B%10;
  Ones_Digit_User_B = (Temperature_User_B/10)%10;
  Tens_Digit_User_B = (Temperature_User_B/100)%10;

  
}

void DataSend(int Num) {
  digitalWrite(latchPin, LOW);  // 送資料前要先把 latchPin 設成低電位
  switch(Num) {
    case 0:
      shiftOut(dataPin, clockPin, LSBFIRST, 252);  //11111100
    break;
    case 1:
      shiftOut(dataPin, clockPin, LSBFIRST, 96);  //01100000
    break;
    case 2:
      shiftOut(dataPin, clockPin, LSBFIRST, 218);  //11011010
    break;
    case 3:
      shiftOut(dataPin, clockPin, LSBFIRST, 242);  //11110010
    break;
    case 4:
      shiftOut(dataPin, clockPin, LSBFIRST, 102);  //01100110
    break;
    case 5:
      shiftOut(dataPin, clockPin, LSBFIRST, 182);  //10110110
    break;
    case 6:
      shiftOut(dataPin, clockPin, LSBFIRST, 62);  //00111110
    break;
    case 7:
      shiftOut(dataPin, clockPin, LSBFIRST, 224);  //11100000
    break;
    case 8:
      shiftOut(dataPin, clockPin, LSBFIRST, 254);  //11111110
    break;
    case 9:
      shiftOut(dataPin, clockPin, LSBFIRST, 246);  //11110110
    break;
    default:
      Serial.println("Invalid number");
  }
  digitalWrite(latchPin, HIGH); // 送完資料後要把 latchPin 設成高電位
  delay(3);
}
