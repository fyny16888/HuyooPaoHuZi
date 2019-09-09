local Common = require("common.Common")
local StaticData = require("app.static.StaticData")
local UserData = require("app.user.UserData")
local EventType = require("common.EventType")
local EventMgr = require("common.EventMgr")
local NetMgr = require("common.NetMgr")
local NetMsgId = require("common.NetMsgId")
local EventType = require("common.EventType")
local Bit = require("common.Bit")
local GameDesc = require("common.GameDesc")

local offset = 2

local RoomCreateLayer = class("RoomCreateLayer", cc.load("mvc").ViewBase)

function RoomCreateLayer:onEnter()
    EventMgr:registListener(EventType.SUB_CL_FRIENDROOM_CONFIG,self,self.SUB_CL_FRIENDROOM_CONFIG)
    EventMgr:registListener(EventType.SUB_CL_FRIENDROOM_CONFIG_END,self,self.SUB_CL_FRIENDROOM_CONFIG_END)
end

function RoomCreateLayer:onExit()
    EventMgr:unregistListener(EventType.SUB_CL_FRIENDROOM_CONFIG,self,self.SUB_CL_FRIENDROOM_CONFIG)
    EventMgr:unregistListener(EventType.SUB_CL_FRIENDROOM_CONFIG_END,self,self.SUB_CL_FRIENDROOM_CONFIG_END)
end

function RoomCreateLayer:onCleanup()

end

function RoomCreateLayer:onCreate(parameter)
    self.wKindID  = parameter[1]
    self.showType = parameter[2]
    self.dwClubID = parameter[3]
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local csb = cc.CSLoader:createNode("RoomCreateLayer48.csb")
    self:addChild(csb)
    self.root = csb:getChildByName("Panel_root")
    self.recordCreateParameter = UserData.Game:readCreateParameter(self.wKindID)
    if self.recordCreateParameter == nil then
        self.recordCreateParameter = {}
    end
    
    local uiListView_create = ccui.Helper:seekWidgetByName(self.root,"ListView_create")
    uiListView_create:setEnabled(false)
    local uiButton_create = ccui.Helper:seekWidgetByName(self.root,"Button_create")
    Common:addTouchEventListener(uiButton_create,function() self:onEventCreate(0) end)
    local uiButton_guild = ccui.Helper:seekWidgetByName(self.root,"Button_guild")
    Common:addTouchEventListener(uiButton_guild,function() self:onEventCreate(1) end)
    local uiButton_help = ccui.Helper:seekWidgetByName(self.root,"Button_help")
    Common:addTouchEventListener(uiButton_help,function() self:onEventCreate(-1) end)
    local uiButton_settings = ccui.Helper:seekWidgetByName(self.root,"Button_settings")
    Common:addTouchEventListener(uiButton_settings,function() self:onEventCreate(-2) end)
    if self.showType ~= nil and self.showType == 1 then
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)

    elseif self.showType ~= nil and self.showType == 3 then
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(0)

    elseif self.showType ~= nil and self.showType == 2 then
        uiListView_create:removeItem(0)
        uiListView_create:removeItem(1)
        uiListView_create:removeItem(1)
    else
        uiListView_create:removeItem(3)
        uiListView_create:removeItem(0)
        if StaticData.Hide[CHANNEL_ID].btn11 ~= 1 then 
            uiListView_create:removeItem(uiListView_create:getIndex(uiButton_help))
        end 
    end
    uiListView_create:refreshView()
    uiListView_create:setContentSize(cc.size(uiListView_create:getInnerContainerSize().width,uiListView_create:getInnerContainerSize().height))
    uiListView_create:setPositionX(uiListView_create:getParent():getContentSize().width/2)
    
    local uiListView_parameterList = ccui.Helper:seekWidgetByName(self.root,"ListView_parameterList")

    local isOpenDengFeng = function(isBool)
        local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(1),"ListView_parameter"):getItems()
        if isBool then
            for i,v in ipairs(items) do
                v:setBright(false)
                v:setTouchEnabled(true)
                v:setColor(cc.c3b(255,255,255))
                local uiText_desc = ccui.Helper:seekWidgetByName(v,"Text_desc")
                if uiText_desc then 
                    uiText_desc:setTextColor(cc.c3b(140,102,57))
                end  
            end
            if self.recordCreateParameter["bDeathCard"] == 1  then
                items[1]:setBright(true)
                local uiText_desc = ccui.Helper:seekWidgetByName(items[1],"Text_desc")
                if uiText_desc then 
                    uiText_desc:setTextColor(cc.c3b(238,105,40))
                end
            else
                items[2]:setBright(true)
                local uiText_desc = ccui.Helper:seekWidgetByName(items[2],"Text_desc")
                if uiText_desc then 
                    uiText_desc:setTextColor(cc.c3b(238,105,40))
                end
            end
        else
            for i,v in ipairs(items) do
                v:setBright(false)
                v:setTouchEnabled(false)
				local uiText_desc = ccui.Helper:seekWidgetByName(v, "Text_desc")
				if uiText_desc then
					uiText_desc:setTextColor(cc.c3b(140,102,57))
				end
				v:setColor(cc.c3b(170,170,170))
            end
        end
    end
    --人数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(0),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,false,function(index)
        if index == 1 then
            self.recordCreateParameter["bPlayerCount"] = 2
            isOpenDengFeng(true)
        else
            self.recordCreateParameter["bPlayerCount"] = 3
            isOpenDengFeng(false)
        end
    end)
    
    --抽牌
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(1),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,false,function(index)
        if index == 1 then
            self.recordCreateParameter["bDeathCard"] = 1
        else
            self.recordCreateParameter["bDeathCard"] = 0
        end
    end)    

    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(0),"ListView_parameter"):getItems()
    self.recordCreateParameter["bPlayerCount"] = self.recordCreateParameter["bPlayerCount"] or 3
    if self.recordCreateParameter["bPlayerCount"] == 3  then
        items[2]:setBright(true)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[2],"Text_desc")
        if uiText_desc then
            uiText_desc:setTextColor(cc.c3b(238,105,40))
        end
        isOpenDengFeng(false)
    else
        items[1]:setBright(true)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[1],"Text_desc")
        if uiText_desc then 
            uiText_desc:setTextColor(cc.c3b(238,105,40))
        end
        isOpenDengFeng(true)
    end

    --选择玩法
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 0),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,true)
    if self.recordCreateParameter["dwMingTang"] and Bit:_and(0x04,self.recordCreateParameter["dwMingTang"]) ~= 0 then
        items[1]:setBright(true)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[1],"Text_desc")
        if uiText_desc ~= nil then 
            uiText_desc:setTextColor(cc.c3b(238,105,40))
        end
    end
    if self.recordCreateParameter["dwMingTang"] and Bit:_and(0x08,self.recordCreateParameter["dwMingTang"]) ~= 0 then
        items[2]:setBright(true)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[2],"Text_desc")
        if uiText_desc ~= nil then 
            uiText_desc:setTextColor(cc.c3b(238,105,40))
        end
    end
    if self.recordCreateParameter["bDelShuaHou"] == nil or self.recordCreateParameter["bDelShuaHou"] ~= 1 then --耍猴  0  1
        items[3]:setBright(true)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[3],"Text_desc")
        if uiText_desc ~= nil then 
            uiText_desc:setTextColor(cc.c3b(238,105,40))
        end
    end

    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 1),"ListView_parameter"):getItems() 
    Common:addCheckTouchEventListener(items,true)
    if self.recordCreateParameter["bTingHuAll"] == nil or self.recordCreateParameter["bTingHuAll"] ~= 2 then --听胡 0 1
        items[1]:setBright(true)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[1],"Text_desc")
        if uiText_desc ~= nil then 
            uiText_desc:setTextColor(cc.c3b(238,105,40))
        end
    end
    if self.recordCreateParameter["bHuangFanAddUp"] == nil or self.recordCreateParameter["bHuangFanAddUp"] ~= 2 then --黄番 2 
        items[2]:setBright(true)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[2],"Text_desc")
        if uiText_desc ~= nil then 
            uiText_desc:setTextColor(cc.c3b(238,105,40))
        end
    end
    if self.recordCreateParameter["dwMingTang"] and Bit:_and(0x8000,self.recordCreateParameter["dwMingTang"]) ~= 0 then --假行行
        items[3]:setBright(true)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[3],"Text_desc")
        if uiText_desc ~= nil then 
            uiText_desc:setTextColor(cc.c3b(238,105,40))
        end
    end

    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 2),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,true)
    if self.recordCreateParameter["bSiQiHong"] and self.recordCreateParameter["bSiQiHong"] == 1 then      --四七红
        items[1]:setBright(true)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[1],"Text_desc")
        if uiText_desc ~= nil then 
            uiText_desc:setTextColor(cc.c3b(238,105,40))
        end
    end

    --选择底分
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 3),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,false,function(index)
        if index == 1 or index == 2 or index == 3 then 
            local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 4),"ListView_parameter"):getItems()
            items[1]:setBright(false)
            local uiText_desc = ccui.Helper:seekWidgetByName(items[1],"Text_desc")
            if uiText_desc ~= nil then 
                uiText_desc:setTextColor(cc.c3b(140,102,57))
            end  
            items[2]:setBright(false)
            local uiText_desc = ccui.Helper:seekWidgetByName(items[2],"Text_desc")
            if uiText_desc ~= nil then 
                uiText_desc:setTextColor(cc.c3b(140,102,57))
            end
        end
    end)
    if self.recordCreateParameter["bStartTun"] ~= nil and self.recordCreateParameter["bStartTun"] == 1 then
        items[2]:setBright(true)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[2],"Text_desc")
        if uiText_desc ~= nil then 
            uiText_desc:setTextColor(cc.c3b(238,105,40))
        end
    elseif self.recordCreateParameter["bStartTun"] ~= nil and self.recordCreateParameter["bStartTun"] == 2 then
        items[3]:setBright(true)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[3],"Text_desc")
        if uiText_desc ~= nil then 
            uiText_desc:setTextColor(cc.c3b(238,105,40))
        end
    elseif self.recordCreateParameter["bStartTun"] ~= nil and self.recordCreateParameter["bStartTun"] == 3 then
    elseif self.recordCreateParameter["bStartTun"] ~= nil and self.recordCreateParameter["bStartTun"] == 4 then
    else
        items[1]:setBright(true)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[1],"Text_desc")
        if uiText_desc ~= nil then 
            uiText_desc:setTextColor(cc.c3b(238,105,40))
        end
    end
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 4),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,false,function(index)
        if index == 1 or index == 2  then 
            local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 3),"ListView_parameter"):getItems()
            items[1]:setBright(false)
            local uiText_desc = ccui.Helper:seekWidgetByName(items[1],"Text_desc")
            if uiText_desc ~= nil then 
                uiText_desc:setTextColor(cc.c3b(140,102,57))
            end  
            items[2]:setBright(false)
            local uiText_desc = ccui.Helper:seekWidgetByName(items[2],"Text_desc")
            if uiText_desc ~= nil then 
                uiText_desc:setTextColor(cc.c3b(140,102,57))
            end
            items[3]:setBright(false)
            local uiText_desc = ccui.Helper:seekWidgetByName(items[3],"Text_desc")
            if uiText_desc ~= nil then 
                uiText_desc:setTextColor(cc.c3b(140,102,57))
            end
        end
    end)    
    if self.recordCreateParameter["bStartTun"] ~= nil and self.recordCreateParameter["bStartTun"] == 4 then
        items[2]:setBright(true)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[2],"Text_desc")
        if uiText_desc ~= nil then 
            uiText_desc:setTextColor(cc.c3b(238,105,40))
        end
     elseif self.recordCreateParameter["bStartTun"] ~= nil and self.recordCreateParameter["bStartTun"] == 3 then
        items[1]:setBright(true)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[1],"Text_desc")
        if uiText_desc ~= nil then 
            uiText_desc:setTextColor(cc.c3b(238,105,40))
        end
    end

    --选择局数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 5),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items, false, function(index)
		if index == 1 or index == 2 or index == 3 then
			local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 6), "ListView_parameter"):getItems()
			items[1]:setBright(false)
			local uiText_desc = ccui.Helper:seekWidgetByName(items[1], "Text_desc")
			if uiText_desc ~= nil then
				uiText_desc:setTextColor(cc.c3b(140,102,57))
            end

            local uiText_addition = ccui.Helper:seekWidgetByName(items[1],"Text_addition")
            if uiText_addition ~= nil then 
                uiText_addition:setTextColor(cc.c3b(140,102,57))
            end
		end
	end)

    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 6),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items, false, function(index)
		if index == 1 then
			local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 5), "ListView_parameter"):getItems()
            for key, var in pairs(items) do 
                var:setBright(false)
                local uiText_desc = ccui.Helper:seekWidgetByName(var, "Text_desc")
                if uiText_desc ~= nil then
                    uiText_desc:setTextColor(cc.c3b(140,102,57))
                end
                local uiText_addition = ccui.Helper:seekWidgetByName(var,"Text_addition")
                if uiText_addition ~= nil then 
                    uiText_addition:setTextColor(cc.c3b(140,102,57))
                end
            end 
		end
	end)

    --封顶
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 7),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,false,function(index)
        if index == 1 or index == 2 or index == 3  then 
            local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 8),"ListView_parameter"):getItems()
            items[1]:setBright(false)
            local uiText_desc = ccui.Helper:seekWidgetByName(items[1],"Text_desc")
            if uiText_desc ~= nil then 
                uiText_desc:setTextColor(cc.c3b(140,102,57))
            end  
        end
    end)    
    if self.recordCreateParameter["bMaxLost"] ~= nil and self.recordCreateParameter["bMaxLost"] == 100 then
        items[1]:setBright(true)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[1],"Text_desc")
        if uiText_desc ~= nil then 
            uiText_desc:setTextColor(cc.c3b(238,105,40))
        end
    elseif self.recordCreateParameter["bMaxLost"] ~= nil and self.recordCreateParameter["bMaxLost"] == 200 then
        items[2]:setBright(true)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[2],"Text_desc")
        if uiText_desc ~= nil then 
            uiText_desc:setTextColor(cc.c3b(238,105,40))
        end
    elseif self.recordCreateParameter["bMaxLost"] ~= nil and self.recordCreateParameter["bMaxLost"] == 300 then
        items[3]:setBright(true)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[3],"Text_desc")
        if uiText_desc ~= nil then 
            uiText_desc:setTextColor(cc.c3b(238,105,40))
        end
    end
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 8),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,false,function(index)
        if index == 1 or index == 2  then 
            local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 7),"ListView_parameter"):getItems()
            items[1]:setBright(false)
            local uiText_desc = ccui.Helper:seekWidgetByName(items[1],"Text_desc")
            if uiText_desc ~= nil then 
                uiText_desc:setTextColor(cc.c3b(140,102,57))
            end  
            items[2]:setBright(false)
            local uiText_desc = ccui.Helper:seekWidgetByName(items[2],"Text_desc")
            if uiText_desc ~= nil then 
                uiText_desc:setTextColor(cc.c3b(140,102,57))
            end
            items[3]:setBright(false)
            local uiText_desc = ccui.Helper:seekWidgetByName(items[3],"Text_desc")
            if uiText_desc ~= nil then 
                uiText_desc:setTextColor(cc.c3b(140,102,57))
            end
        end
    end)   
    if self.recordCreateParameter["bMaxLost"] ~= nil and self.recordCreateParameter["bMaxLost"] == 100 then
    elseif self.recordCreateParameter["bMaxLost"] ~= nil and self.recordCreateParameter["bMaxLost"] == 200 then
    elseif self.recordCreateParameter["bMaxLost"] ~= nil and self.recordCreateParameter["bMaxLost"] == 300 then
    else       
        items[1]:setBright(true)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[1],"Text_desc")
        if uiText_desc ~= nil then 
            uiText_desc:setTextColor(cc.c3b(238,105,40))
        end
    end

    --随机庄
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 9),"ListView_parameter"):getItems()
    Common:addCheckTouchEventListener(items,true)
    if self.recordCreateParameter["bStartBanker"] ~= nil and self.recordCreateParameter["bStartBanker"] == 1 then
        items[1]:setBright(false)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[1],"Text_desc")
        if uiText_desc ~= nil then 
            uiText_desc:setTextColor(cc.c3b(140,102,57))
        end
    else
        items[1]:setBright(true)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[1],"Text_desc")
        if uiText_desc ~= nil then 
            uiText_desc:setTextColor(cc.c3b(238,105,40))
        end
    end


    if self.showType == 3 then
        self.tableFriendsRoomParams = {[1] = {wGameCount = 1}}
        self:SUB_CL_FRIENDROOM_CONFIG_END()
    else
        UserData.Game:sendMsgGetFriendsRoomParam(self.wKindID)
    end
end

function RoomCreateLayer:SUB_CL_FRIENDROOM_CONFIG(event)
    local data = event._usedata
    if data.wKindID ~= self.wKindID then
        return
    end
    if self.tableFriendsRoomParams == nil then
        self.tableFriendsRoomParams = {}
    end
    self.tableFriendsRoomParams[data.dwIndexes] = data
end

function RoomCreateLayer:SUB_CL_FRIENDROOM_CONFIG_END(event)
    if self.tableFriendsRoomParams == nil then
        return
    end
    local uiListView_create = ccui.Helper:seekWidgetByName(self.root,"ListView_create")
    uiListView_create:setEnabled(true)
    local uiListView_parameterList = ccui.Helper:seekWidgetByName(self.root,"ListView_parameterList")
    local uiListView_parameter = uiListView_parameterList:getItem(offset + 5)
    uiListView_parameter:setVisible(true)
    local items = ccui.Helper:seekWidgetByName(uiListView_parameter,"ListView_parameter"):getItems()
    local isFound = false
    for key, var in pairs(items) do
        local data = self.tableFriendsRoomParams[key]
    	if data then
            local uiText_desc = ccui.Helper:seekWidgetByName(var,"Text_desc")
            uiText_desc:setString(string.format("%d局",data.wGameCount))
            local uiText_addition = ccui.Helper:seekWidgetByName(var,"Text_addition")
            if data.dwExpendType == 1 then
                uiText_addition:setString(string.format("金币x%d",data.dwExpendCount))
            elseif data.dwExpendType == 2 then
                uiText_addition:setString(string.format("元宝x%d",data.dwExpendCount))
            elseif data.dwExpendType == 3 then
                uiText_addition:setString(string.format("(%sx%d)",StaticData.Items[data.dwSubType].name,data.dwExpendCount))   
            else
                uiText_addition:setString("(无消耗)")
            end
            if isFound == false and self.recordCreateParameter["wGameCount"] ~= nil and self.recordCreateParameter["wGameCount"] == data.wGameCount then
                var:setBright(true)
                isFound = true
                local uiText_desc = ccui.Helper:seekWidgetByName(var,"Text_desc")
                if uiText_desc ~= nil then 
                    uiText_desc:setTextColor(cc.c3b(238,105,40))
                end
                if uiText_addition ~= nil then 
                    uiText_addition:setTextColor(cc.c3b(238,105,40))
                end
            else
                uiText_desc:setTextColor(cc.c3b(140,102,57))
                uiText_addition:setTextColor(cc.c3b(140,102,57))
            end
    	else
    	   var:setBright(false)
           var:setVisible(false)
           local uiText_desc = ccui.Helper:seekWidgetByName(var,"Text_desc")
           if uiText_desc ~= nil then 
               uiText_desc:setTextColor(cc.c3b(140,102,57))
           end
           local uiText_addition = ccui.Helper:seekWidgetByName(var,"Text_addition")
           if uiText_addition ~= nil then 
            uiText_addition:setTextColor(cc.c3b(140,102,57))
           end
    	end
    end
    if isFound == false and items[1]:isVisible() and self.recordCreateParameter["wGameCount"] == nil then
        items[1]:setBright(true)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[1],"Text_desc")
        if uiText_desc ~= nil then 
            uiText_desc:setTextColor(cc.c3b(238,105,40))
        end
        local uiText_addition = ccui.Helper:seekWidgetByName(items[1],"Text_addition")
        if uiText_addition ~= nil then 
         uiText_addition:setTextColor(cc.c3b(238,105,40))
        end
    end

    local uiListView_parameter = uiListView_parameterList:getItem(offset + 6)
    uiListView_parameter:setVisible(true)
    local items = ccui.Helper:seekWidgetByName(uiListView_parameter,"ListView_parameter"):getItems()
    local isFound = false
    local data = self.tableFriendsRoomParams[4]
    if data then
        local uiText_desc = ccui.Helper:seekWidgetByName(items[1],"Text_desc")
        uiText_desc:setString(string.format("%d局",data.wGameCount))
        local uiText_addition = ccui.Helper:seekWidgetByName(items[1],"Text_addition")
        if data.dwExpendType == 1 then
            uiText_addition:setString(string.format("金币x%d",data.dwExpendCount))
        elseif data.dwExpendType == 2 then
            uiText_addition:setString(string.format("元宝x%d",data.dwExpendCount))
        elseif data.dwExpendType == 3 then
            uiText_addition:setString(string.format("(%sx%d)",StaticData.Items[data.dwSubType].name,data.dwExpendCount))   
        else
            uiText_addition:setString("(无消耗)")
        end
        if isFound == false and self.recordCreateParameter["wGameCount"] ~= nil and self.recordCreateParameter["wGameCount"] == data.wGameCount then
            items[1]:setBright(true)
            isFound = true
            local uiText_desc = ccui.Helper:seekWidgetByName(items[1],"Text_desc")
            if uiText_desc ~= nil then 
                uiText_desc:setTextColor(cc.c3b(238,105,40))
            end
            if uiText_addition ~= nil then 
                uiText_addition:setTextColor(cc.c3b(238,105,40))
            end
        else
            uiText_desc:setTextColor(cc.c3b(140,102,57))
            uiText_addition:setTextColor(cc.c3b(140,102,57))
        end
    else
        items[1]:setBright(false)
        items[1]:setVisible(false)
        local uiText_desc = ccui.Helper:seekWidgetByName(items[1],"Text_desc")
        if uiText_desc ~= nil then 
            uiText_desc:setTextColor(cc.c3b(140,102,57))
        end
        local uiText_addition = ccui.Helper:seekWidgetByName(items[1],"Text_addition")
        if uiText_addition ~= nil then 
        uiText_addition:setTextColor(cc.c3b(140,102,57))
        end
    end
end

function RoomCreateLayer:onEventCreate(nTableType)
    NetMgr:getGameInstance():closeConnect()
    local uiListView_parameterList = ccui.Helper:seekWidgetByName(self.root,"ListView_parameterList")
    local tableParameter = {}
    --人数
    tableParameter.bPlayerCount = self.recordCreateParameter["bPlayerCount"] or 3

    --抽牌
    tableParameter.bDeathCard = self.recordCreateParameter["bDeathCard"] or 0

    --选择玩法
    tableParameter.dwMingTang = 0xFFFF
    tableParameter.dwMingTang = Bit:_xor(tableParameter.dwMingTang,0x02)   --闷一底
    tableParameter.dwMingTang = Bit:_xor(tableParameter.dwMingTang,0x04)   --团圆
    tableParameter.dwMingTang = Bit:_xor(tableParameter.dwMingTang,0x08)   --真
    tableParameter.dwMingTang = Bit:_xor(tableParameter.dwMingTang,0x10)   --假
    tableParameter.dwMingTang = Bit:_xor(tableParameter.dwMingTang,0x8000)   --假行行
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 0),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.dwMingTang = Bit:_or(tableParameter.dwMingTang,0x04)
    end
    if items[2]:isBright() then
        tableParameter.dwMingTang = Bit:_or(tableParameter.dwMingTang,0x08)
    end
    if items[3]:isBright() then--耍猴
        tableParameter.bDelShuaHou = 0
    else
        tableParameter.bDelShuaHou = 1
    end
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 1),"ListView_parameter"):getItems()   
    if items[1]:isBright() then    --听胡
        tableParameter.bTingHuAll = 1
    else
        tableParameter.bTingHuAll = 2
    end
    if items[2]:isBright() then   --黄番2倍
        tableParameter.bHuangFanAddUp = 1
    else
        tableParameter.bHuangFanAddUp = 2
    end
    if items[3]:isBright() then   --假行
        tableParameter.dwMingTang = Bit:_or(tableParameter.dwMingTang,0x8000)
    end
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 2),"ListView_parameter"):getItems()   
    if items[1]:isBright() then   --四七红
        tableParameter.bSiQiHong = 1
    else
        tableParameter.bSiQiHong = 0
    end

    --选择加底
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 3),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bStartTun = 0
    elseif items[2]:isBright() then
        tableParameter.bStartTun = 1
    elseif items[3]:isBright() then
        tableParameter.bStartTun = 2
    end
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 4),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bStartTun = 3
    elseif items[2]:isBright() then
        tableParameter.bStartTun = 4
    end

    --选择局数
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 5),"ListView_parameter"):getItems()
    if items[1]:isBright() and self.tableFriendsRoomParams[1] then
        tableParameter.wGameCount = self.tableFriendsRoomParams[1].wGameCount
    elseif items[2]:isBright() and self.tableFriendsRoomParams[2] then
        tableParameter.wGameCount = self.tableFriendsRoomParams[2].wGameCount
    elseif items[3]:isBright() and self.tableFriendsRoomParams[3] then
        tableParameter.wGameCount = self.tableFriendsRoomParams[3].wGameCount
    end
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 6),"ListView_parameter"):getItems()
    if items[1]:isBright() and self.tableFriendsRoomParams[4] then
        tableParameter.wGameCount = self.tableFriendsRoomParams[4].wGameCount
    end
    --选择人数
    -- tableParameter.bPlayerCount = 3
    tableParameter.bPlayerCountType = 0
    --起胡胡息 
    tableParameter.bCanHuXi = 15
    
    --封顶
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 7),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bMaxLost = 100
    elseif items[2]:isBright() then
        tableParameter.bMaxLost = 200
    elseif items[3]:isBright() then
        tableParameter.bMaxLost = 300
    end
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 8),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bMaxLost = 0
    end

    --随机庄家
    local items = ccui.Helper:seekWidgetByName(uiListView_parameterList:getItem(offset + 9),"ListView_parameter"):getItems()
    if items[1]:isBright() then
        tableParameter.bStartBanker = 0
    else 
        tableParameter.bStartBanker = 1
    end

    tableParameter.bTurn = 0
    tableParameter.bPaoTips = 0    
    tableParameter.FanXing = {}
    tableParameter.FanXing.bType = 0
    tableParameter.FanXing.bCount = 0
    tableParameter.FanXing.bAddTun = 0
    tableParameter.bLaiZiCount = 0
    tableParameter.bYiWuShi = 0
    tableParameter.bLiangPai = 0
    tableParameter.bHuType = 0
    tableParameter.bFangPao = 0
    tableParameter.bSettlement = 0
    tableParameter.bSocreType = 1
    
   if self.showType ~= 2 and (nTableType == TableType_FriendRoom or nTableType == TableType_HelpRoom) then
        --普通创房和代开需要判断金币
        local uiListView_parameterList = ccui.Helper:seekWidgetByName(self.root,"ListView_parameterList")
        local uiListView_parameter = uiListView_parameterList:getItem(offset + 5)
        local items = ccui.Helper:seekWidgetByName(uiListView_parameter,"ListView_parameter"):getItems()
        for key, var in pairs(items) do
            if var:isBright() then
                local data = self.tableFriendsRoomParams[key]
                if data.dwExpendType == 0 then--无消耗
                elseif data.dwExpendType == 1 then--金币
                    if UserData.User.dwGold  < data.dwExpendCount then
                        if  StaticData.Hide[CHANNEL_ID].btn8 == 1 and StaticData.Hide[CHANNEL_ID].btn9 == 1  then
                            require("common.MsgBoxLayer"):create(1,nil,"您的金币不足,请前往商城充值？",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(2):createView("NewMallLayer")) end)
                        else
                            require("common.MsgBoxLayer"):create(1,nil,"您的金币不足，请联系代理购买！",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("GuilLayer"))  end)
                        end
                        return
                end  
                elseif data.dwExpendType == 2 then--元宝
                    if UserData.User.dwIngot  < data.dwExpendCount then
                        if  StaticData.Hide[CHANNEL_ID].btn8 == 1 and StaticData.Hide[CHANNEL_ID].btn9 == 1  then
                            require("common.MsgBoxLayer"):create(1,nil,"您的元宝不足,请前往商城购买？",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(2):createView("NewMallLayer")) end)
                        else
                            require("common.MsgBoxLayer"):create(1,nil,"您的元宝不足，请联系代理购买！",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("GuilLayer"))  end)
                        end
                        return
                end 
                elseif data.dwExpendType == 3 then--道具
                    local itemCount = UserData.Bag:getBagPropCount(data.dwSubType)
                    if itemCount < data.dwExpendCount then
                        if  StaticData.Hide[CHANNEL_ID].btn8 == 1 and StaticData.Hide[CHANNEL_ID].btn9 == 1  then
                            require("common.MsgBoxLayer"):create(1,nil,"您的道具不足,请前往商城购买?",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(2):createView("NewMallLayer")) end)
                        else
                            require("common.MsgBoxLayer"):create(0,nil,"您的道具不足!")
                        end
                        return
                    end
                else
                    return
                end
                break
            end

            local uiListView_parameter = uiListView_parameterList:getItem(offset + 6)
            local items = ccui.Helper:seekWidgetByName(uiListView_parameter,"ListView_parameter"):getItems()
            if items[1]:isBright() then
                local data = self.tableFriendsRoomParams[4]
                if data.dwExpendType == 0 then--无消耗
                elseif data.dwExpendType == 1 then--金币
                    if UserData.User.dwGold  < data.dwExpendCount then
                        if  StaticData.Hide[CHANNEL_ID].btn8 == 1 and StaticData.Hide[CHANNEL_ID].btn9 == 1  then
                            require("common.MsgBoxLayer"):create(1,nil,"您的金币不足,请前往商城充值？",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(2):createView("NewMallLayer")) end)
                        else
                            require("common.MsgBoxLayer"):create(1,nil,"您的金币不足，请联系代理购买！",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("GuilLayer"))  end)
                        end
                        return
                end  
                elseif data.dwExpendType == 2 then--元宝
                    if UserData.User.dwIngot  < data.dwExpendCount then
                        if  StaticData.Hide[CHANNEL_ID].btn8 == 1 and StaticData.Hide[CHANNEL_ID].btn9 == 1  then
                            require("common.MsgBoxLayer"):create(1,nil,"您的元宝不足,请前往商城购买？",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(2):createView("NewMallLayer")) end)
                        else
                            require("common.MsgBoxLayer"):create(1,nil,"您的元宝不足，请联系代理购买！",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create():createView("GuilLayer"))  end)
                        end
                        return
                end 
                elseif data.dwExpendType == 3 then--道具
                    local itemCount = UserData.Bag:getBagPropCount(data.dwSubType)
                    if itemCount < data.dwExpendCount then
                        if  StaticData.Hide[CHANNEL_ID].btn8 == 1 and StaticData.Hide[CHANNEL_ID].btn9 == 1  then
                            require("common.MsgBoxLayer"):create(1,nil,"您的道具不足,请前往商城购买?",function() require("common.SceneMgr"):switchOperation(require("app.MyApp"):create(2):createView("NewMallLayer")) end)
                        else
                            require("common.MsgBoxLayer"):create(0,nil,"您的道具不足!")
                        end
                        return
                    end
                else
                    return
                end
            end
        end
    end

    UserData.Game:saveCreateParameter(self.wKindID,tableParameter)

    --亲友圈自定义创房
    if self.showType == 2 then
        local uiButton_create = ccui.Helper:seekWidgetByName(self.root,"Button_create")
        uiButton_create:removeAllChildren()
        uiButton_create:addChild(require("app.MyApp"):create(TableType_ClubRoom,1,self.wKindID,tableParameter.wGameCount,self.dwClubID,tableParameter):createView("InterfaceCreateRoomNode"))
        return
    end 
    --设置亲友圈   
    if nTableType == TableType_ClubRoom then
        EventMgr:dispatch(EventType.EVENT_TYPE_SETTINGS_CLUB_PARAMETER,{wKindID = self.wKindID,wGameCount = tableParameter.wGameCount,tableParameter = tableParameter})      
        return
    end

    local uiButton_create = ccui.Helper:seekWidgetByName(self.root,"Button_create")
    uiButton_create:removeAllChildren()
    uiButton_create:addChild(require("app.MyApp"):create(nTableType,0,self.wKindID,tableParameter.wGameCount,UserData.Guild.dwPresidentID,tableParameter):createView("InterfaceCreateRoomNode"))

end

return RoomCreateLayer

