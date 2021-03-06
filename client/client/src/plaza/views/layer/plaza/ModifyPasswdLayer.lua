--
-- Author: zhong
-- Date: 2016-08-02 15:57:41
--

--密码修改界面

local ModifyPasswdLayer = class("ModifyPasswdLayer", cc.Layer)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local ModifyFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.ModifyFrame")

--按钮
local BT_EXIT = 101
local BT_SURE = 102
local BT_CANCEL = 103
--复选框
local CBT_LOGIN = 201
local CBT_BANK = 202

local strWeChatNotPassword = "微信登录不需要登录密码"
local strVisitorNotPassword = "游客登录不需要登录密码"

function ModifyPasswdLayer:onTouchBegan (touch, event)
    return true
end

function ModifyPasswdLayer:ctor( scene )
    ExternalFun.registerTouchEvent (self, true)
    self._scene = scene

	--加载csb资源
	local rootLayer, csbNode = ExternalFun.loadRootCSB("modify/ModifyPassLayer.csb", self)
	self.m_csbNode = csbNode

	--旧密码图片
	self.m_spOldPass = csbNode:getChildByName("sp_pass_old")
	--新密码图片
	self.m_spNewPass = csbNode:getChildByName("sp_pass_new")
	
	local function btncallback(ref, type)
        if type == ccui.TouchEventType.ended then
         	self:onButtonClickedEvent(ref:getTag(),ref)
        end
    end     
    --返回按钮
    local btn = csbNode:getChildByName("back_btn")
    btn:setTag(BT_EXIT)
    btn:addTouchEventListener(btncallback)
    --确定按钮
    btn = csbNode:getChildByName("sure_btn")
    btn:setTag(BT_SURE)
    btn:addTouchEventListener(btncallback)
    --取消按钮
    btn = csbNode:getChildByName("cancel_btn")
    btn:setTag(BT_CANCEL)
    btn:addTouchEventListener(btncallback)

    local function checkEvent( sender,eventType )
		self:onCheckBoxClickEvent(sender, eventType);
	end
	--修改登录密码复选框
	self.m_checkLogin = csbNode:getChildByName("login_check")
	self.m_checkLogin:setTag(CBT_LOGIN)
	self.m_checkLogin:addEventListener(checkEvent)
	self.m_checkLogin:setSelected(true)
	--修改银行密码复选框
	self.m_checkBank = csbNode:getChildByName("bank_check")
	self.m_checkBank:setTag(CBT_BANK)
	self.m_checkBank:addEventListener(checkEvent)
	self.m_checkBank:setSelected(false)
	--当前选择的box
	self.m_nSelectBox = CBT_LOGIN



	local  strOldPass = "请输入您的旧登录密码"
	local  strNewPass = "请输入您的新登录密码"
	local  strConfirmPass = "请再次输入您的新登录密码"

	if GlobalUserItem.bWeChat == true then	  --微信
		strOldPass = strWeChatNotPassword
		strNewPass = strWeChatNotPassword
		strConfirmPass = strWeChatNotPassword
	elseif GlobalUserItem.bVistor == true then  --游客
		strOldPass = strVisitorNotPassword
		strNewPass = strVisitorNotPassword
		strConfirmPass = strVisitorNotPassword
	end



	--旧密码编辑
	local tmp = csbNode:getChildByName("sp_edit_old")
	local editbox = ccui.EditBox:create(cc.size(tmp:getContentSize().width - 10, tmp:getContentSize().height - 10),"blank.png",UI_TEX_TYPE_PLIST)
		:setPosition(tmp:getPosition())
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(30)
		:setPlaceholderFontSize(30)
		:setMaxLength(26)
        :setPlaceholderFontColor(cc.c3b(127,113,217))
    	:setFontColor(cc.c3b(229,225,255))
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder(strOldPass)
	csbNode:addChild(editbox)
	self.m_editOldPass = editbox
	
	--新密码编辑
	tmp = csbNode:getChildByName("sp_edit_new")
	editbox = ccui.EditBox:create(cc.size(tmp:getContentSize().width - 10, tmp:getContentSize().height - 10),"blank.png",UI_TEX_TYPE_PLIST)
		:setPosition(tmp:getPosition())
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(30)
		:setPlaceholderFontSize(30)
		:setMaxLength(26)
            :setPlaceholderFontColor(cc.c3b(127,113,217))
    :setFontColor(cc.c3b(229,225,255))
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder(strNewPass)
	csbNode:addChild(editbox)
	self.m_editNewPass = editbox
	
	--确认密码编辑
	tmp = csbNode:getChildByName("sp_edit_confirm")
	editbox = ccui.EditBox:create(cc.size(tmp:getContentSize().width - 10, tmp:getContentSize().height - 10),"blank.png",UI_TEX_TYPE_PLIST)
		:setPosition(tmp:getPosition())
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setFontSize(30)
		:setPlaceholderFontSize(30)
		:setMaxLength(26)
            :setPlaceholderFontColor(cc.c3b(127,113,217))
    :setFontColor(cc.c3b(229,225,255))
		:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
		:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setPlaceHolder(strConfirmPass)
	csbNode:addChild(editbox)
	self.m_editConfirmPass = editbox
	
	--游客和微信在默认的登录密码修改界面，禁用3个输入框
	if GlobalUserItem.bVistor == true or GlobalUserItem.bWeChat == true then
		self:setEditBoxsEnabled(CBT_LOGIN)
	end


	--网络回调
    local modifyCallBack = function(result,message)
		self:onModifyCallBack(result,message)
	end
    --网络处理
	self._modifyFrame = ModifyFrame:create(self,modifyCallBack)
end

function ModifyPasswdLayer:onButtonClickedEvent( tag, ref )
             ExternalFun.playClickEffect()            
  
    if BT_EXIT == tag then
        self:removeFromParent()
    elseif BT_SURE == tag then
    	--微信和游客不需登录密码
    	if self.m_nSelectBox == CBT_LOGIN then 
			if GlobalUserItem.bVistor then
				showToast(self, strVisitorNotPassword, 2)
				return
			end
			if GlobalUserItem.bWeChat then
				showToast(self, strWeChatNotPassword, 2)
				return
			end
    	end
		local var, tips = self:confirmPasswd()
		if false == var then
			showToast(self, tips, 2)
			return
		end
		local oldpass = self.m_editOldPass:getText()
		local newpass = self.m_editNewPass:getText()
		if CBT_LOGIN == self.m_nSelectBox then   --账号登录
			self._modifyFrame:onModifyLogonPass(oldpass, newpass)
		elseif CBT_BANK == self.m_nSelectBox then
			-- 银行不同登陆
			if string.lower(newpass) == string.lower(GlobalUserItem.szPassword) then
				showToast(self, "银行密码不能与登录密码一致!", 2)
				return
			end
			self._modifyFrame:onModifyBankPass(oldpass, newpass)
		end
	elseif BT_CANCEL == tag then
		self:clearEdit()
	end
end

function ModifyPasswdLayer:onCheckBoxClickEvent(sender, eventType)
	if nil == sender then
		return
	end

	local tag = sender:getTag()
	if self.m_nSelectBox == tag then
		sender:setSelected(true)
		return
	end
	self.m_nSelectBox = tag

	local oldstr = ""
	local newstr = ""
	local oldTips = ""
	local newTips = ""
	local confirmTips = ""

	if tag == CBT_LOGIN then

		self.m_checkBank:setSelected(false)
		oldstr = "sp_login_pass.png"
		newstr = "sp_new_lgpass.png"	

		if GlobalUserItem.bWeChat == true then	  --微信
			oldTips = strWeChatNotPassword
			newTips = strWeChatNotPassword
			confirmTips = strWeChatNotPassword
			self:setEditBoxsEnabled(CBT_LOGIN)
		elseif GlobalUserItem.bVistor == true then  --游客
			oldTips = strVisitorNotPassword
			newTips = strVisitorNotPassword
			confirmTips = strVisitorNotPassword
			self:setEditBoxsEnabled(CBT_LOGIN)
		else   --账号
			oldTips = "输入您的旧登录密码"
			newTips = "输入您的新登录密码"
			confirmTips = "请再次输入您的新登录密码"		
		end	

	elseif tag == CBT_BANK then
		self.m_checkLogin:setSelected(false)
		oldstr = "sp_old_bkpass.png"
		newstr = "sp_new_bkpass.png"

		newTips = "输入您的新银行密码"
		confirmTips = "请再次输入您的新银行密码"

		if GlobalUserItem.bWeChat == true then	  --微信
			oldTips = "微信登录不需要旧银行密码"
			self:setEditBoxsEnabled(CBT_BANK)
		elseif GlobalUserItem.bVistor == true then  --游客
			oldTips = "游客登录不需要旧银行密码"
			self:setEditBoxsEnabled(CBT_BANK)
		else   --账号
			oldTips = "输入您的旧银行密码"
		end	
	end

	--刷新界面
	local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(oldstr)
	if nil ~= frame then
		self.m_spOldPass:setSpriteFrame(frame)
	end
	frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(newstr)
	if nil ~= frame then
		self.m_spNewPass:setSpriteFrame(frame)
	end
	self.m_editOldPass:setPlaceHolder(oldTips)
	self.m_editNewPass:setPlaceHolder(newTips)
	self.m_editConfirmPass:setPlaceHolder(confirmTips)
	self:clearEdit()
end

--游客和微信登录时，编辑框是否可以点击， 
function ModifyPasswdLayer:setEditBoxsEnabled( cbtTag )
	if cbtTag == CBT_LOGIN then 
		self.m_editOldPass:setEnabled(false)
		self.m_editNewPass:setEnabled(false)
		self.m_editConfirmPass:setEnabled(false)
	
	elseif cbtTag == CBT_BANK then 
		self.m_editOldPass:setEnabled(false)
		self.m_editNewPass:setEnabled(true)
		self.m_editConfirmPass:setEnabled(true)
	end
end

function ModifyPasswdLayer:onModifyCallBack( result, tips )
	if type(tips) == "string" and "" ~= tips then
		showToast(self, tips, 2)
	end
	
	if -1 ~= result then
		self:clearEdit()
	end
end

function ModifyPasswdLayer:clearEdit(  )
	self.m_editOldPass:setText("")
	self.m_editNewPass:setText("")
	self.m_editConfirmPass:setText("")
end

function ModifyPasswdLayer:confirmPasswd(  )
	local oldpass = self.m_editOldPass:getText()
	local newpass = self.m_editNewPass:getText()
	local confirm = self.m_editConfirmPass:getText()

	--游客、微信不验证原始密码
	if GlobalUserItem.bVistor == false and GlobalUserItem.bWeChat == false then
		local oldlen = string.len(oldpass)
		if 0 == oldlen then
			return false, "原始密码不能为空"
		end

		if oldlen > 26 or oldlen < 6 then
			return false, "原始密码请输入6-26位字符"
		end
		
		local md5old =  md5(oldpass)
		if self.m_nSelectBox == CBT_LOGIN then
			if oldpass ~= GlobalUserItem.szPassword then
				return false, "您输入的原登录密码有误"
			end
		end
	end


	local newlen = ExternalFun.stringLen(newpass)
	if 0 == newlen then
		return false, "新密码不能为空!"
	end

	if newlen > 26 or newlen < 6 then
		return false, "新密码请输入6-26位字符"
	end

	--空格
	local b,e = string.find(newpass, " ")
	if b ~= e then
		return false, "新密码不能输入空格字符,请重新输入"
	end

	--新旧密码
	if oldpass == newpass then
		return false, "新密码与原始密码一致,请重新输入"
	end

	--密码确认
	if newpass ~= confirm then
		return false, "两次输入的密码不一致,请重新输入"
	end

	-- 首位为字母
	--[[if 1 ~= string.find(newpass, "%a") then
		return false, "密码首位必须为字母，请重新输入！"
	end]]

	-- 与帐号不同
	if string.lower(newpass) == string.lower(GlobalUserItem.szAccount) then
		return false, "密码不能与帐号相同，请重新输入！"
	end

	return true
end

function ModifyPasswdLayer:onExit()
	if self._modifyFrame:isSocketServer() then
		self._modifyFrame:onCloseSocket()
	end
end

return ModifyPasswdLayer