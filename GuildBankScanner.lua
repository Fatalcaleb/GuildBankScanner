local addonName, addonTable = ...

-- Event handler frame
local frame = CreateFrame("Frame")
frame:RegisterEvent("GUILDBANKFRAME_OPENED")
frame:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "GUILDBANKFRAME_OPENED" then
        ScanGuildBank()
    elseif event == "GUILDBANKBAGSLOTS_CHANGED" then
        ScanGuildBank()
    end
end)

-- Function to scan the guild bank
function ScanGuildBank()
    local guildBankData = {}
    for tab = 1, GetNumGuildBankTabs() do
        for slot = 1, MAX_GUILDBANK_SLOTS_PER_TAB or 98 do
            local itemLink = GetGuildBankItemLink(tab, slot)
            if itemLink then
                local _, itemCount = GetGuildBankItemInfo(tab, slot)
                table.insert(guildBankData, { itemLink = itemLink, itemCount = itemCount })
            end
        end
    end
    PostToDiscord(guildBankData)
end

-- Function to post data to Discord
function PostToDiscord(guildBankData)
    local webhookURL = "YOUR_DISCORD_WEBHOOK_URL"
    local message = "Guild Bank Contents:\n"

    for _, item in ipairs(guildBankData) do
        message = message .. item.itemLink .. " x" .. item.itemCount .. "\n"
    end

    SendWebhookMessage(webhookURL, message)
end

-- Function to send a message to a Discord webhook
function SendWebhookMessage(webhookURL, message)
    local jsonData = {
        ["content"] = message
    }
    local jsonDataString = JSON:encode(jsonData)

    local body = {
        method = "POST",
        url = webhookURL,
        headers = {
            ["Content-Type"] = "application/json"
        },
        data = jsonDataString
    }

    C_HttpRequest:SendRequest(body)
end
