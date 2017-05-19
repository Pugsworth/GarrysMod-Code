--[[{
    "password": "banni",
    "servers": [
        [
            "88.191.102.162",
            27015,
            37477,
            1
        ],
        [
            "88.191.109.120",
            27015,
            37477,
            2
        ],
        [
            "iriz.uk.to",
            80,
            9081,
            0
        ]
    ],
    "myid": 2
}]]
local oprint = print;
local print = function(...) oprint(...); epoe.MsgN(...); end

require('glsock2');
require('json'); -- garry's included json sucks ass

local servers = {
    {'88.191.102.162', 37477, 1},
    {'88.191.109.120', 37477, 2},
    {'127.0.0.1', 1234, 3} -- localhost for testing
};
local errortranslatetbl = {
    [0] = 'GLSOCK_ERROR_SUCCESS',
    [1] = 'GLSOCK_ERROR_ADDRESSFAMILYNOTSUPPORTED',
    [2] = 'GLSOCK_ERROR_ADDRESSINUSE',
    [3] = 'GLSOCK_ERROR_ALREADYCONNECTED',
    [4] = 'GLSOCK_ERROR_ALREADYSTARTED',
    [5] = 'GLSOCK_ERROR_BROKENPIPE',
    [6] = 'GLSOCK_ERROR_CONNECTIONABORTED',
    [7] = 'GLSOCK_ERROR_CONNECTIONREFUSED',
    [8] = 'GLSOCK_ERROR_CONNECTIONRESET',
    [9] = 'GLSOCK_ERROR_BADDESCRIPTOR',
    [10] = 'GLSOCK_ERROR_BADADDRESS',
    [11] = 'GLSOCK_ERROR_HOSTUNREACHABLE',
    [12] = 'GLSOCK_ERROR_INPROGRESS',
    [13] = 'GLSOCK_ERROR_INTERRUPTED',
    [14] = 'GLSOCK_ERROR_INVALIDARGUMENT',
    [15] = 'GLSOCK_ERROR_MESSAGESIZE',
    [16] = 'GLSOCK_ERROR_NAMETOOLONG',
    [17] = 'GLSOCK_ERROR_NETWORKDOWN',
    [18] = 'GLSOCK_ERROR_NETWORKRESET',
    [19] = 'GLSOCK_ERROR_NETWORKUNREACHABLE',
    [20] = 'GLSOCK_ERROR_NODESCRIPTORS',
    [21] = 'GLSOCK_ERROR_NOBUFFERSPACE',
    [22] = 'GLSOCK_ERROR_NOMEMORY',
    [23] = 'GLSOCK_ERROR_NOPERMISSION',
    [24] = 'GLSOCK_ERROR_NOPROTOCOLOPTION',
    [25] = 'GLSOCK_ERROR_NOTCONNECTED',
    [26] = 'GLSOCK_ERROR_NOTSOCKET',
    [27] = 'GLSOCK_ERROR_OPERATIONABORTED',
    [28] = 'GLSOCK_ERROR_OPERATIONNOTSUPPORTED',
    [29] = 'GLSOCK_ERROR_SHUTDOWN',
    [30] = 'GLSOCK_ERROR_TIMEDOUT',
    [31] = 'GLSOCK_ERROR_TRYAGAIN',
    [32] = 'GLSOCK_ERROR_WOULDBLOCK',
    [33] = 'GLSOCK_ERROR_ACCESSDENIED'
}

local function safeprint(...)
    local t = {...};
    if not t[2] then
        local sub = t[1]:gsub('%z', '\\z');
        print(sub);
    else
        for i = 1, #t do
            safeprint(t[i]);
        end
    end
end
IN_DBG = true;
local function DebugMessage(...)
    if not IN_DBG then return end
    local message = table.concat({...}, ' '):gsub('%z', '\\z\n');
    safeprint(message);
    -- chat.AddText(Color(255, 180, 45), message);
end


function CreateConnection(type)
    return GLSock(type or GLSOCK_TYPE_TCP);
end

function OnRead(sock, buffer, error)

    -- DebugMessage('[OnRead]', 'reading...');
    
    if error == GLSOCK_ERROR_SUCCESS then
        local count, data = buffer:Read(buffer:Size());
        -- DebugMessage('[OnRead]', 'count: ', count);
        if count > 0 then
            ProcessData(sock, data);
        end

        sock:Read(100, OnRead);

    else    
        DebugMessage('[OnRead]', errortranslatetbl[error], "~= GLSOCK_ERROR_SUCCESS; Socket closed!");
        sock:Cancel();
        sock:Close();
    end

end

function OnConnect(sock, error)

    if error == GLSOCK_ERROR_SUCCESS then
        
        DebugMessage('[OnConnect]', 'Socket[' .. tostring(sock) .. ']', 'connected');

        SendBurst();
        
        sock:Read(100, OnRead);
    else
        DebugMessage('[OnConnect]', errortranslatetbl[error], "~= GLSOCK_ERROR_SUCCESS; Socket closed!");
        sock:Cancel();
        sock:Close();
    end
    
end

local teamcolors = {
    Color(112, 208, 208), -- players
    Color(176, 90, 176), -- developers, but this is unused for now
    Color(207, 110, 90) -- owners, unused
};
local CHAT_COLOR_DEFAULT = Color(240, 234, 215); -- eggshell-ish white
local CHAT_COLOR_INVALID = Color(175, 0, 255); -- bright-ish purple
local CHAT_COLOR_CROSSSERVER = Color(126, 126, 126);

local function GetTeamColor(id)

    if teamcolors[id] then
        return teamcolors[id];
    else
        return CHAT_COLOR_INVALID;
    end

end

local function WriteChatMessage(sock, userid, message, thetype)

    thetype = thetype or 'chat';

    -- print('[WriteChatMessage]', tostring(sock), ', ', tostring(sock.plydata));

    if not sock.plydata or not sock.plydata[userid] then return end

    local data = sock.plydata[userid];
    local name, team = data.name, data.team;

    if thetype == 'chat' then
        chat.AddText(CHAT_COLOR_CROSSSERVER, string.format('#%d ', sock.serverID or -1), -- #3
                    GetTeamColor(team), name, -- Name
                    CHAT_COLOR_DEFAULT, ': ', message); -- : message
        -- #3 name: message

    elseif thetype == 'join' then
        chat.AddText(CHAT_COLOR_CROSSSERVER, string.format('#%d ', sock.serverID or -1),
            CHAT_COLOR_DEFAULT, "Player ",
            GetTeamColor(team), name,
            CHAT_COLOR_DEFAULT, " Has joined the game.");

    elseif thetype == 'leave' then
        chat.AddText(CHAT_COLOR_CROSSSERVER, string.format('#%d ', sock.serverID or -1),
            CHAT_COLOR_DEFAULT, "Player ",
            GetTeamColor(team), name,
            CHAT_COLOR_DEFAULT, " Has disconnected from the game.");
    end

end

local recbuffer = '';
function ProcessData(sock, argdata)
    
    if type(argdata) ~= "string" then return end

    -- safeprint('[Proc][raw]', argdata);

    local data = recbuffer .. argdata;
    local posstart = data:find('\0', 1, true);
    -- DebugMessage('[Proc][pos]', posstart);

    while posstart do

        local recdata = data:sub(1, posstart - 1);
        data = data:sub(posstart + 1, -1);

        -- safeprint("[Proc][safeprint]" .. recdata);
        
        local x = json.decode(recdata);
        if type(x) ~= 'table' then
            DebugMessage('[Proc]', tostring(x), 'expected table, got type', type(x));
            return;
        end
        
        local what = x[1]; -- the type of transmission 

        if what == 'say' then -- {"say",pl:UserID(),txt}
            local ply, message = x[2], x[3];
            WriteChatMessage(sock, ply, message);

        elseif what == 'hello' then -- {"hello",MYID,MYPW}
            sock.inburst = true;
            sock.plydata = {};
            sock.serverID = x[2];

        elseif what == 'endburst' then
            if sock.inburst == false then
                DebugMessage("[CrossChat] 'endburst' called without hello!!");
            end

            sock.inburst = false;

        elseif what == 'players' then -- {players",#player.GetAll()}
            sock.playercount = x[2];

        elseif what == 'join' then -- {"join",pl:UserID(),pl:SteamID64() or pl:SteamID() or "WTF",pl:Name(),pl:Team() or 0}

            sock.plydata[x[2]] = {['name'] = x[4], ['id'] = sock.serverID, ['team'] = x[5]};

            if not sock.inburst then
                WriteChatMessage(sock, ply, "", 'join');
                -- chat.AddText(string.format("Player: [%u] %s has joined #%d on team #%d", x[2], x[4], sock.serverID, x[5]));
                sock.playercount = sock.playercount + 1;
            end

        elseif what == 'leave' then -- {"leave",pl:UserID(),pl:SteamID64() or pl:SteamID() or "WTF"}
            if not sock or sock.plydata then continue end
            if not sock.plydata[x[2]] then print('[Proc][leave]', x[2], ', invalid??'); continue end

            local name = sock.plydata[x[2]];
            -- chat.AddText(string.format("Player [%u] %s has left #%d", x[2], name, sock.serverID));
            WriteChatMessage(sock, ply, "", 'leave');

            sock.plydata[x[2]] = nil;

            if not sock.inburst then
                sock.playercount = sock.playercount - 1;
            end

        else
            DebugMessage("[CrossChat]", "Unknown message type: (" .. what .. ")");
            safeprint(recdata);
        end

        posstart = data:find('\0', 1, true);

    end

    recbuffer = data;
    
end

function SendBurst()

    local bursttable = {
        {"hello", 80, 'banni'}, -- start burst, set server to 80
        {'players', 1}, -- send number of players; 1
        {'join', LocalPlayer():UserID(), LocalPlayer():SteamID64(), LocalPlayer():Name(), 2}, -- send userid, steamid, name, and team
        {'endburst'} -- end burst
    };
    
    local data = {};

    for i = 1, #bursttable do
        local encoded = json.encode(bursttable[i]);

        -- table.insert(data, encoded); -- insert encoded table
        -- table.insert(data, '\0'); -- null terminate it

        local buffer = GLSockBuffer();
            buffer:WriteString(encoded);
        sock:Send(buffer, function(sock, bytes, error)
            if error ~= GLSOCK_ERROR_SUCCESS then
                DebugMessage('[SendBurst]', bytes, errortranslatetbl[error]);
            end
        end);

    end
    
    -- local buffer = GLSockBuffer();
        -- buffer:Write(table.concat(data, "")); -- Write instead of WriteString because I'm manually adding the null terminator
    -- sock:Send(buffer, function(sock, bytes, error) print('Sent: ', bytes, errortranslatetbl[error]); end);
    -- TODO: how to handle 'sock'
    
end

hook.Add('OnPlayerChat', 'a', function(ply, message, teamonly, isdead)

    if message:sub(1, 1) == '!' then return end

    -- print('[Chat]', message:sub(1, 1));

    if teamonly then return end

    local tab = {'say', ply:UserID(), message};
    
    if sock and sock ~= nil then
        local buffer = GLSockBuffer();
        buffer:WriteString(json.encode(tab)); -- WriteString auto appends \0 at the end
        sock:Send(buffer, function(sock, bytes, error)
            if error ~= GLSOCK_ERROR_SUCCESS then
                DebugMessage('[Hook]', bytes, errortranslatetbl[error]);
            end
        end);

        -- print('Message Sent!');
    
    else
        DebugMessage('sock invalid!');
    end

end);

if sock then
    sock:Cancel();
    sock:Close();
    sock = nil;
    DebugMessage("Previous sock exists, closing");
end

sock = CreateConnection(GLSOCK_TYPE_TCP);

local ip, port = unpack(servers[1]);
DebugMessage('[IP]', ip, port);
sock:Connect(ip, port, OnConnect);

