surface.CreateFont( "LMMSBfontclose", {
		font = "Lato Light",
		size = 25,
		weight = 250,
		antialias = true,
		strikeout = false,
		additive = true,
} )
 
surface.CreateFont( "LMMSBTitleFont", {
	font = "Lato Light",
	size = 30,
	weight = 250,
	antialias = true,
	strikeout = false,
	additive = true,
} )
 
surface.CreateFont( "LMMSBHeadingFont", {
	font = "Arial",
	size = 25,
	weight = 500,
} )

surface.CreateFont( "LMMSBTextFont", {
	font = "Arial",
	size = 15,
	weight = 500,
} )

local blur = Material("pp/blurscreen")
local function DrawBlur(panel, amount) --Panel blur function
	local x, y = panel:LocalToScreen(0, 0)
	local scrW, scrH = ScrW(), ScrH()
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(blur)
	for i = 1, 6 do
		blur:SetFloat("$blur", (i / 3) * (amount or 6))
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
	end
end

local function drawRectOutline( x, y, w, h, color )
	surface.SetDrawColor( color )
	surface.DrawOutlinedRect( x, y, w, h )
end

net.Receive( "LMMSBOpenMenu", function()

	local tablemsg = net.ReadTable()
	local xornah = net.ReadBool()
	local posts = net.ReadFloat()
	local lastrefresh = net.ReadString()
	
	function MainMenuNoX()
		local menu = vgui.Create( "DFrame" )	
		menu:SetSize( 610, 450 )
		menu:Center()
		menu:SetDraggable( false )
		menu:MakePopup()
		menu:SetTitle( "" )
		menu:ShowCloseButton( false )
		menu.Paint = function( self, w, h )
			DrawBlur(menu, 2)
			drawRectOutline( 0, 0, w, h, Color( 0, 0, 0, 85 ) )	
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 85))
			drawRectOutline( 2, 2, w - 4, h / 8.9, Color( 0, 0, 0, 85 ) )
			draw.RoundedBox(0, 2, 2, w - 4, h / 9, Color(0,0,0,125))
			draw.SimpleText( "ShoutBox", "LMMSBTitleFont", menu:GetWide() / 2, 25, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText( "Current Posts: "..posts, "LMMSBTextFont", 50, 10, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText( "Last Refresh: "..lastrefresh, "LMMSBTextFont", 70, 45, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end		
					
		local DScrollPanel = vgui.Create( "DPanelList", menu )
		DScrollPanel:SetPos( 10, 60 )
		DScrollPanel:SetSize( menu:GetWide() - 20, menu:GetTall() - 100 )
		DScrollPanel:SetSpacing( 2 )
		DScrollPanel:EnableVerticalScrollbar( true )
		DScrollPanel.VBar.Paint = function( s, w, h )
			draw.RoundedBox( 4, 3, 13, 8, h-24, Color(0,0,0,70))
		end
		DScrollPanel.VBar.btnUp.Paint = function( s, w, h ) end
		DScrollPanel.VBar.btnDown.Paint = function( s, w, h ) end
		DScrollPanel.VBar.btnGrip.Paint = function( s, w, h )
			draw.RoundedBox( 4, 5, 0, 4, h+22, Color(0,0,0,70))
		end
		
		if #tablemsg > 0 then
			for k, v in pairs( tablemsg ) do
				
				local name = v[2]
				
				if name == nil then
					name = v[6].."(offline)"
				elseif name != nil then
					name = v[2]:Nick()
				end
				
				local MessageMain = vgui.Create( "DFrame" )
				MessageMain:SetSize( DScrollPanel:GetWide(), 100 )
				MessageMain:ShowCloseButton( false )
				MessageMain:SetTitle( "" )
				MessageMain.Paint = function( self, w, h )				
					drawRectOutline( 2, 2, w - 2, h - 2, Color( 0, 0, 0, 85 ) )
					draw.RoundedBox(0, 2, 2, w , h , Color(0,0,0,125))
					draw.SimpleText( name.." said: ", "LMMSBTextFont", 84, 8, Color( 255,255, 255 ) ) -- name
					draw.SimpleText( v[3], "LMMSBTextFont", 84, 34, Color( 255,255, 255, 200 ) ) -- Message
					draw.SimpleText( v[4], "LMMSBTextFont", 84, 60, Color( 255,255, 255, 200 ) ) -- Date
--					draw.SimpleText( "Votes: "..v[5], "LMMSBTextFont", MessageMain:GetWide() - 35.5, 8, Color( 255,255, 255, 255 ), TEXT_ALIGN_RIGHT ) -- Rates up
				end
				
				local ava = vgui.Create( "AvatarImage", MessageMain )
				ava:SetPos( 15, 15 )
				ava:SetSize( 64, 64 )
				ava:SetPlayer( v[2], 64 )
					
				local RemoveButton = vgui.Create( "DButton", MessageMain )
				RemoveButton:SetPos( MessageMain:GetWide() - 110, MessageMain:GetTall() - 25 )
				RemoveButton:SetSize( 80, 20 )
				RemoveButton:SetDrawOnTop( true )
				RemoveButton:SetTextColor( Color( 255, 255, 255 ) )
				RemoveButton:SetText( "Remove" )
				RemoveButton.Paint = function( self, w, h )
					DrawBlur(RemoveButton, 2)
					drawRectOutline( 0, 0, w, h, Color( 0, 0, 0, 85 ) )	
					draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 125))
				end
				RemoveButton.DoClick = function( self )
					local DmenuR = DermaMenu()
					DmenuR:AddOption( "Are you sure?", function()
						DmenuR:Open()					
					end )
					DmenuR:AddOption( "Yes", function()
						net.Start("LMMSBRateRemove")
							net.WriteString(v[1])
						net.SendToServer()
						chat.AddText(Color(255,0,0), "Shout removed!")
					end )
					DmenuR:AddOption("No", function()
					
					end)
					DmenuR:Open()					
				end
				DScrollPanel:AddItem( MessageMain )					
			end	
		else
			local NoShouts = vgui.Create( "DLabel", menu )
			NoShouts:SetText( "There are no shouts! Be the first!" )
			NoShouts:SetFont( "LMMSBTitleFont" )
			NoShouts:SetTextColor( Color( 255, 0, 0 ) )
			NoShouts:SizeToContents()
			NoShouts:Center()
		end
		
		local PostMain = vgui.Create( "DFrame" )
		PostMain:SetPos( menu:GetTall() + 45, menu:GetWide() + 70 )
		PostMain:SetSize( 610, 100 )
		PostMain:ShowCloseButton( false )
		PostMain:SetDraggable( false )
		PostMain:MakePopup()		
		PostMain:SetTitle( "" )
		PostMain.Paint = function( self, w, h )				
			DrawBlur(PostMain, 2)
			drawRectOutline( 0, 0, w, h, Color( 0, 0, 0, 85 ) )	
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 125))
		end	
		
		local TextToSay = vgui.Create("DLabel", PostMain)
		TextToSay:SetPos( 2, 20 )
		TextToSay:SetSize( PostMain:GetWide() - 4, 20 )
		TextToSay:SetText("Enter what you want to shout out!")
		TextToSay:SetTextColor(Color(255,255,255))
		TextToSay:SetFont("LMMSBTitleFont")

		local TextToSayBAD = vgui.Create("DLabel", PostMain)
		TextToSayBAD:SetPos( 2, 80 )
		TextToSayBAD:SetSize( PostMain:GetWide() - 4, 20 )
		TextToSayBAD:SetText("WARNING: If you say something bad you could be banned from posting or on the server!")
		TextToSayBAD:SetTextColor(Color(255,0,0))
		TextToSayBAD:SetFont("LMMSBTextFont")
		
		local TextEntry = vgui.Create( "DTextEntry", PostMain )
		TextEntry:SetPos( 2, 50 )
		TextEntry:SetSize(  PostMain:GetWide() - 4,20 )
		TextEntry:SetText( "Shout!" )
		TextEntry.OnEnter = function( self )
			Derma_Query( 
			"Are you sure you would like to post this?\nThere is a chance you could get banned from posting!",
			"ShoutBox",
			"Yes I agree", function()
				net.Start("LMMSBWriteShoutout")
					net.WriteString(self:GetValue())
				net.SendToServer()
				PostMain:Close()
				PostMain:Remove()
				menu:Close()
				menu:Remove()
				net.Start("LMMSBReOpenMenu")
				net.SendToServer()
			end, 
			"No take me back", function()
				PostMain:Close()
				PostMain:Remove()
				menu:Close()
				menu:Remove()			
				MainMenu()
			end
			)
		end

		local framecloseTop = vgui.Create( "DButton", menu )
		framecloseTop:SetSize( 35, 35 )
		framecloseTop:SetPos( menu:GetWide() - 34,10 )
		framecloseTop:SetText( "X" )
		framecloseTop:SetFont( "LMMSBfontclose" )
		framecloseTop:SetTextColor( Color( 255, 255, 255 ) )
		framecloseTop.Paint = function()
			
		end
		framecloseTop.DoClick = function()
			PostMain:Close()
			PostMain:Remove()
			menu:Close()
			menu:Remove()
			gui.EnableScreenClicker( false )			
		end	
		
		local framecloseBottom = vgui.Create( "DButton", PostMain )
		framecloseBottom:SetSize( 35, 35 )
		framecloseBottom:SetPos( PostMain:GetWide() - 34,10 )
		framecloseBottom:SetText( "X" )
		framecloseBottom:SetFont( "LMMSBfontclose" )
		framecloseBottom:SetTextColor( Color( 255, 255, 255 ) )
		framecloseBottom.Paint = function()
			
		end
		framecloseBottom.DoClick = function()
			PostMain:Close()
			PostMain:Remove()
			menu:Close()
			menu:Remove()
			gui.EnableScreenClicker( false )			
		end			

		local refresh = vgui.Create( "DButton", menu )
		refresh:SetSize( 80, 35 )
		refresh:SetPos( 20,10 )
		refresh:SetText( "Refresh" )
		refresh:SetFont( "LMMSBfontclose" )
		refresh:SetTextColor( Color( 255, 255, 255 ) )
		refresh.Paint = function()
			
		end
		refresh.DoClick = function()
			menu:Close()
			menu:Remove()
			PostMain:Close()
			PostMain:Remove()
			gui.EnableScreenClicker( true )
			net.Start("LMMSBReOpenMenuNoX")
			net.SendToServer()
		end	
		
	end
	
	function MainMenu()
		local menu = vgui.Create( "DFrame" )	
		menu:SetSize( 610, 450 )
		menu:Center()
		menu:SetDraggable( false )
		menu:MakePopup()
		menu:SetTitle( "" )
		menu:ShowCloseButton( false )
		menu.Paint = function( self, w, h )
			DrawBlur(menu, 2)
			drawRectOutline( 0, 0, w, h, Color( 0, 0, 0, 85 ) )	
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 85))
			drawRectOutline( 2, 2, w - 4, h / 8.9, Color( 0, 0, 0, 85 ) )
			draw.RoundedBox(0, 2, 2, w - 4, h / 9, Color(0,0,0,125))
			draw.SimpleText( "ShoutBox", "LMMSBTitleFont", menu:GetWide() / 2, 25, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText( "Current Posts: "..posts, "LMMSBTextFont", 50, 10, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText( "Last Refresh: "..lastrefresh, "LMMSBTextFont", 70, 45, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)			
		end
		
		local frameclose = vgui.Create( "DButton", menu )
		frameclose:SetSize( 35, 35 )
		frameclose:SetPos( menu:GetWide() - 34,10 )
		frameclose:SetText( "X" )
		frameclose:SetFont( "LMMSBfontclose" )
		frameclose:SetTextColor( Color( 255, 255, 255 ) )
		frameclose.Paint = function()
			
		end
		frameclose.DoClick = function()
			menu:Close()
			menu:Remove()
			gui.EnableScreenClicker( false )			
		end	

		local refresh = vgui.Create( "DButton", menu )
		refresh:SetSize( 80, 35 )
		refresh:SetPos( 20,10 )
		refresh:SetText( "Refresh" )
		refresh:SetFont( "LMMSBfontclose" )
		refresh:SetTextColor( Color( 255, 255, 255 ) )
		refresh.Paint = function()
			
		end
		refresh.DoClick = function()
			menu:Close()
			menu:Remove()
			gui.EnableScreenClicker( true )
			net.Start("LMMSBReOpenMenu")
			net.SendToServer()
		end			
		
		local PostBtn = vgui.Create("DButton", menu)
		PostBtn:SetPos( 10, 420 )
		PostBtn:SetSize( menu:GetWide() - 20, 20 )
		PostBtn:SetText("Post")
		PostBtn:SetTextColor(Color(255,255,255))
		PostBtn.Paint = function( self, w, h )
			DrawBlur(PostBtn, 2)
			drawRectOutline( 0, 0, w, h, Color( 0, 0, 0, 85 ) )	
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 125))
		end
		PostBtn.DoClick = function()
			MainMenuNoX()
			menu:Close()
			menu:Remove()
		end
		
		local DScrollPanel = vgui.Create( "DPanelList", menu )
		DScrollPanel:SetPos( 10, 60 )
		DScrollPanel:SetSize( menu:GetWide() - 20, menu:GetTall() - 100 )
		DScrollPanel:SetSpacing( 2 )
		DScrollPanel:EnableVerticalScrollbar( true )
		DScrollPanel.VBar.Paint = function( s, w, h )
			draw.RoundedBox( 4, 3, 13, 8, h-24, Color(0,0,0,70))
		end
		DScrollPanel.VBar.btnUp.Paint = function( s, w, h ) end
		DScrollPanel.VBar.btnDown.Paint = function( s, w, h ) end
		DScrollPanel.VBar.btnGrip.Paint = function( s, w, h )
			draw.RoundedBox( 4, 5, 0, 4, h+22, Color(0,0,0,70))
		end
		
		if #tablemsg > 0 then
			for k, v in pairs( tablemsg ) do
				
				local name = v[2]
				
				if name == nil then
					name = v[6].."(offline)"
				elseif name != nil then
					name = v[2]:Nick()
				end
				
				local MessageMain = vgui.Create( "DFrame" )
				MessageMain:SetSize( DScrollPanel:GetWide(), 100 )
				MessageMain:ShowCloseButton( false )
				MessageMain:SetTitle( "" )
				MessageMain.Paint = function( self, w, h )				
					drawRectOutline( 2, 2, w - 2, h - 2, Color( 0, 0, 0, 85 ) )
					draw.RoundedBox(0, 2, 2, w , h , Color(0,0,0,125))
					draw.SimpleText( name.." said: ", "LMMSBTextFont", 84, 8, Color( 255,255, 255 ) ) -- name
					draw.SimpleText( v[3], "LMMSBTextFont", 84, 34, Color( 255,255, 255, 200 ) ) -- Message
					draw.SimpleText( v[4], "LMMSBTextFont", 84, 60, Color( 255,255, 255, 200 ) ) -- Date
--					draw.SimpleText( "Votes: "..v[5], "LMMSBTextFont", MessageMain:GetWide() - 35.5, 8, Color( 255,255, 255, 255 ), TEXT_ALIGN_RIGHT ) -- Rates up
				end
				
				local ava = vgui.Create( "AvatarImage", MessageMain )
				ava:SetPos( 15, 15 )
				ava:SetSize( 64, 64 )
				ava:SetPlayer( v[2], 64 )
					
				local RemoveButton = vgui.Create( "DButton", MessageMain )
				RemoveButton:SetPos( MessageMain:GetWide() - 110, MessageMain:GetTall() - 25 )
				RemoveButton:SetSize( 80, 20 )
				RemoveButton:SetDrawOnTop( true )
				RemoveButton:SetTextColor( Color( 255, 255, 255 ) )
				RemoveButton:SetText( "Remove" )
				RemoveButton.Paint = function( self, w, h )
					DrawBlur(RemoveButton, 2)
					drawRectOutline( 0, 0, w, h, Color( 0, 0, 0, 85 ) )	
					draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 125))
				end
				RemoveButton.DoClick = function( self )
					local DmenuR = DermaMenu()
					DmenuR:AddOption( "Are you sure?", function()
						DmenuR:Open()					
					end )
					DmenuR:AddOption( "Yes", function()
						net.Start("LMMSBRateRemove")
							net.WriteString(v[1])
						net.SendToServer()
						chat.AddText(Color(255,0,0), "Shout removed!")
					end )
					DmenuR:AddOption("No", function()
					
					end)
					DmenuR:Open()					
				end
				DScrollPanel:AddItem( MessageMain )					
			end	
		else
			local NoShouts = vgui.Create( "DLabel", menu )
			NoShouts:SetText( "There are no shouts! Be the first!" )
			NoShouts:SetFont( "LMMSBTitleFont" )
			NoShouts:SetTextColor( Color( 255, 0, 0 ) )
			NoShouts:SizeToContents()
			NoShouts:Center() 
		end			
	end	
	
	if xornah then
		MainMenu()
	else
		MainMenuNoX()
	end
	
end )