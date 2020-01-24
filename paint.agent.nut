function infohandler(data) {
    server.log("Got device data: " + data);
    
    server.log(http.jsonencode(device.info()));
}

device.on("data", infohandler);


const pageTemplate = "@{include('html/agent.html')|escape}";
const hsize = 128;
const vsize = 128;

assert (vsize%8 == 0);

function requestHandler(request, response) {
    try {
        if (request.method == "GET") {
            if (request.path == "/") {
                response.send(200, format(pageTemplate, http.agenturl(), hsize, vsize));
            } else {
                response.send(404, "Not found");
            }
        } else if (request.method == "POST") {
            local decoded = http.jsondecode(request.body);
            pixeldata <- http.base64decode(decoded["bytes"]);
            local pixelblob = blob(hsize*vsize/8);
            
            if (pixeldata.len() != hsize*vsize*4) {
                server.log(format("Bad image size %d when %d expected", pixeldata.len(), hsize*vsize*4));
                response.send(400, "Bad request");
                return;
            }

            for (local index = 0 ; index < pixeldata.len(); index = index + 4) {
                if (pixeldata[index+3] != 0) {
                    local x = (index/4) % hsize;
                    local y = (index/4) / hsize;
                    
                    local page = y/8;
                    local addr = x;
                    local bit = y%8;
                    pixelblob[addr+hsize*page] = pixelblob[addr+hsize*page] | (1 << bit);
                }
            }
            

            local device_message = {};
            device_message["stride"] <- hsize;
            device_message["pixels"] <- pixelblob;
            device.send("image", device_message);
            response.send(200, "OK");
        } else {
            response.send(400, "Bad request");
        }
        
    } catch (exp) {
        server.log(exp);
        response.send(500, "Error");
    }
}

// Register your HTTP request handler
// NOTE your agent code can only have ONE handler
http.onrequest(requestHandler);

server.log(http.agenturl());

