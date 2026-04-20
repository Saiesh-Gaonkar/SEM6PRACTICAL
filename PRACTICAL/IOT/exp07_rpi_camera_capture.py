import time

try:
	from picamera2 import Picamera2
	USE_PICAMERA2 = True
except ImportError:
	from picamera import PiCamera
	USE_PICAMERA2 = False


def capture_with_picamera2():
	camera = Picamera2()
	camera.configure(camera.create_still_configuration())
	print("Starting camera...")
	camera.start()
	time.sleep(3)
	print("Capturing image...")
	camera.capture_file("/home/pi/Desktop/test_image.jpg")
	camera.stop()
	print("Image saved to Desktop.")


def capture_with_picamera():
	camera = PiCamera()
	camera.resolution = (1920, 1080)
	print("Starting camera preview...")
	camera.start_preview()
	time.sleep(3)
	print("Capturing image...")
	camera.capture("/home/pi/Desktop/test_image.jpg")
	camera.stop_preview()
	print("Image saved to Desktop.")


if USE_PICAMERA2:
	capture_with_picamera2()
else:
	capture_with_picamera()
