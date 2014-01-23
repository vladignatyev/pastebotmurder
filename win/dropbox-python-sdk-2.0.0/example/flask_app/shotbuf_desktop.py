#!/usr/bin/env python	
import wx
import wx.html2
from wx.webkit import WebKitCtrl

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
		wx.Frame.__init__(self, parent, -1, title, size=(410,290))

		self.panel = wx.Panel(self)
		button = wx.Button(self.panel, label="Connect now", pos=(130,200), size=(140,50))

		self.Bind(wx.EVT_BUTTON, self.OnConnectDropbox, button)
		
		self.tbiicon = CustomTaskBarIcon()
		self.Show()

	def OnConnectDropbox(self, event):
		self.dialog = WebViewDialog(self, -1)
		# self.Bind(wx.html2.EVT_WEBVIEW_LOADED, self.OnNavigated, self.dialog.browser)
		
		self.dialog.browser.LoadURL("http://127.0.0.1:5000/dropbox-auth-start")
		# self.dialog.browser.LoadURL("http://google.com")
		print 'Connect '
		self.dialog.Show()


class WebViewDialog(wx.Dialog):
	def __init__(self, *args, **kw):
		super(WebViewDialog, self).__init__(*args, **kw)
		sizer = wx.BoxSizer(wx.VERTICAL)
		self.browser = wx.html2.WebView.New(self)
		sizer.Add(self.browser, 1, wx.EXPAND, 10)
		self.SetSizer(sizer)
		self.SetSize((700, 700))
		self.Bind(wx.html2.EVT_WEBVIEW_LOADED, self.OnNavigated, self.browser)
		# 

		self.SetTitle('Dropbox authorization')
	def OnNavigated(self, event):
		print "HUI PIZDA"
		url = event.GetURL()
		print 'URL %s' % url
		if url == 'http://127.0.0.1:5000/':
			print "FUCKING SUCCESS"
		else:
			print 'Fail'

	

class WebViewFrame(wx.Frame):

	def __init__(self, parent, id, title):
		wx.Frame.__init__(self, parent, -1, title, size=(410,290))

		self.panel = wx.Panel(self)
		self.web = WebKitCtrl(self.panel, 4030, 'http://127.0.0.1:5000/dropbox-auth-start', (5,5), (400,250))

		self.ShowModal()
		self.Show()

		self.eventLoop = wx.EventLoop()
		self.eventLoop.Run()
	
def main():
	app = wx.App(False)
	frame = ShotBufFrame(None, -1, 'ShotBuf')
	frame.Show(True)
	print 'Start'
	app.MainLoop()
	print 'Start'

if __name__ == '__main__':
	main()