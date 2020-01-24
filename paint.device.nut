@include "lib/sh1107.device.nut"

i2c_device <- hardware.i2c89;

i2c_device.configure(CLOCK_SPEED_400_KHZ);

oled_controller <- SH1107(i2c_device);

oled_controller.init();

function handleImage(data) {
    server.log("Device got an image");
    oled_controller.send_screen(data["pixels"]);
}
agent.on("image", handleImage);
