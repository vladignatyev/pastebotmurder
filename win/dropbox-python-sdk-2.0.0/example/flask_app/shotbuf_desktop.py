#!/usr/bin/env python	
import wx
import wx.html2
from wx.webkit import WebKitCtrl

from dropbox.client import DropboxClient
from dropbox.rest import ErrorResponse, RESTSocketError
from dropbox.datastore import DatastoreError, DatastoreManager, Date, Bytes
from time import time
import tempfile
from shotbuf_app import ShotBufApp
from dropbox_api import DropboxApi

ACCESS_TOKEN = ''

class CustomTaskBarIcon(wx.TaskBarIcon):
	ID_DISABLE_SHOTBUF = wx.NewId()
	ID_UNLINK_DROPBOX = wx.NewId()
	ID_CLEAR_DATA = wx.NewId()
	ID_CHECK_UPDATES = wx.NewId()

	def __init__(self):
		super(CustomTaskBarIcon, self).__init__()

		#Setup
		icon = wx.Icon("statusbaricon.png", wx.BITMAP_TYPE_PNG)
		self.SetIcon(icon)

		self.Bind(wx.EVT_MENU, self.OnMenu)

	def CreatePopupMenu(self):
		menu = wx.Menu()
		menu.Append(CustomTaskBarIcon.ID_DISABLE_SHOTBUF, "Disable ShotBuf")
		menu.AppendSeparator()

		menu.Append(CustomTaskBarIcon.ID_UNLINK_DROPBOX, "Unlink DropBox")
		menu.Append(CustomTaskBarIcon.ID_CLEAR_DATA, "Clear Data")
		menu.AppendSeparator()
		menu.Append(CustomTaskBarIcon.ID_CHECK_UPDATES, "Check for updates...")
		menu.Append(wx.ID_CLOSE, "Quit ShotBuf")
		return menu

	def OnMenu(self, event):
		evt_id = event.GetId()
		# if evt_id == CustomTaskBarIcon.ID_HELLO:
		# 	wx.MessageBox("Hello World!", "Hello")
		# elif evt_id == CustomTaskBarIcon.ID_HELLO2:
		# 	wx.MessageBox("Hi Again!", "Hi!")
		# el
		# if evt_id == wx.ID_CLOSE:
		# 	self.Destroy()
		# else:
		event.Skip()

class ShotBufFrame(wx.Frame):


	def __init__(self, parent, id, title, shotBufApp):
		self.shotBufApp = shotBufApp
		wx.Frame.__init__(self, parent, -1, title, size=(410,290))

		self.panel = wx.Panel(self)
		button = wx.Button(self.panel, label="Connect now", pos=(130,200), size=(140,50))
		secondButton = wx.Button(self.panel, label="Paste", pos=(130,150), size=(140,50))

		self.Bind(wx.EVT_BUTTON, self.OnConnectDropbox, button)
		self.Bind(wx.EVT_BUTTON, self.OnPasteButton, secondButton)
		
		self.tbiicon = CustomTaskBarIcon()

		self.timer = wx.Timer(self)

		self.last_bitmap = None
		self.Show()

	def on_timer(self, event):
		print "FUCK"
	

	def OnConnectDropbox(self, event):
		self.dialog = WebViewDialog(self, -1)
		self.dialog.parent = self
		self.dialog.shotBufApp = self.shotBufApp
		# self.Bind(wx.html2.EVT_WEBVIEW_LOADED, self.OnNavigated, self.dialog.browser)
		
		self.dialog.browser.LoadURL("http://127.0.0.1:5000/dropbox-auth-start")
		# self.dialog.browser.LoadURL("http://google.com")
		print 'Connect '
		self.dialog.Show()

	def did_login(self):
		self.Bind(wx.EVT_TIMER, self.OnPasteButton, self.timer)
		self.timer.Start(100)

	def OnPasteButton(self, event):	
		if not wx.TheClipboard.IsOpened():
			wx.TheClipboard.Open()
			bitmap_success = wx.TheClipboard.IsSupported(wx.DataFormat(wx.DF_BITMAP))
			text_success = wx.TheClipboard.IsSupported(wx.DataFormat(wx.DF_TEXT))
			if bitmap_success or text_success:
				print 'Bitmap and text supported'
				bitmap_data_object = wx.BitmapDataObject()
				text_data_object = wx.TextDataObject()
				do = wx.DataObjectComposite()
				do.Add(bitmap_data_object, True)
				do.Add(text_data_object, True)
				success = wx.TheClipboard.GetData(do)
				if success:
					format = do.GetReceivedFormat()
					data_object = do.GetObject(format)

					format_type = format.GetType()
					if format_type == wx.DF_BITMAP:
						bitmap = bitmap_data_object.GetBitmap()
						image = bitmap.ConvertToImage()
						image_data = image.GetData()
					
						isNewImage = self.shotBufApp.set_data_if_new(image_data) 
						if isNewImage:

							fileTemp = tempfile.NamedTemporaryFile(delete = False)
							bitmap.SaveFile(fileTemp.name, wx.BITMAP_TYPE_PNG)

							self.shotBufApp.paste_file(fileTemp.name)

					elif format_type in [wx.DF_UNICODETEXT, wx.DF_TEXT]:
						text = text_data_object.GetText()
						self.shotBufApp.paste_text_if_new(text)
						
					
			wx.TheClipboard.Close()



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
			self.Destroy()
			print 'asd %s' % self.shotBufApp 
			self.shotBufApp.did_login()
			self.parent.did_login()
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
	dropboxApi = DropboxApi()
	shotBufApp = ShotBufApp(dropboxApi)
	print 'is logined', shotBufApp.is_logined()

	app = wx.App(False)
	frame = ShotBufFrame(None, -1, 'ShotBuf', shotBufApp)
	frame.Show(True)
	print 'Start'
	app.MainLoop()
	print 'Start'

if __name__ == '__main__':
	main()
