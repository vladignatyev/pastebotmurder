#!/usr/bin/env python	
import wx

class CustomTaskBarIcon(wx.TaskBarIcon):
	ID_HELLO = wx.NewId()
	ID_HELLO2 = wx.NewId()
	def __init__(self):
		super(CustomTaskBarIcon, self).__init__()

		#Setup
		icon = wx.Icon("statusbaricon.png", wx.BITMAP_TYPE_PNG)
		self.SetIcon(icon)

		self.Bind(wx.EVT_MENU, self.OnMenu)

	def CreatePopupMenu(self):
		menu = wx.Menu()
		menu.Append(CustomTaskBarIcon.ID_HELLO, "HELLO")
		menu.Append(CustomTaskBarIcon.ID_HELLO2, "Hi!")
		menu.AppendSeparator()
		menu.Append(wx.ID_CLOSE, "Exit")
		return menu

	def OnMenu(self, event):
		evt_id = event.GetId()
		if evt_id == CustomTaskBarIcon.ID_HELLO:
			wx.MessageBox("Hello World!", "Hello")
		elif evt_id == CustomTaskBarIcon.ID_HELLO2:
			wx.MessageBox("Hi Again!", "Hi!")
		elif evt_id == wx.ID_CLOSE:
			self.Destroy()
		else:
			event.Skip()

class ShotBufFrame(wx.Frame):

	def __init__(self, parent, id, title):
		wx.Frame.__init__(self, parent, -1, title, size=(1,1), style=wx.FRAME_NO_TASKBAR|wx.NO_FULL_REPAINT_ON_RESIZE)
		
		self.tbiicon = CustomTaskBarIcon()
		self.Show()

if __name__ == '__main__':
	app = wx.App(False)
	frame = ShotBufFrame(None, -1, ' ')
	frame.Show(False)
	app.MainLoop()
