from time import sleep

from pymodbus.client.sync import ModbusTcpClient
import logging
import numpy as np
import requests

UNIT = 0x1


if __name__ == "__main__":
    FORMAT = ('%(asctime)-15s %(threadName)-15s'
              ' %(levelname)-8s %(module)-15s:%(lineno)-8s %(message)s')
    logging.basicConfig(format=FORMAT)
    log = logging.getLogger()
    # log.setLevel(logging.DEBUG)

    client = ModbusTcpClient('192.168.0.179', port=502)
    client.connect()
    while True:
        try:
            rr = client.read_input_registers(0, 2, unit=UNIT)
            data = np.array(rr.registers, dtype=np.uint16)
            data = data.view(dtype=np.float32)[0]
            req_data = {"temperature": data}
            requests.put("http://127.0.0.1:8000/api/sensors/", data=req_data)
            sleep(1.0)
        except RuntimeError:
            client.close()
