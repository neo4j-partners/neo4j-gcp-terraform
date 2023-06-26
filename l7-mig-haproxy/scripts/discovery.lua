    local function neo4j_discovery(applet)
        local function ends_with(str, ending)
            return ending == "" or str:sub(-#ending) == ending
        end
        -- what's the client trying to access???
        local reqhost = applet.headers["host"][0]
        if not reqhost then
            core.Alert("request doesn't have host header!?")
            return
        end
        -- because the js driver will provide a default port if we don't!
        if not ends_with(reqhost, ":8080") then
            reqhost = reqhost .. ":80"
        end
        core.Info(string.format("translating discovery request with reqhost: %s", reqhost))
        
        -- look for a particular backend named "neo4j-http"
        local httpbe = core.backends["neo4j-http"]
        if not httpbe then
            core.Alert("cannot find backend named 'neo4j-http'")
            return
        end
        
        -- get the first server in our backend
        local server = nil
        for k, v in pairs(httpbe.servers) do
            server = v
            break
        end
        local host = server:get_addr()
        if not host then
            core.Alert(string.format("can't get a host value for server %s", server))
            return
        end
        
        core.Info(string.format("using backend server %s", host))
        local hdrs = {
            [1] = string.format('host: %s', host),
            [2] = 'accept: application/json',
            [3] = 'connection: close'
        }
        
        local req = {
            [1] = string.format('GET / HTTP/1.1'),
            [2] = table.concat(hdrs, '\r\n'),
            [3] = '\r\n'
        }
        
        req = table.concat(req, '\r\n')
        
        local socket = core.tcp()
        socket:settimeout(5)
        
        if socket:connect(host) then
            if socket:send(req) then
                -- pull off headers
                while true do
                    local line, _ = socket:receive('*l')
                    if not line then
                        break
                    end
                    if line == '' then
                        break
                    end
                end
                
                -- process body line by line
                local content = ""
                while true do
                    local line, _ = socket:receive('*l')
                    if not line then
                        break
                    end
                    if line == '' then
                        break
                    end
                    
                    local start = string.find(line, "//")
                    if start ~= nil then
                        local finish = string.find(line, '[/"]', start + 2)
                        content = content .. string.sub(line, 1, start + 1) .. reqhost .. string.sub(line, finish) .. "\n"
                    else
                        content = content .. line .. "\n"
                    end
                end
                if content then
                    applet:set_status(200)
                    applet:add_header('content-length', string.len(content))
                    applet:add_header('content-type', 'application/json')
                    applet:start_response()
                    applet:send(content)
                end
            else
                core.Alert('Could not connect to Neo4j')
            end
            
            socket:close()
        else
            core.Alert('Could not connecto to Neo4j')
        end

    end

    core.register_service('neo4j_discovery', 'http', neo4j_discovery)
