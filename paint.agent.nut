function infohandler(data) {
    server.log("Got device data: " + data);
    
    server.log(http.jsonencode(device.info()));
}

device.on("data", infohandler);


const pageTemplate = "@{include('html/agent.html')|escape}";

function requestHandler(request, response) {
    try {
        if (request.method == "GET") {
            if (request.path == "/") {
                response.send(200, format(pageTemplate, http.agenturl()));
            } else {
                response.send(404, "Not found");
            }
        } else if (request.method == "POST") {
            local decoded = http.jsondecode(request.body);
            pixeldata <- http.base64decode(decoded["bytes"]);
            local pixelblob = blob(128*128/8);
            
            for (local index = 0 ; index < pixeldata.len(); index = index + 4) {
                if (pixeldata[index+3] != 0) {
                    local x = (index/4) % 128;
                    local y = (index/4) / 128;
                    
                    local page = y/8;
                    local addr = x;
                    local bit = y%8;
                    pixelblob[addr+128*page] = pixelblob[addr+128*page] | (1 << bit);
                }
            }
            

            local device_message = {};
            device_message["stride"] <- 128;
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

