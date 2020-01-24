class SH1107 {

    static VERSION = "1.0.0";

    _i2c             = null;
    _hsize           = null;
    _vsize           = null;
    _address         = null;
    _initialized     = false;

    // Parameters:
    //    i2c          An I2C bus
    //    address      Slave address
    //    hsize        Number of pixels per line
    //    vsize        Number of pixels per column
    constructor(i2c, address=0x78, hsize = 128, vsize = 128) {
      _i2c = i2c;
      _hsize = hsize;
      _vsize = vsize;
      assert(vsize%8 == 0);
      _address = address;
    }

    function init() {
      _send_command(0xAE); // Display OFF
      imp.sleep(0.005);
      _send_command(0xAF); // Display ON
      imp.sleep(0.005);
      _send_command(0xA7); // Inverted display
      _send_command(0x20); // Set addressing mode
      _send_command(0x00); // Horizontal

      _initialized = true;
    }

    function send_screen(pixeldata) {
      if (!_initialized) {
        server.log("Paint attempt before initialization, skip");
        return;
      }

      if (pixeldata.len() != (_hsize * _vsize) / 8) {
        server.log(format("Image dimensions (%d) didn't match the screen size (%d)", pixeldata.len(), (_hsize * _vsize) / 8));
      }
     
      for (local i = 0; i < _vsize/8; i++) {
        pixeldata.seek(_hsize*i, 'b');
        _send_page(i, pixeldata.readstring(_hsize));
      }
    }

    function _send_command(command) {
      local sendString = format("%c%c", 0x80, command);
      _i2c.write(_address, sendString);
    }

    function _send_data(data) {
      local sendString = "\x40" + data;
      _i2c.write(_address, sendString);
    }

    function _send_page(pagenum, pagedata) {
      _send_command(0xB0 | pagenum);
      _send_command(0x00);
      _send_command(0x10);
      _send_data(pagedata);
    }

}
