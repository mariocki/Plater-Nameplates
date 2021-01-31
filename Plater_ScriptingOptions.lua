

local Plater = _G.Plater
local GameCooltip = GameCooltip2
local DF = DetailsFramework
local _
local unpack = _G.unpack
local tremove = _G.tremove
local CreateFrame = _G.CreateFrame
local tinsert = _G.tinsert


--tab indexes
local PLATER_OPTIONS_SCRIPTING_TAB = 6

--options
local edit_script_size = {620, 431}
local scrollbox_line_backdrop_color = {0, 0, 0, 0.5}
local buttons_size = {120, 20}
local luaeditor_backdrop_color = {.2, .2, .2, .5}
local luaeditor_border_color = {0, 0, 0, 1}

--get templates
local options_text_template = DF:GetTemplate ("font", "OPTIONS_FONT_TEMPLATE")
local options_dropdown_template = DF:GetTemplate ("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
local options_switch_template = DF:GetTemplate ("switch", "OPTIONS_CHECKBOX_TEMPLATE")
local options_slider_template = DF:GetTemplate ("slider", "OPTIONS_SLIDER_TEMPLATE")
local options_button_template = DF:GetTemplate ("button", "OPTIONS_BUTTON_TEMPLATE")

options_dropdown_template = DF.table.copy({}, options_dropdown_template)
options_dropdown_template.backdropcolor = {.2, .2, .2, .8}

options_slider_template = DF.table.copy({}, options_slider_template)
options_slider_template.backdropcolor = {.2, .2, .2, .8}

options_button_template = DF.table.copy({}, options_button_template)
options_button_template.backdropcolor = {.2, .2, .2, .8}


function Plater.CreateScriptingOptionsPanel(parent, mainFrame)
    local script_options_topleft_anchor = {235, -25}
    local script_options_scroll_size = {170, 389}
    local script_options_scrollbox_lines = 15
    local script_options_line_height = 24
    local script_options_background_size = {620, 453}
    local options_frame_width = 407
    local options_frame_shared_height = 100
    local options_frame_widget_options_height = 259
    
    if (_G.PlaterOptionsPanelContainer.AllFrames[PLATER_OPTIONS_SCRIPTING_TAB] == mainFrame) then --scripting tab
        script_options_background_size = {620, 407}
        script_options_scroll_size = {170, 369}
        options_frame_widget_options_height = 264 - 25
        script_options_topleft_anchor = {230, -25}
        options_frame_width = 420
    end

    local iconList = {
        "Interface\\AddOns\\Plater\\images\\option_color", --1
        "Interface\\AddOns\\Plater\\images\\option_number", --2
        "Interface\\AddOns\\Plater\\images\\option_text", --3
        "Interface\\AddOns\\Plater\\images\\option_bool", --4
        "Interface\\AddOns\\Plater\\images\\option_label", --5
        "Interface\\AddOns\\Plater\\images\\option_blank", --6
        "Interface\\AddOns\\Plater\\images\\option_list", --7 list
    }

    --> admin script options (this frame is used to configurate the options which the script has)
    --> far below this code there's the code for user options frame
        local adminFrame = CreateFrame("frame", "$parentEditScriptOptionsAdmin", parent, BackdropTemplateMixin and "BackdropTemplate")
        adminFrame:SetSize(script_options_background_size[1], script_options_background_size[2])
        adminFrame:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
        adminFrame:SetBackdropBorderColor (unpack (luaeditor_border_color))
        adminFrame:SetBackdropColor (unpack (luaeditor_backdrop_color))
        mainFrame.ScriptOptionsPanelAdmin = adminFrame
        adminFrame:Hide()

    --> user script options (this frame is where the end user adjust the script settings)
        local userFrame = CreateFrame("frame", "$parentEditScriptOptionsUser", parent, BackdropTemplateMixin and "BackdropTemplate")
        userFrame:SetSize(edit_script_size[1], edit_script_size[2])
        userFrame:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
        userFrame:SetBackdropBorderColor (unpack (luaeditor_border_color))
        userFrame:SetBackdropColor (unpack (luaeditor_backdrop_color))
        mainFrame.ScriptOptionsPanelUser = userFrame
        userFrame:Hide()

        --regular buttons admin frame
        do
            --save button
            local save_script_button = DF:CreateButton (adminFrame, mainFrame.SaveScript, buttons_size[1], buttons_size[2], "Save", -1, nil, nil, nil, nil, nil, options_button_template, DF:GetTemplate ("font", "PLATER_BUTTON"))
            save_script_button:SetIcon ([[Interface\BUTTONS\UI-Panel-ExpandButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
            save_script_button.tooltip = "While editing, you may use:\n\n|cFFFFFF00SHIFT + Enter|r: save the script, apply the changes and don't lose the focus on the editor.\n\n|cFFFFFF00CTRL + Enter|r: save the script and apply the changes."
            save_script_button:SetFrameLevel(adminFrame:GetFrameLevel()+11)
            
            --cancel button
            local cancel_script_button = DF:CreateButton (adminFrame, mainFrame.CancelEditing, buttons_size[1], buttons_size[2], "Cancel", -1, nil, nil, nil, nil, nil, options_button_template, DF:GetTemplate ("font", "PLATER_BUTTON"))
            cancel_script_button:SetIcon ([[Interface\BUTTONS\UI-Panel-MinimizeButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
            cancel_script_button:SetFrameLevel(adminFrame:GetFrameLevel()+11)

            --documentation icon
            local docs_button = DF:CreateButton (adminFrame, mainFrame.OpenDocs, buttons_size[1], buttons_size[2], "Docs", -1, nil, nil, nil, nil, nil, options_button_template, DF:GetTemplate ("font", "PLATER_BUTTON"))
            docs_button:SetIcon ([[Interface\BUTTONS\UI-GuildButton-PublicNote-Up]], 16, 16, "overlay", {0, 1, 0, 1})
            docs_button:SetFrameLevel(adminFrame:GetFrameLevel()+11)

            if (mainFrame:GetName() == "PlaterOptionsPanelContainerScripting") then
                save_script_button:SetPoint ("topright", mainFrame.CodeEditorLuaEntry, "bottomright", 0, 21)
            else
                save_script_button:SetPoint ("topright", mainFrame.CodeEditorLuaEntry, "bottomright", 0, -25)
            end
            
            cancel_script_button:SetPoint ("right", save_script_button, "left", -20, 0)
            docs_button:SetPoint ("right", cancel_script_button, "left", -20, 0)
        end

        --regular buttons user frame
        do
            --save button
            local save_script_button = DF:CreateButton (userFrame, mainFrame.SaveScript, buttons_size[1], buttons_size[2], "Save", -1, nil, nil, nil, nil, nil, options_button_template, DF:GetTemplate ("font", "PLATER_BUTTON"))
            save_script_button:SetIcon ([[Interface\BUTTONS\UI-Panel-ExpandButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
            save_script_button.tooltip = "While editing, you may use:\n\n|cFFFFFF00SHIFT + Enter|r: save the script, apply the changes and don't lose the focus on the editor.\n\n|cFFFFFF00CTRL + Enter|r: save the script and apply the changes."
            save_script_button:SetFrameLevel(userFrame:GetFrameLevel()+11)
            
            --cancel button
            local cancel_script_button = DF:CreateButton (userFrame, mainFrame.CancelEditing, buttons_size[1], buttons_size[2], "Cancel", -1, nil, nil, nil, nil, nil, options_button_template, DF:GetTemplate ("font", "PLATER_BUTTON"))
            cancel_script_button:SetIcon ([[Interface\BUTTONS\UI-Panel-MinimizeButton-Up]], 20, 20, "overlay", {0.1, .9, 0.1, .9})
            cancel_script_button:SetFrameLevel(userFrame:GetFrameLevel()+11)

            --documentation icon
            local docs_button = DF:CreateButton (userFrame, mainFrame.OpenDocs, buttons_size[1], buttons_size[2], "Docs", -1, nil, nil, nil, nil, nil, options_button_template, DF:GetTemplate ("font", "PLATER_BUTTON"))
            docs_button:SetIcon ([[Interface\BUTTONS\UI-GuildButton-PublicNote-Up]], 16, 16, "overlay", {0, 1, 0, 1})
            docs_button:SetFrameLevel(userFrame:GetFrameLevel()+11)

            if (mainFrame:GetName() == "PlaterOptionsPanelContainerScripting") then
                save_script_button:SetPoint ("topright", mainFrame.CodeEditorLuaEntry, "bottomright", 0, 21)
            else
                save_script_button:SetPoint ("topright", mainFrame.CodeEditorLuaEntry, "bottomright", 0, -25)
            end

            cancel_script_button:SetPoint ("right", save_script_button, "left", -20, 0)
            docs_button:SetPoint ("right", cancel_script_button, "left", -20, 0)
        end
        
        local createNewOptionButtonFunction = function(button, buttontype, param1, param2)
            --get the current selected script
            local scriptObject = mainFrame.GetCurrentScriptObject() --can be hook or script
            if (scriptObject) then
                --does the table exists? old scripts does not have them
                local optionsTable = scriptObject.Options
                local optionIndex = #scriptObject.Options + 1
                local selectedOptionType = mainFrame.SelectScriptOptionTypeDropdown.value

                local newOptionObject = {
                    Type = selectedOptionType,
                    Name = "Option " .. optionIndex,
                    Key = "option" .. optionIndex,
                    Desc = "",
                    Icon = "",
                }

                --> how to add more options:
                    --add belowa new type
                    --add its name into the local 'listOfAvailableOptions'
                    --goto ~options (search) add the frame for the option, can copy paste from an existing
                    --goto ~useroptions to add the option on the user options frame
                
                --add variables by option type
                if (selectedOptionType == 1) then --color
                    newOptionObject.Value = {1, 1, 1, 1}
                    newOptionObject.Icon = iconList[selectedOptionType]

                elseif (selectedOptionType == 2) then --number
                    newOptionObject.Value = 0.5
                    newOptionObject.Min = 0
                    newOptionObject.Max = 1
                    newOptionObject.Fraction = true
                    newOptionObject.Icon = iconList[selectedOptionType]

                elseif (selectedOptionType == 3) then --text
                    newOptionObject.Value = ""
                    newOptionObject.Icon = iconList[selectedOptionType]

                elseif (selectedOptionType == 4) then --toggle
                    newOptionObject.Value = false
                    newOptionObject.Icon = iconList[selectedOptionType]

                elseif (selectedOptionType == 5) then --label (a text to name a section of options)
                    newOptionObject.Value = "New Section Name"
                    newOptionObject.Icon = iconList[selectedOptionType]

                elseif (selectedOptionType == 6) then --black space
                    newOptionObject.Value = 0
                    newOptionObject.Icon = iconList[selectedOptionType]

                elseif (selectedOptionType == 7) then --list
                    newOptionObject.Value = {}
                    newOptionObject.Icon = iconList[selectedOptionType]
                end

                --add it
                scriptObject.Options[optionIndex] = newOptionObject

                --refresh script scroll
                mainFrame.ScriptOptionsScrollBox:Refresh()
                mainFrame.ScriptOptionsScrollBox:Show()
                --select the new option created
                mainFrame.selectScriptOptionToEdit(optionIndex)

                --show the edit panel

            end
        end

        --top left dropdown to create a new option
        local listOfAvailableOptions = {
            "Color", --just a simple color, can also represent a vector4
            "Number", --scalar number
            "Text", --any text, can be just a regular text, a texture path, etc
            "Toggle", --just a yes or not
            "Label", --a text to name a section in the options
            "Blank Line", --an empty line to separate two sections
            --"List Panel", --a panel to add values to a list
        }
        local getListOfAvailableOptions = function()
            local t = {}
            for i = 1, #listOfAvailableOptions do
                local option = listOfAvailableOptions[i]
                t [#t + 1] = {label = option, value = i, onclick = function()end, desc = "Select which option to add", tooltipwidth = 300, icon = iconList[i]}
            end
            return t
        end

        local createOptionLabel = DF:CreateLabel (adminFrame, "Create New Option:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
        local createOptionDropdown = DF:CreateDropDown (adminFrame, getListOfAvailableOptions, 1, 130, 20, nil, nil, options_dropdown_template)
        createOptionLabel:SetPoint("topleft", parent, "topleft", unpack(script_options_topleft_anchor))
        createOptionDropdown:SetPoint("topleft", createOptionLabel, "bottomleft", 0, -2)
        mainFrame.SelectScriptOptionTypeDropdown = createOptionDropdown

        --button to commit the creation at the right of the dropdown
        local createOptionButton = DF:CreateButton (adminFrame, createNewOptionButtonFunction, 60, 20, "Add", -1, nil, nil, nil, nil, nil, options_button_template, DF:GetTemplate ("font", "PLATER_BUTTON"))
        createOptionButton:SetPoint("left", createOptionDropdown, "right", 2, 0)
        mainFrame.CreateOptionForScriptButton = createOptionButton

        --left script box containing the created options for this script
            local refreshScriptOptionsScrollBox = function (self, data, offset, totalLines)
                for i = 1, totalLines do
                    local index = i + offset
                    local option = data[index]
                    if (option) then
                        local line = self:GetLine(i)
                        line.Icon:SetTexture(option.Icon)
                        line.OptionNameLabel:SetText(option.Name)
                        line.TypeLabel:SetText(listOfAvailableOptions[option.Type])
                        line.RemoveButton.optionIndex = index
                        line.optionIndex = index
                        line.GoDownButton.widget.optionIndex = index
                        line.GoUpButton.widget.optionIndex = index
                        line.DuplicateButton.widget.optionIndex = index

                        if (mainFrame.optionSelected == index) then
                            line:SetBackdropColor (1, .6, 0, 0.5)
                            line.IsEditing = true
                        else
                            line.IsEditing = false
                            line:SetBackdropColor (unpack (scrollbox_line_backdrop_color))
                        end
                    end
                end
            end

            local onEnterScriptOptionButton = function(self)

            end

            local onLeaveScriptOptionButton = function(self)

            end

            local onMouseUpScriptOptionButton = function(self)
                mainFrame.selectScriptOptionToEdit(self.optionIndex)
            end

            function mainFrame.selectScriptOptionToEdit(optionIndex)
                --hide all frames holding options for specific types of options
                for i = 1, #mainFrame.TypeFrames do
                    mainFrame.TypeFrames[i]:Hide()
                end
                
                mainFrame.optionSelected = optionIndex
                mainFrame.ScriptOptionsScrollBox:Refresh()
                mainFrame.SharedOptionsFrame:RefreshOptions()

                local scriptObject = mainFrame.GetCurrentScriptObject()
                local optionType
                if (scriptObject) then
                    local scriptOption = scriptObject.Options[optionIndex]
                    optionType = scriptOption.Type
                end

                mainFrame.SharedOptionsFrame:Show()

                --show the frame for this option type
                mainFrame.TypeFrames[optionType]:Show()
                mainFrame.TypeFrames[optionType]:RefreshOptions()
            end

            local onMouseUpDeleteOptionButton = function(self, button)
                local optionIndex = self.optionIndex
                mainFrame.deleteScriptOption(optionIndex)
            end

            function mainFrame.deleteScriptOption(optionIndex)
                local scriptObject = mainFrame.GetCurrentScriptObject() --can be hook or script
                if (scriptObject) then
                    local scriptOptions = scriptObject.Options
                    tremove(scriptOptions, optionIndex)
                    mainFrame.ScriptOptionsScrollBox:Refresh()
                end
            end

            --make an option go up in the order
            local onMouseUpGoUpOptionButton = function(self)
                local optionIndex = self.optionIndex
                local scriptObject = mainFrame.GetCurrentScriptObject()
                if (scriptObject) then
                    --if this is already the first option
                    if (optionIndex == 1) then
                        return
                    end

                    local moveUp = scriptObject.Options[optionIndex]
                    local moveDown = scriptObject.Options[optionIndex-1]

                    if (moveUp and moveDown) then
                        tremove(scriptObject.Options, optionIndex)
                        tinsert(scriptObject.Options, optionIndex-1, moveUp)
                    end

                    mainFrame.ScriptOptionsScrollBox:Refresh()
                end
            end
            --make an option go down in the order
            local onMouseUpGoDownOptionButton = function(self)
                local optionIndex = self.optionIndex
                local scriptObject = mainFrame.GetCurrentScriptObject()
                if (scriptObject) then
                    --if this is the last script
                    if (optionIndex == #scriptObject.Options) then
                        return
                    end

                    local moveDown = scriptObject.Options[optionIndex]
                    local moveUp = scriptObject.Options[optionIndex+1]

                    if (moveUp and moveDown) then
                        tremove(scriptObject.Options, optionIndex)
                        tinsert(scriptObject.Options, optionIndex+1, moveDown)
                    end

                    mainFrame.ScriptOptionsScrollBox:Refresh()
                end
            end

            --duplicate the option
            local onclick_menu_option_export = function(cooltip, scriptType, payload)
                local scriptId, mainFrame, button, optionCopy = unpack(payload)
                local scriptData = Plater.db.profile[scriptType] --script_data hook_data
                local scriptObject = scriptData[scriptId]

                if (scriptObject) then
                    scriptObject.Options = scriptObject.Options or {}
                    tinsert(scriptObject.Options, #scriptObject.Options+1, optionCopy)
                    mainFrame.ScriptOptionsScrollBox:Refresh()
                    Plater:Msg("Option '" .. optionCopy.Name .. "' copied to '" .. scriptObject.Name .. "'.")
                end

                GameCooltip:Close()
            end

            local onclick_menu_option_duplicate = function(cooltip, scriptOptionIndex, optionSelected, payload)

                local mainFrame, button, optionCopy = unpack(payload)

                if (optionSelected == 1) then --duplicate
                    local scriptObject = mainFrame.GetCurrentScriptObject()
                    if (scriptObject) then
                        tinsert(scriptObject.Options, scriptOptionIndex+1, optionCopy)
                        mainFrame.ScriptOptionsScrollBox:Refresh()
                    end

                    GameCooltip:Close()

                elseif (optionSelected == 2) then --copy to another script
                    GameCooltip:Preset (2)
                    GameCooltip:SetType ("menu")
                    GameCooltip:SetOption ("TextSize", 10)
                    GameCooltip:SetOption ("FixedWidth", 200)
                    GameCooltip:SetOption ("ButtonsYModSub", -1)
                    GameCooltip:SetOption ("YSpacingModSub", -4)
                    GameCooltip:SetOwner (button, "topleft", "topright", 2, 0)
                    GameCooltip:SetFixedParameter ("script_data")
        
                    --build a list of scripts (from the script tab)
                    local allScripts = Plater.db.profile.script_data
                    if (allScripts) then
                        for i = 1, #allScripts do
                            GameCooltip:AddLine (allScripts[i].Name)
                            GameCooltip:AddMenu (1, onclick_menu_option_export, {i, mainFrame, button, optionCopy})
                            GameCooltip:AddIcon ([[Interface\AddOns\Plater\images\icons]], 1, 1, 16, 16, 3/512, 21/512, 215/512, 233/512)
                        end
                    end
                    GameCooltip:SetOption("SubFollowButton", true)
                    GameCooltip:Show()

                elseif (optionSelected == 3) then --copy to another mod
                    GameCooltip:Preset (2)
                    GameCooltip:SetType ("menu")
                    GameCooltip:SetOption ("TextSize", 10)
                    GameCooltip:SetOption ("FixedWidth", 200)
                    GameCooltip:SetOption ("ButtonsYModSub", -1)
                    GameCooltip:SetOption ("YSpacingModSub", -4)
                    GameCooltip:SetOwner (button, "topleft", "topright", 2, 0)
                    GameCooltip:SetFixedParameter ("hook_data")
        
                    --build a list of mods (from the modding tab)
                    local allMods = Plater.db.profile.hook_data
                    if (allMods) then
                        for i = 1, #allMods do
                            GameCooltip:AddLine (allMods[i].Name)
                            GameCooltip:AddMenu (1, onclick_menu_option_export, {i, mainFrame, button, optionCopy})
                            GameCooltip:AddIcon ([[Interface\AddOns\Plater\images\icons]], 1, 1, 16, 16, 3/512, 21/512, 215/512, 233/512)
                        end
                    end
                    GameCooltip:SetOption("SubFollowButton", true)
                    GameCooltip:Show()
                end
            end

            local onMouseUpDuplicateOptionButton = function(self)
                local optionIndex = self.optionIndex

                GameCooltip:Preset (2)
                GameCooltip:SetType ("menu")
                GameCooltip:SetOption ("TextSize", 10)
                GameCooltip:SetOption ("FixedWidth", 200)
                GameCooltip:SetOption ("ButtonsYModSub", -1)
                GameCooltip:SetOption ("YSpacingModSub", -4)
                GameCooltip:SetOwner (self, "topleft", "topright", 2, 0)
                GameCooltip:SetFixedParameter (optionIndex)

                --send a copy of the option as payload
                local optionCopy = DF.table.copy({}, mainFrame.GetCurrentScriptObject().Options[optionIndex])

                local payload = {mainFrame, self, optionCopy}

                GameCooltip:AddLine ("Duplicate Here")
                GameCooltip:AddMenu (1, onclick_menu_option_duplicate, 1, payload)
                GameCooltip:AddIcon ([[Interface\BUTTONS\UI-GuildButton-PublicNote-Up]], 1, 1, 16, 16)
                
                GameCooltip:AddLine ("Copy to Another Script")
                GameCooltip:AddMenu (1, onclick_menu_option_duplicate, 2, payload)
                GameCooltip:AddIcon ([[Interface\AddOns\Plater\images\icons]], 1, 1, 16, 16, 3/512, 21/512, 215/512, 233/512)

                GameCooltip:AddLine ("Copy to Another Mod")
                GameCooltip:AddMenu (1, onclick_menu_option_duplicate, 3, payload)
                GameCooltip:AddIcon ([[Interface\AddOns\Plater\images\icons]], 1, 1, 16, 16, 3/512, 21/512, 215/512, 233/512)

                GameCooltip:SetOption("SubFollowButton", true)
                GameCooltip:Show()
            end
            
            --create a new line within the scrollbox containing options created to edit
            local optionsListCreateLine = function (self, index)
                local line = CreateFrame ("button", "$parentLine" .. index, self, BackdropTemplateMixin and "BackdropTemplate")
                
                --set its parameters
                line:SetPoint ("topleft", self, "topleft", 0, -((index-1) * (script_options_line_height+1)))
                line:SetSize (script_options_scroll_size[1], script_options_line_height)

                line:SetScript ("OnEnter", onEnterScriptOptionButton)
                line:SetScript ("OnLeave", onLeaveScriptOptionButton)
                line:SetScript ("OnMouseUp", onMouseUpScriptOptionButton)

                line:SetBackdrop ({bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true, edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1})
                line:SetBackdropColor (unpack (scrollbox_line_backdrop_color))
                line:SetBackdropBorderColor (0, 0, 0, 0)
                
                local icon = line:CreateTexture("$parentIcon", "overlay")
                icon:SetSize (script_options_line_height - 2, script_options_line_height - 2)
                icon:SetTexture ([[Interface\ICONS\INV_Hand_1H_PirateHook_B_01]])
                icon:SetTexCoord (.1, .9, .1, .9)
                
                local optionNameLabel = DF:CreateLabel(line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_NAME"))
                local typeLabel = DF:CreateLabel (line, "", DF:GetTemplate ("font", "PLATER_SCRIPTS_TRIGGER_SPELLID"))
                
                local removeButton = CreateFrame("button", "$parentRemoveButton", line, "UIPanelCloseButton")
                removeButton:SetSize (16, 16)
                removeButton:SetScript ("OnClick", onMouseUpDeleteOptionButton)
                removeButton:SetPoint ("right", line, "right")
                removeButton:GetNormalTexture():SetDesaturated (true)
                removeButton:SetAlpha(0.7)

                local goButtonsIconSize = {12, 14}
                local goButtonsIconAlpha = 0.6412
                local goButtonsX = -3
                local duplicateX = -17

                local goUpButton = DF:CreateButton(line, onMouseUpGoUpOptionButton, 16, 16, "", -1, nil, nil, nil, nil, nil, {}, {})
                goUpButton:SetIcon ([[Interface\BUTTONS\Arrow-Up-Up]], goButtonsIconSize[1], goButtonsIconSize[2], "overlay")
                goUpButton:SetPoint ("topright", line, "topright", goButtonsX, 3)
                goUpButton:SetAlpha(goButtonsIconAlpha)
                --goUpButton.tooltip = "move this option up"

                local goDownButton = DF:CreateButton(line, onMouseUpGoDownOptionButton, 16, 16, "", -1, nil, nil, nil, nil, nil, {}, {})
                goDownButton:SetIcon ([[Interface\BUTTONS\Arrow-Down-Up]], goButtonsIconSize[1], goButtonsIconSize[2], "overlay")
                goDownButton:SetPoint ("topright", line, "topright", goButtonsX, -13)
                goDownButton:SetAlpha(goButtonsIconAlpha)
                --goDownButton.tooltip = "move this option down"

                local duplicateButton = DF:CreateButton(line, onMouseUpDuplicateOptionButton, 16, 16, "", -1, nil, nil, nil, nil, nil, {}, {})
                duplicateButton:SetIcon ([[Interface\AddOns\Plater\images\icons]], goButtonsIconSize[1], goButtonsIconSize[2], "overlay", {3/512, 21/512, 215/512, 233/512})
                duplicateButton:SetPoint ("right", line, "right", duplicateX, 0)
                duplicateButton:SetAlpha(goButtonsIconAlpha)
        
                icon:SetPoint ("left", line, "left", 2, 0)
                optionNameLabel:SetPoint ("topleft", icon, "topright", 4, -2)
                typeLabel:SetPoint ("topleft", optionNameLabel, "bottomleft", 0, 0)
                
                line.Icon = icon
                line.OptionNameLabel = optionNameLabel
                line.TypeLabel = typeLabel
                line.RemoveButton = removeButton
                line.GoUpButton = goUpButton
                line.GoDownButton = goDownButton
                line.DuplicateButton = duplicateButton

                line:Hide()
                
                return line
            end
            
            --scroll showing all options of the script
            local optionsLabel = DF:CreateLabel (adminFrame, "Options Created:", DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE"))
            local scriptOptionsScrollbox = DF:CreateScrollBox (adminFrame, "$parentScriptOptionsScrollBox", refreshScriptOptionsScrollBox, {} --[[empty values, to be filled when a script is selected]], script_options_scroll_size[1], script_options_scroll_size[2], script_options_scrollbox_lines, script_options_line_height)
            optionsLabel:SetPoint("topleft", createOptionDropdown, "bottomleft", 0, -5)
            scriptOptionsScrollbox:SetPoint ("topleft", optionsLabel.widget, "bottomleft", 0, -4)
            scriptOptionsScrollbox:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
            scriptOptionsScrollbox:SetBackdropColor (0, 0, 0, 0.2)
            scriptOptionsScrollbox:SetBackdropBorderColor (0, 0, 0, 1)
            mainFrame.ScriptOptionsScrollBox = scriptOptionsScrollbox -- hookFrame.ScriptOptionsScrollBox scriptFrame.ScriptOptionsScrollBox
            DF:ReskinSlider (scriptOptionsScrollbox)
            
            --create the hook scrollbox lines
            for i = 1, script_options_scrollbox_lines do
                scriptOptionsScrollbox:CreateLine(optionsListCreateLine)
            end
        
            --hold the frames for each type of option
            mainFrame.TypeFrames = {}

        --> shared options frame
            local sharedOptionsFrame = CreateFrame("frame", "$parentSharedOptions", adminFrame, BackdropTemplateMixin and "BackdropTemplate")
            sharedOptionsFrame:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
            sharedOptionsFrame:SetBackdropColor (0, 0, 0, 0.2)
            sharedOptionsFrame:SetBackdropBorderColor (0, 0, 0, 1)
            sharedOptionsFrame:SetPoint("topleft", scriptOptionsScrollbox, "topright", 30, 0)
            sharedOptionsFrame:SetSize(options_frame_width, options_frame_shared_height)
            adminFrame.SharedOptionsFrame = sharedOptionsFrame
            mainFrame.SharedOptionsFrame = sharedOptionsFrame

            --get a value from an option object
            local getOptionValue = function(key, default)
                local scriptObject = mainFrame.GetCurrentScriptObject()
                if (scriptObject) then
                    local scriptOptions = scriptObject.Options
                    local currentOption = scriptOptions[mainFrame.optionSelected]
                    return currentOption[key]
                else
                    return default
                end
            end

            local setOptionValue = function(key, value, default)
                local scriptObject = mainFrame.GetCurrentScriptObject()
                if (scriptObject) then
                    local scriptOptions = scriptObject.Options
                    local currentOption = scriptOptions[mainFrame.optionSelected]

                    if (value ~= nil) then
                        currentOption[key] = value
                    else
                        currentOption[key] = default
                    end
                end
            end

            --widgets
            local sharedOptionsMenu = {
                {type = "label", get = function() return "General Settings:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
                --name
                {
                    type = "textentry",
                    get = function() return getOptionValue("Name", "") end,
                    set = function (self, fixedparam, value) setOptionValue("Name", value, ""); mainFrame.ScriptOptionsScrollBox:Refresh() end,
                    name = "Name",
                    desc = "The name of this option.",
                    width = 200,
                },
                --key
                {
                    type = "textentry",
                    get = function() return getOptionValue("Key", "") end,
                    set = function (self, fixedparam, value) setOptionValue("Key", value, "") end,
                    name = "Key",
                    desc = "Key to be used inside the code to insert the value.",
                    width = 200,
                },
                --desc
                {
                    type = "textentry",
                    get = function() return getOptionValue("Desc", "") end,
                    set = function (self, fixedparam, value) setOptionValue("Desc", value, "") end,
                    name = "Description",
                    desc = "A short description of what this option controls.",
                    width = 300,
                },
            }

            DF:BuildMenuVolatile(sharedOptionsFrame, sharedOptionsMenu, 5, -5, options_frame_shared_height, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)

        --create subframes to hold panels with specific options for:
        -- ~options
        --option: color
            local colorOptionsFrame = CreateFrame("frame", "$parentColorOptions", adminFrame, BackdropTemplateMixin and "BackdropTemplate")
            colorOptionsFrame:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
            colorOptionsFrame:SetBackdropColor (0, 0, 0, 0.2)
            colorOptionsFrame:SetBackdropBorderColor (0, 0, 0, 1)
            colorOptionsFrame:SetPoint("topleft", sharedOptionsFrame, "bottomleft", 0, -5)
            colorOptionsFrame:SetSize(options_frame_width, options_frame_widget_options_height)
            mainFrame.TypeFrames[#mainFrame.TypeFrames+1] = colorOptionsFrame
            
            local colorOptionsMenu = {
                {type = "label", get = function() return "Settings for Color:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
                --value
                {
                    type = "color",
                    get = function() return getOptionValue("Value", {1, 1, 1, 1}) end,
                    set = function (self, r, g, b, a) setOptionValue("Value", {r, g, b, a}, {1, 1, 1, 1}) end,
                    name = "Color",
                    desc = "A Color",
                },
            }

            DF:BuildMenuVolatile(colorOptionsFrame, colorOptionsMenu, 5, -5, options_frame_shared_height, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)

        --option: number
            local numberOptionsFrame = CreateFrame("frame", "$parentNumberOptions", adminFrame, BackdropTemplateMixin and "BackdropTemplate")
            numberOptionsFrame:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
            numberOptionsFrame:SetBackdropColor (0, 0, 0, 0.2)
            numberOptionsFrame:SetBackdropBorderColor (0, 0, 0, 1)
            numberOptionsFrame:SetPoint("topleft", sharedOptionsFrame, "bottomleft", 0, -5)
            numberOptionsFrame:SetSize(options_frame_width, options_frame_widget_options_height)
            mainFrame.TypeFrames[#mainFrame.TypeFrames+1] = numberOptionsFrame

            local numberOptionsMenu = {
                {type = "label", get = function() return "Settings for Number:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
                --value
                {
                    type = "textentry",
                    get = function() return getOptionValue("Value", 0) end,
                    set = function (self, fixedparam, value) setOptionValue("Value", tonumber(value), 0) end,
                    name = "Default Value",
                    desc = "The initial value shown for the player when showing the options.",
                },
                --min value
                {
                    type = "textentry",
                    get = function() return getOptionValue("Min", 0) end,
                    set = function (self, fixedparam, value) setOptionValue("Min", tonumber(value), 0) end,
                    name = "Min Value",
                    desc = "The minimum value this option can go.",
                },
                --max value
                {
                    type = "textentry",
                    get = function() return getOptionValue("Max", 1) end,
                    set = function (self, fixedparam, value) setOptionValue("Max", tonumber(value), 0) end,
                    name = "Max Value",
                    desc = "The maximum value this option can go.",
                },
                --allow fraction
                {
                    type = "toggle",
                    get = function() return getOptionValue("Fraction", true) end,
                    set = function (self, fixedparam, value) setOptionValue("Fraction", value, true) end,
                    name = "Allow Fractions",
                    desc = "Allow fractions or only whole numbers if false.",
                },
            }

            DF:BuildMenuVolatile(numberOptionsFrame, numberOptionsMenu, 5, -5, options_frame_shared_height, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)

        --option: text
            local textOptionsFrame = CreateFrame("frame", "$parentTextOptions", adminFrame, BackdropTemplateMixin and "BackdropTemplate")
            textOptionsFrame:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
            textOptionsFrame:SetBackdropColor (0, 0, 0, 0.2)
            textOptionsFrame:SetBackdropBorderColor (0, 0, 0, 1)
            textOptionsFrame:SetPoint("topleft", sharedOptionsFrame, "bottomleft", 0, -5)
            textOptionsFrame:SetSize(options_frame_width, options_frame_widget_options_height)
            mainFrame.TypeFrames[#mainFrame.TypeFrames+1] = textOptionsFrame

            local textOptionsMenu = {
                {type = "label", get = function() return "Settings for Text:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
                --value
                {
                    type = "textentry",
                    get = function() return getOptionValue("Value", "") end,
                    set = function (self, fixedparam, value) setOptionValue("Value", value, "") end,
                    name = "Default Text",
                    desc = "Default text shown to the player.",
                },
            }

            DF:BuildMenuVolatile(textOptionsFrame, textOptionsMenu, 5, -5, options_frame_shared_height, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)

        --option: boolean
            local booleanOptionsFrame = CreateFrame("frame", "$parentBooleanOptions", adminFrame, BackdropTemplateMixin and "BackdropTemplate")
            booleanOptionsFrame:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
            booleanOptionsFrame:SetBackdropColor (0, 0, 0, 0.2)
            booleanOptionsFrame:SetBackdropBorderColor (0, 0, 0, 1)
            booleanOptionsFrame:SetPoint("topleft", sharedOptionsFrame, "bottomleft", 0, -5)
            booleanOptionsFrame:SetSize(options_frame_width, options_frame_widget_options_height)
            mainFrame.TypeFrames[#mainFrame.TypeFrames+1] = booleanOptionsFrame
            
            local boolOptionsMenu = {
                {type = "label", get = function() return "Settings for Boolean:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
                --value
                {
                    type = "toggle",
                    get = function() return getOptionValue("Value", true) end,
                    set = function (self, fixedparam, value) setOptionValue("Value", value, true) end,
                    name = "Default Toggle State",
                    desc = "If the toggle is default pressed or not.",
                },
            }

            DF:BuildMenuVolatile(booleanOptionsFrame, boolOptionsMenu, 5, -5, options_frame_shared_height, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)
        
        --option: label
            local labelOptionsFrame = CreateFrame("frame", "$parentLabelOptions", adminFrame, BackdropTemplateMixin and "BackdropTemplate")
            labelOptionsFrame:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
            labelOptionsFrame:SetBackdropColor (0, 0, 0, 0.2)
            labelOptionsFrame:SetBackdropBorderColor (0, 0, 0, 1)
            labelOptionsFrame:SetPoint("topleft", sharedOptionsFrame, "bottomleft", 0, -5)
            labelOptionsFrame:SetSize(options_frame_width, options_frame_widget_options_height)
            mainFrame.TypeFrames[#mainFrame.TypeFrames+1] = labelOptionsFrame

            local labelOptionsMenu = {
                {type = "label", get = function() return "Settings for Label:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
                --value
                {
                    type = "textentry",
                    get = function() return getOptionValue("Value", "") end,
                    set = function (self, fixedparam, value) setOptionValue("Value", value, "") end,
                    name = "Label Text",
                    desc = "Text shown as a header of a section.",
                    width = 330,
                },
            }

            DF:BuildMenuVolatile(labelOptionsFrame, labelOptionsMenu, 5, -5, options_frame_shared_height, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)

        --option: blank space
            local blackspaceOptionsFrame = CreateFrame("frame", "$parentBlankSpaceOptions", adminFrame, BackdropTemplateMixin and "BackdropTemplate")
            blackspaceOptionsFrame:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
            blackspaceOptionsFrame:SetBackdropColor (0, 0, 0, 0.2)
            blackspaceOptionsFrame:SetBackdropBorderColor (0, 0, 0, 1)
            blackspaceOptionsFrame:SetPoint("topleft", sharedOptionsFrame, "bottomleft", 0, -5)
            blackspaceOptionsFrame:SetSize(options_frame_width, options_frame_widget_options_height)
            mainFrame.TypeFrames[#mainFrame.TypeFrames+1] = blackspaceOptionsFrame

            local blankspaceOptionsMenu = {
                {type = "label", get = function() return "There's no settings for blank space" end, text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")},
            }

            DF:BuildMenuVolatile(blackspaceOptionsFrame, blankspaceOptionsMenu, 5, -5, options_frame_shared_height, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)

        --option: texture
            local textureOptionsFrame = CreateFrame("frame", "$parentTextureOptions", adminFrame, BackdropTemplateMixin and "BackdropTemplate")
            textureOptionsFrame:SetBackdrop ({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\Tooltips\UI-Tooltip-Background]], tileSize = 64, tile = true})
            textureOptionsFrame:SetBackdropColor (0, 0, 0, 0.2)
            textureOptionsFrame:SetBackdropBorderColor (0, 0, 0, 1)
            textureOptionsFrame:SetPoint("topleft", sharedOptionsFrame, "bottomleft", 0, -5)
            textureOptionsFrame:SetSize(options_frame_width, options_frame_widget_options_height)
            mainFrame.TypeFrames[#mainFrame.TypeFrames+1] = textureOptionsFrame
            
            local textureOptionsMenu = {
                {type = "label", get = function() return "Settings for Texture:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
                --value
                {type = "label", get = function() return "under construction:" end, text_template = DF:GetTemplate ("font", "ORANGE_FONT_TEMPLATE")},
            }
            DF:BuildMenuVolatile(textureOptionsFrame, textureOptionsMenu, 5, -5, options_frame_shared_height, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template)


        function Plater.RefreshUserScriptOptions(mainFrame)
            mainFrame.ImportTextEditor:Hide()
            mainFrame.CodeEditorLuaEntry:Hide()
            mainFrame.ScriptOptionsPanelAdmin:Hide()

            --show the user panel
            mainFrame.ScriptOptionsPanelUser:Show()

            --remove the selected border from the scripting buttons from scriptsFrame
            if (mainFrame.UpdateScriptsButton) then
                mainFrame.UpdateScriptsButton()
            end

            --global callback
            local globaCallBack = function()
                local scriptObject = mainFrame.GetCurrentScriptObject()
                if (scriptObject) then
                    Plater.RecompileScript(scriptObject)
                end
            end

            local scriptObject = mainFrame.GetCurrentScriptObject() --can be hook or script
            if (scriptObject) then
                if (scriptObject.Name ~= mainFrame.lastEditedScript) then
                    mainFrame.lastEditedScript = scriptObject.Name
                    mainFrame.optionSelected = 1
                end

                --clear the last hook edited so the hook list won't show a selected hook
                --check first if the key exists, this might be a script as well
                if (scriptObject.LastHookEdited) then
                    scriptObject.LastHookEdited = ""
                    mainFrame.HookScrollBox:Refresh()
                end

                --build the menu with options for the end user of the mod or script if it does not exist
                Plater.CreateOptionTableForScriptObject(scriptObject)

                local options = scriptObject.Options
                local thisOptionsValues = scriptObject.OptionsValues

                local menu = {}
                for i = 1, #options do
                    local thisOption = options[i]
                    local newOption = {
                        name = thisOption.Name,
                        desc = thisOption.Desc,
                        get = function()
                            return (thisOptionsValues[thisOption.Key] == nil and thisOption.Value) or thisOptionsValues[thisOption.Key]
                        end,
                        set = function (self, fixedparam, value)
                            thisOptionsValues[thisOption.Key] = value
                            --thisOption.Value = value
                        end,
                    }

                    -- ~useroptions
                    if (thisOption.Type == 1) then --color
                        newOption.type = "color"
                        newOption.set = function (self, r, g, b, a)
                            thisOptionsValues[thisOption.Key] = {r, g, b, a}
                            --thisOption.Value = {r, g, b, a}
                        end

                    elseif (thisOption.Type == 2) then --number
                        newOption.type = "range"
                        newOption.min = thisOption.Min
                        newOption.max = thisOption.Max
                        newOption.usedecimals = thisOption.Fraction
                        newOption.step = thisOption.Fraction and 0.01 or 1
                        newOption.thumbscale = 0.5
                        newOption.set = function (self, fixedparam, value)
                            thisOptionsValues[thisOption.Key] = thisOption.Fraction and value or math.floor(value)
                        end

                    elseif (thisOption.Type == 3) then --text
                        newOption.type = "textentry"
                        newOption.width = 300

                    elseif (thisOption.Type == 4) then --toggle
                        newOption.type = "toggle"

                    elseif (thisOption.Type == 5) then --label
                        newOption.type = "label"
                        newOption.text_template = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")

                        local text = thisOption.Value
                        text = text:gsub("@scriptname", scriptObject.Name)

                        newOption.get = function() return text end

                    elseif (thisOption.Type == 6) then --black space
                        newOption.type = "blank"

                    end

                    tinsert(menu, newOption)
                end

                DF:BuildMenuVolatile(mainFrame.ScriptOptionsPanelUser, menu, 5, -5, options_frame_widget_options_height + options_frame_shared_height, true, options_text_template, options_dropdown_template, options_switch_template, true, options_slider_template, options_button_template, globaCallBack)
            end
        end

        function Plater.RefreshAdminScriptOptions(mainFrame)
            mainFrame.ImportTextEditor:Hide()
            mainFrame.CodeEditorLuaEntry:Hide()
            mainFrame.ScriptOptionsPanelAdmin:Show()
            mainFrame.ScriptOptionsPanelUser:Hide()

            --remove the selected border from the scripting buttons from scriptsFrame
            if (mainFrame.UpdateScriptsButton) then
                mainFrame.UpdateScriptsButton()
            end

            local scriptObject = mainFrame.GetCurrentScriptObject() --can be hook or script
            if (scriptObject) then
                if (scriptObject.Name ~= mainFrame.lastEditedScript) then
                    mainFrame.lastEditedScript = scriptObject.Name
                    mainFrame.optionSelected = 1
                end

                --clear the last hook edited so the hook list won't show a selected hook
                --check first if the key exists, this might be a script as well
                if (scriptObject.LastHookEdited) then
                    scriptObject.LastHookEdited = ""
                    mainFrame.HookScrollBox:Refresh()
                end

                --does the table exists? old scripts does not have them
                local optionsTable = scriptObject.Options
                if (not optionsTable) then
                    optionsTable = {}
                    scriptObject.Options = optionsTable
                end

                mainFrame.ScriptOptionsScrollBox:SetData(scriptObject.Options)
                mainFrame.ScriptOptionsScrollBox:Refresh()

                --select the first option
                if (#optionsTable > 0) then
                    mainFrame.selectScriptOptionToEdit(1)
                    mainFrame.ScriptOptionsScrollBox:Show()
                else
                    for i = 1, #mainFrame.TypeFrames do
                        mainFrame.TypeFrames[i]:Hide()
                    end
                    mainFrame.SharedOptionsFrame:Hide()
                end
            else
                mainFrame.ScriptOptionsScrollBox:SetData({})
                mainFrame.ScriptOptionsScrollBox:Refresh()
                mainFrame.ScriptOptionsScrollBox:Hide()
            end
        end
end