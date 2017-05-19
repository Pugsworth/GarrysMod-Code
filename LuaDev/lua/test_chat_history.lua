ChatHistory = ChatHistory or {};

local vguiMenu = nil;
local function ShowMenu()
    local panel = vgui.Create("DListLayout");
    panel:SetPos(x, y);
    panel:SetSize(w, h);

    local historyLength = #ChatHistory;
    local lbl,idx,text;

    for i = 1, 10 do
        lbl = vgui.Create("DLabel");
        idx = historyLength - i;
        text = ChatHistory[idx];

        if text == nil then break; end
        lbl:SetText(text);
        panel:Add(lbl);
    end

    panel:Show();
end

local function SelectMenuItem(text)
    if not vguiMenu then
        ShowMenu();
    end

    local children = vguiMenu:GetChildren();
    for
end

local function CloseMenu()

    if vguiMenu then
        vguiMenu:Hide();
        vguiMenu:Remove();
    end

end



local tmpCurrentText = nil;
hook.Add("OnPlayerChat", "chat history", function(ply, text, teamchat, isDead)
    if ply == LocalPlayer() then
        table.RemoveByValue(ChatHistory, text);
        local index = table.insert(ChatHistory, text);
        print(string.format("Added \"%s\" to history at %i", text, index));

    end
end);

local bHistorySelected = false;
local historyIndex = 0;

hook.Add("FinishChat", "chat history", function()
    tmpCurrentText = nil;
    CloseMenu();
    if input.IsKeyDown(KEY_ENTER) then
        local index = #ChatHistory - historyIndex;
        print("FinishChat - Pre:", index, ChatHistory[index]);
        historyIndex = historyIndex + 1;
        local index = #ChatHistory - historyIndex;
        print("FinishChat - Post:", index, ChatHistory[index]);
    end
end);

hook.Add("OnChatTab", "chat history", function(text)
    print("OnChatTab", text);
    if bHistorySelected then
        bHistorySelected = false;

        local historyLength = #ChatHistory;
        local index = historyLength - historyIndex;
        return ChatHistory[index];
    end
end);


hook.Add("ChatTextChanged", "chat history", function(text)

    local historyAction = false;
    local historyLength = #ChatHistory;

    if input.IsKeyDown(KEY_DOWN) and historyIndex < historyLength-1 then
        print("+");
        historyIndex = historyIndex + 1;
        historyAction = true;

    elseif input.IsKeyDown(KEY_UP) and historyIndex > 0 then
        print("-");
        historyIndex = historyIndex - 1;
        historyAction = true;
    end

    print("esc", input.IsKeyDown(KEY_ESCAPE))

    if historyAction then
        bHistorySelected = true;
        ShowMenu();

        if tmpCurrentText == nil then
            tmpCurrentText = text;
        end

        local index = historyLength - historyIndex;
        local result = ChatHistory[index];
        print(string.format("ChatHistory: [%i] \"%s\"", index, result));

        return result;

    end

end);


