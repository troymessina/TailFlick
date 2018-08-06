from Tkinter import *
import time
import serial

dt = 0
locations=[2, 3, 4, '/dev/ttyUSB0','/dev/ttyUSB1','/dev/ttyUSB2','/dev/ttyUSB3',  
 '/dev/ttyS0','/dev/ttyS1','/dev/ttyS2','/dev/ttyS3']    
   
for device in locations:  
    try:  
        print "Trying...",device  
        ser = serial.Serial(device, 9600, timeout=1)
        time.sleep(1)
        device_feedback = ser.readline()
        if device_feedback == "Program Initialized":
            print device_feedback
        elif device_feedback == "":
            print "Port ", device, " active but not Arduino."
            continue
        else:
            break
        break  
    except:  
        print "Failed to connect on",device

ser.flushOutput()
ser.flushInput()

class MyDialog:

    def __init__(self,parent):

        global dt, samplename
        self.entryVariable = StringVar()
        self.entryVariable.set(str(dt))
        self.T1Variable = StringVar()
        self.T2Variable = StringVar()
        self.sample = StringVar()
        self.sample.set("Mouse 1")
        self.filename = StringVar()
        self.filename.set("temp.csv")
        global top
        top = self.top = parent
        self.e = Entry(top, textvariable = self.filename)
        self.e.config(font=("Helvetica", 12),state=NORMAL)
        self.e2 = Entry(top, textvariable = self.sample)
        self.e2.config(font=("Helvetica", 12),state=NORMAL)
        self.e3 = Entry(top, textvariable = self.entryVariable)
        self.e3.config(font=("Helvetica", 12), justify=CENTER,state=NORMAL)
        self.e4 = Entry(top, textvariable = self.T1Variable)
        self.e4.config(font=("Helvetica", 12), justify=CENTER,state=NORMAL)
        
        Label(top, text="What is the file name?", font=("Helvetica",12)).pack()
        self.e.pack(padx=50, pady=5, fill=X)
        Label(top, text="What is the sample?", font=("Helvetica",12)).pack()
        self.e2.pack(padx=3, pady=5)
        Label(top, text="elapsed time (s)", font=("Helvetica",12)).pack()
        self.e3.pack(padx=3, pady=5)
        Label(top, text="Temperature (C)", font=("Helvetica",12)).pack()
        self.e4.pack(padx=3, pady=5)
        
        self.b = Button(top, text="OK", command=self.ok, font=("Helvetica",12))
        self.b.pack(pady=5, side=BOTTOM)

        self.e.bind("<Return>", self.ok)
        self.e.bind("<Escape>", self.escape)

    def ok(self, event = None):
        samplename = self.e2.get()
        ser.write('Y')
        start = time.time()
        filename = self.e.get()
        if len(filename) == 0:
            filename = self.filname
            self.e = Entry(top, textvariable = self.filename)
            root.update()
        print "Your file is ", filename
        
        f=open(filename, 'a')
        #line = ""
        ser.flushOutput()
        ser.flushInput()
        temperature = []
        times = []
        line = []
        while(line != "flick"):
            line = ser.readline()       #why does readline and not read get data
            #print line[0]
            dt = time.time()-start
            times.append(dt)
            temperature.append(line)
            self.entryVariable.set("%.0f" % dt)
            self.e3 = Entry(top, textvariable = self.entryVariable)
            self.T1Variable.set("%s" % line)
            self.e4 = Entry(top, textvariable = self.T1Variable)
            root.update()
        dt = time.time()-start
        ser.flushOutput()
        ser.flushInput()
        f.writelines("\r%s, %.1f\r" % (samplename, dt))
        index = 0
        for x in times:
            f.writelines("%s, " % x)
            f.writelines(temperature[index])
            index += 1
        f.close()
#        print "%.1f" % dt
        self.entryVariable.set("%.1f" % dt)
        return dt

    def escape(self, event = None):
        print "Exiting the program"
        ser.close()
        root.destroy()
        return 0

root = Tk()
root.title("Tail Flick Analgesic Meter")

d = MyDialog(root)

root.wait_window(d.top)
