# -*- coding: utf-8 -*-

import os
import cv2
import io
import Orange
import RPi.GPIO as GPIO
import pickle
import numpy as np
import picamera
import traceback
from pylepton.Lepton3 import Lepton3

GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(0,GPIO.OUT)
GPIO.setup(5,GPIO.OUT)
GPIO.setup(6,GPIO.OUT)
GPIO.setup(13,GPIO.OUT)
GPIO.setup(19,GPIO.OUT)
GPIO.setup(26,GPIO.OUT)

def data_output(rop):
    dop = round(float(rop),0)
    if dop == -3.0:
        GPIO.output(0,GPIO.HIGH)
        GPIO.output(5,GPIO.HIGH)
        GPIO.output(6,GPIO.HIGH)
        GPIO.output(13,GPIO.LOW)
        GPIO.output(19,GPIO.LOW)
        GPIO.output(26,GPIO.LOW)
        
    if dop == -2.0:
        GPIO.output(0,GPIO.LOW)
        GPIO.output(5,GPIO.HIGH)
        GPIO.output(6,GPIO.HIGH)
        GPIO.output(13,GPIO.LOW)
        GPIO.output(19,GPIO.LOW)
        GPIO.output(26,GPIO.LOW)
        
    if dop == -1.0:
        GPIO.output(0,GPIO.HIGH)
        GPIO.output(5,GPIO.LOW)
        GPIO.output(6,GPIO.HIGH)
        GPIO.output(13,GPIO.LOW)
        GPIO.output(19,GPIO.LOW)
        GPIO.output(26,GPIO.LOW)
        
    if dop == 0.0:
        GPIO.output(0,GPIO.LOW)
        GPIO.output(5,GPIO.LOW)
        GPIO.output(6,GPIO.LOW)
        GPIO.output(13,GPIO.LOW)
        GPIO.output(19,GPIO.LOW)
        GPIO.output(26,GPIO.LOW)
        
    if dop == 1.0:
        GPIO.output(0,GPIO.HIGH)
        GPIO.output(5,GPIO.LOW)
        GPIO.output(6,GPIO.LOW)
        GPIO.output(13,GPIO.LOW)
        GPIO.output(19,GPIO.LOW)
        GPIO.output(26,GPIO.LOW)
        
    if dop == 2.0:
        GPIO.output(0,GPIO.LOW)
        GPIO.output(5,GPIO.HIGH)
        GPIO.output(6,GPIO.LOW)
        GPIO.output(13,GPIO.LOW)
        GPIO.output(19,GPIO.LOW)
        GPIO.output(26,GPIO.LOW)
        
    if dop == 3.0:
        GPIO.output(0,GPIO.HIGH)
        GPIO.output(5,GPIO.HIGH)
        GPIO.output(6,GPIO.LOW)
        GPIO.output(13,GPIO.LOW)
        GPIO.output(19,GPIO.LOW)
        GPIO.output(26,GPIO.LOW)

def read_value(tmp3):
    output_path = "test.csv"
    f = open(output_path, 'w')
    f.write("nose\n")
    tmp3 = round(tmp3, 2)
    f.write(str(tmp3))
    f.write("\n")
    f.close()

    model = pickle.load(open("DHT22_temperature.pkcls", "rb"))
    data = Orange.data.Table("test.csv")

    finaldata = model(data)
    return finaldata


def setColorBar(lepton_buf, _low, _high):

    d = (_high - _low) / 120.0
    i = 0 
    for i in range(120):
        if i == 0:
            continue
        if i == 119:
            break
        _d = d * i
        lepton_buf[i][152] = _high - int(_d)
        lepton_buf[i][151] = _high - int(_d)
        #print("%d,%d" % (i,lepton_buf[i][152]))

def main(alpha = 0.5, device = "/dev/spidev0.0", high = 70, low = 10):

    alpha = float(alpha)
    high  = int(high)
    low   = int(low)

    if high < low:
        exit

    _high = int(high) * 100 + 27315
    _low  = int(low)  * 100 + 27315

    stream = io.BytesIO()

    cv2.namedWindow('image', cv2.WND_PROP_FULLSCREEN)
    cv2.setWindowProperty('image', cv2.WND_PROP_FULLSCREEN, cv2.WINDOW_FULLSCREEN)

    lepton_buf = np.zeros((120, 160, 1), dtype=np.uint16)

    with picamera.PiCamera() as camera:
        camera.resolution = (640, 480)
        camera.framerate  = 10
        try:
            with Lepton3(device) as l:
                last_nr = 0

                while True:
                    lepton_buf, nr = l.capture()
                    if nr == last_nr:
                        k = cv2.waitKey(1)
                        if k==27:
                            break
                        continue

                    stream.seek(0)
                    camera.capture(stream, format='jpeg')
                    data = np.fromstring(stream.getvalue(), dtype=np.uint8)
                    image = cv2.imdecode(data, 1)
                    #im = image[38+18:38+18+384, 51+35:51+35+512]
                    #image = cv2.resize(im, (640, 480))

                    last_nr = nr

                    # error skip
                    data_1d = lepton_buf.ravel()
                    if np.min(data_1d) == 0:
                        k = cv2.waitKey(1)
                        if k==27:
                            break
                        continue

                    # backup for temperature
                    lepton_temp = np.copy(lepton_buf)

                    # for color bar
                    lepton_buf = np.clip(lepton_buf, _low, _high)
                    setColorBar(lepton_buf, _low, _high)

                    cv2.normalize(lepton_buf, lepton_buf, 0, 65535, cv2.NORM_MINMAX)
                    np.right_shift(lepton_buf, 8, lepton_buf)

                    h, w, _ = image.shape
                    _image  = np.asarray(image, np.uint8)
                    _lepton = np.asarray(lepton_buf, np.uint8)
                    _lepton_gray = cv2.cvtColor(_lepton, cv2.COLOR_GRAY2RGB)
                    _lepton_gray = cv2.resize(_lepton_gray, (w, h))
                    _lepton_gray = cv2.applyColorMap(_lepton_gray, cv2.COLORMAP_JET)
                    res = cv2.addWeighted(_image, alpha, _lepton_gray, 1.0 - alpha, 0)

                    h = 2
                    w = 2

                    #x1 = 160 / 4 * 1.3 - w
                    #y1 = 150 / 4 * 1 - h
                    
                    #x2 = 160 / 4 * 3 - w
                    #y2 = 120 / 4 * 2 - h
                    
                    x3 = 160 / 4 * 2 - w  
                    y3 = 120 / 4 * 2 - h
                    


                    #cv2.rectangle(res, (int(x1 * 4), int(y1 * 4)), (int((x1 + w) * 4), int((y1 + h) * 4)), (0, 255, 0), -1)
                    #cv2.rectangle(res, (int(x2 * 4), int(y2 * 4)), (int((x2 + w) * 4), int((y2 + h) * 4)), (0, 255, 0), -1)
                    cv2.rectangle(res, (int(x3 * 4), int(y3 * 4)), (int((x3 + w) * 4), int((y3 + h) * 4)), (0, 255, 0), -1)


                    #lepton_temp1 = lepton_temp[int(y1):int(y1+h), int(x1):int(x1+w)]
                    #lepton_temp2 = lepton_temp[int(y2):int(y2+h), int(x2):int(x2+w)]
                    lepton_temp3 = lepton_temp[int(y3):int(y3+h), int(x3):int(x3+w)]


                    #tmp1 = (np.max(lepton_temp1.ravel()) - 27315) / 100.0
                    #tmp2 = (np.max(lepton_temp2.ravel()) - 27315) / 100.0
                    tmp3 = (np.max(lepton_temp3.ravel()) - 27315) / 100.0

                    frv = tmp3
                    
                    #cv2.putText(res, str(tmp1), (int(x1 * 4 - 40), int(y1 * 4 + 40)), cv2.FONT_HERSHEY_COMPLEX, 1.0, (255, 255, 255))
                    #cv2.putText(res, str(tmp2), (int(x2 * 4 - 40), int(y2 * 4 + 40)), cv2.FONT_HERSHEY_COMPLEX, 1.0, (255, 255, 255))
                    cv2.putText(res, str(tmp3), (int(x3 * 4 - 40), int(y3 * 4 + 40)), cv2.FONT_HERSHEY_COMPLEX, 1.0, (255, 255, 255))

                    rop = read_value(frv) #rop是預測結果

                    data_output(rop)
                    
                    
                    j = 10
                    d = (high - low) / 5.0
                    for i in range(6):
                        _d = d * i
                        _m = "-" + str(high - int(_d))
                        _n = j + (i * 92)
                        cv2.putText(res, _m, (610,  _n), cv2.FONT_HERSHEY_COMPLEX, 0.4, (255,255,255))

                    cv2.imshow('image', res)
                    k = cv2.waitKey(33)
                    if k==27:
                        cv2.destroyAllWindows()            # Esc key to stop
                        break
                    
        except Exception:
            traceback.print_exc()
        finally:
            camera.close()

if __name__ == '__main__':
    from optparse import OptionParser

    usage = "usage: %prog [options] output_file[.format]"
    parser = OptionParser(usage=usage)
    parser.add_option("-a", "--alpha",  dest="alpha",  default=0.5,              help="set lepton overlay opacity")
    parser.add_option("-d", "--device", dest="device", default="/dev/spidev0.0", help="specify the spi device node (might be /dev/spidev0.1 on a newer device)")
    parser.add_option("-H", "--high",   dest="high",   default=70,               help="highest value on display")
    parser.add_option("-L", "--low",    dest="low",    default=10,               help="lowest value on display")

    options = parser.parse_args()[0]

    main(alpha = options.alpha, device = options.device, high = options.high, low = options.low)