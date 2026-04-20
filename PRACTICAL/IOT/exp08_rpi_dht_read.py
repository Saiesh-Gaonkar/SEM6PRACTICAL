import time
import board
import adafruit_dht

dht_device = adafruit_dht.DHT11(board.D4)

try:
    while True:
        try:
            temperature_c = dht_device.temperature
            humidity = dht_device.humidity
            print(f"Temp: {temperature_c:.1f} C  |  Humidity: {humidity}%")
        except RuntimeError as error:
            print(error.args[0])
            time.sleep(2.0)
            continue
        time.sleep(2.0)
except KeyboardInterrupt:
    print("Exiting program.")
    dht_device.exit()
