from flask import Flask
import board
import adafruit_dht

app = Flask(__name__)

dht_device = adafruit_dht.DHT11(board.D4)


@app.route('/')
def get_sensor_data():
    try:
        temperature_c = dht_device.temperature
        humidity = dht_device.humidity
        if temperature_c is not None and humidity is not None:
            return (
                "<h1>Raspberry Pi Weather Server</h1>"
                f"<p>Temperature: {temperature_c:.1f} C</p>"
                f"<p>Humidity: {humidity}%</p>"
            )
        return "<h1>Error</h1><p>Failed to retrieve data from sensor.</p>"
    except RuntimeError as error:
        return f"<h1>Error</h1><p>Sensor read error: {error.args[0]}</p>"


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
