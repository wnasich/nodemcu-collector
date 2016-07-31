telnetsrv = net.createServer(net.TCP, 180)

telnetsrv:listen(23, function(socket)
    local fifo = {}
    local fifo_drained = true

    local function sender(sck)
        if #fifo > 0 then
            sck:send(table.remove(fifo, 1))
        else
            fifo_drained = true
        end
    end

    local function s_output(str)
        table.insert(fifo, str)
        if socket ~= nil and fifo_drained then
            fifo_drained = false
            sender(socket)
        end
    end

    node.output(s_output, 0)

    socket:on('receive', function(c, l)
        node.input(l)
    end)
  
    socket:on('disconnection', function(c)
        node.output(nil)        
    end)
  
    socket:on('sent', sender)
    socket:send('Welcome to NodeMCU collector.\n> ')
end)
