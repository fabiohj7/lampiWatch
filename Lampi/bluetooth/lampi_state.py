from paho.mqtt.client import Client

import json
from collections import defaultdict
from typing import Callable, Optional

# MQTT Topic Names
TOPIC_SET_LAMP_CONFIG = "lamp/set_config"
TOPIC_LAMP_CHANGE_NOTIFICATION = "lamp/changed"
TOPIC_LAMP_ASSOCIATED = "lamp/associated"

MQTT_CLIENT_ID = "lamp_bt_peripheral"

# MQTT_VERSION = paho.mqtt.client.MQTTv311
MQTT_BROKER_HOST = "localhost"
MQTT_BROKER_PORT = 1883
MQTT_BROKER_KEEP_ALIVE_SECS = 60


def client_state_topic(client_id):
    return 'lamp/connection/{}/state'.format(client_id)


class LampiState():
    def __init__(self):
        self._isOn = True
        self._hue = 0
        self._saturation = 0
        self._brightness = 0

        self.got_initial_state = False

        self._setup_mqtt()

        self.callbacks: Dict[str, List[Callable]] = defaultdict(list)

    def _setup_mqtt(self):
        self.mqtt = Client(client_id=MQTT_CLIENT_ID)
        self.mqtt.enable_logger()
        self.mqtt.will_set(client_state_topic(MQTT_CLIENT_ID), "0",
                           qos=2, retain=True)
        self.mqtt.on_connect = self.on_mqtt_connect
        self.mqtt.connect(MQTT_BROKER_HOST, port=MQTT_BROKER_PORT,
                          keepalive=MQTT_BROKER_KEEP_ALIVE_SECS)
        self.mqtt.loop_start()

# region Change Subscriptions
    def on(self, event: str, func: Optional[Callable] = None):
        def subscribe(func: Callable):
            if not callable(func):
                raise ValueError("Argument func must be callable.")
            self.callbacks[event].append(func)
            return func
        if func is None:
            return subscribe
        subscribe(func)

    def emit(self, event, message):
        for callback in self.callbacks[event]:
            callback(message)
# endregion

    @property
    def isOn(self):
        return self._isOn

    @isOn.setter
    def isOn(self, newIsOn):
        if newIsOn != self.isOn:
            self._isOn = newIsOn
            self.publish_state_change()

    def setHSV(self, newHue, newSaturation):
        publish_state_change = False
        if newHue != self.hue:
            self._hue = newHue
            publish_state_change = True

        if newSaturation != self.saturation:
            self._saturation = newSaturation
            publish_state_change = True

        if publish_state_change:
            self.publish_state_change()

    @property
    def hue(self):
        return self._hue

    @property
    def saturation(self):
        return self._saturation

    @property
    def brightness(self):
        return self._brightness

    @brightness.setter
    def brightness(self, newBrightness):
        if newBrightness != self.brightness:
            self._brightness = newBrightness
            self.publish_state_change()

    def on_mqtt_connect(self, client, userdata, flags, rc):
        self.mqtt.publish(client_state_topic(MQTT_CLIENT_ID), b"1",
                          qos=2, retain=True)
        self.mqtt.message_callback_add(TOPIC_LAMP_CHANGE_NOTIFICATION,
                                       self.receive_new_lamp_state)
        self.mqtt.subscribe(TOPIC_LAMP_CHANGE_NOTIFICATION, qos=1)

    def receive_new_lamp_state(self, client, userdata, message):
        new_state = json.loads(message.payload.decode('utf-8'))

        if not self.got_initial_state or new_state.get(
                'client', 'UNKNONW') != MQTT_CLIENT_ID:
            print(f"Got new state: {new_state}")
            self.got_initial_state = True

            if new_state.get('on', False) != self._isOn:
                self._isOn = new_state.get('on', False)
                self.emit('onOffChange', self.isOn)

            emit_color_change = False
            new_color = new_state.get('color', {})
            if new_color.get('h', 0) != self._hue:
                self._hue = new_color.get('h', 0)
                emit_color_change = True

            if new_color.get('s', 0) != self._saturation:
                self._saturation = new_color.get('s', 0)
                emit_color_change = True

            if emit_color_change:
                self.emit('hsvChange', new_color)

            if new_state.get('brightness', 0) != self._brightness:
                self.brightness = new_state.get('brightness', 0)
                self.emit('brightnessChange', self.brightness)

    def publish_state_change(self):

        config = {
            'color': {'h': self.hue, 's': self.saturation},
            'brightness': self.brightness,
            'on': self.isOn,
            'client': MQTT_CLIENT_ID}
        print(f"Publishing new state: {config}")
        self.mqtt.publish(TOPIC_SET_LAMP_CONFIG,
                          json.dumps(config).encode('utf-8'), qos=1,
                          retain=True)
