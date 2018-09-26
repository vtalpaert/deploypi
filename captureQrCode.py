import os
import picamera


default_image_path = "/tmp/capture.jpeg"
decoder_exec_path = "~/zxing-cpp/build/zxing"


class CaptureQrCode(object):

    def __init__(self, image_path=default_image_path):
        self.image_path = image_path
        self.camera = picamera.PiCamera()

    def _capture(self):
        self.camera.capture(self.image_path)

    def _decode(self):
        return os.popen(decoder_exec_path + " " + default_image_path).read()

    def getCode(self):
        self._capture()
        output = self._decode()
        if output == "decoding failed":
            return None
        else:
            return output


if __name__ == "__main__":
    capture = CaptureQrCode()
    while True:
        print [capture.getCode()]
