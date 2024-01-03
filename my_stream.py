import cv2
import sys
sys.path.append("./fisheye_tools")
from fisheye_tools import e2c
# Construct the GStreamer pipeline

# with the nvidia driver
gst_str = "thetauvcsrc ! h264parse ! nvv4l2decoder ! nvvidconv ! video/x-raw,format=RGBA ! videoconvert ! video/x-raw,format=BGR ! appsink "

# auto select the driver
#gst_str = "thetauvcsrc ! decodebin ! autovideoconvert ! video/x-raw,format=BGRx ! videoconvert ! video/x-raw,format=BGR ! appsink"

# according to Sara's code
#gst_str = "gst-launch-1.0 thetauvcsrc mode=4K ! queue ! h264parse ! nvv4l2decoder ! queue ! nv3dsink sync=false"

# Create a VideoCapture object
cap = cv2.VideoCapture(gst_str, cv2.CAP_GSTREAMER)

# Check if the VideoCapture object was opened successfully
if not cap.isOpened():
    print("Error: Cannot open video stream or file")

# Read frames in a loop
while True:
    ret, frame = cap.read()
    frame = cv2.resize(frame, (800, 400))

    frame = e2c(frame, face_w = 256)
    if not ret:
        break

    # Do something with the frame
    cv2.imshow('Frame', frame)

    # Break the loop
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Release the VideoCapture object
cap.release()
cv2.destroyAllWindows()
