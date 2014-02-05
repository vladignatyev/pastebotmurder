#!/usr/bin/env python	
import wx
import wx.html2
from wx.webkit import WebKitCtrl
from dropbox.client import DropboxOAuth2FlowNoRedirect

from dropbox.client import DropboxClient
from dropbox.rest import ErrorResponse, RESTSocketError
from dropbox.datastore import DatastoreError, DatastoreManager, Date, Bytes
from time import time
import tempfile
from shotbuf_app import ShotBufApp
from token_provider import TokenProvider
from dropbox_api import DropboxApi

ACCESS_TOKEN = ''


class CustomTaskBarIcon(wx.TaskBarIcon):
	ID_ENABLE_SHOTBUF = wx.NewId()
	ID_DISABLE_SHOTBUF = wx.NewId()
	ID_UNLINK_DROPBOX = wx.NewId()
	ID_LINK_DROPBOX = wx.NewId()
	ID_CLEAR_DATA = wx.NewId()
	ID_CHECK_UPDATES = wx.NewId()

	def __init__(self):
		super(CustomTaskBarIcon, self).__init__()

		#Setup
		icon = wx.Icon("statusbaricon.png", wx.BITMAP_TYPE_PNG)
		self.SetIcon(icon)
		self.isEnabled = False

		self.Bind(wx.EVT_MENU, self.OnMenu)

	def CreatePopupMenu(self):
		self.menu = wx.Menu()
		
		if not self.isEnabled:
			self.disableMenuItem = self.menu.Append(CustomTaskBarIcon.ID_DISABLE_SHOTBUF, "Disable ShotBuf")
		else:
			self.menu.Append(CustomTaskBarIcon.ID_ENABLE_SHOTBUF, "Enable ShotBuf")
		self.menu.AppendSeparator()

		if shotBufApp.is_logined():
			self.menu.Append(CustomTaskBarIcon.ID_UNLINK_DROPBOX, "Unlink Dropbox")
		else:
			self.linkDropboxMenuItem = self.menu.Append(CustomTaskBarIcon.ID_LINK_DROPBOX, "Link Dropbox")

		if not shotBufApp.is_logined():
			self.disableMenuItem.Enable(False)
			self.linkDropboxMenuItem.Enable(False)

		self.menu.AppendSeparator()
		self.menu.Append(CustomTaskBarIcon.ID_CHECK_UPDATES, "Check for updates...")
		self.menu.Append(wx.ID_CLOSE, "Quit ShotBuf")
		return self.menu

	def OnMenu(self, event):
		evt_id = event.GetId()
		if evt_id == CustomTaskBarIcon.ID_DISABLE_SHOTBUF:
			self.isEnabled = True
			disable_shotbuf()
		if evt_id == CustomTaskBarIcon.ID_ENABLE_SHOTBUF:
			self.isEnabled = False
			enable_shotbuf()	
		elif evt_id == CustomTaskBarIcon.ID_UNLINK_DROPBOX:
			shotBufApp.unlink_dropbox()
			frame.ShowAsTopWindow()
			disable_shotbuf()
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
		self.style = wx.DEFAULT_FRAME_STYLE 
		wx.Frame.__init__(self, parent, -1, title, size=(410,290), style = self.style | wx.STAY_ON_TOP)

		self.panel = wx.Panel(self)
		button = wx.Button(self.panel, label="Connect now", pos=(130,200), size=(140,50))

		self.Bind(wx.EVT_BUTTON, self.OnConnectDropbox, button)

	
	

	def OnConnectDropbox(self, event):
		self.dialog = WebViewDialog(self, -1)
		self.dialog.parent = self
		self.dialog.shotBufApp = self.shotBufApp
		# self.Bind(wx.html2.EVT_WEBVIEW_LOADED, self.OnNavigated, self.dialog.browser)
		auth_flow = DropboxOAuth2FlowNoRedirect('84zxlqvsmm2py5y', 'u5sva6uz22bvuyy')
		authorize_url = auth_flow.start()

		self.dialog.browser.LoadURL(authorize_url)
		# self.dialog.browser.LoadURL("http://google.com")
		print 'Connect '
		self.SetWindowStyle(self.style)
		self.dialog.Show()

	def ShowAsTopWindow(self):
		self.SetWindowStyle(self.style | wx.STAY_ON_TOP)
		self.Show(True)
	



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
		if url == 'https://www.dropbox.com/1/oauth2/authorize_submit':
			result = self.browser.RunScript("""
				if (!document.getElementsByClassName) {
    				document.getElementsByClassName=function(cn) {
        			var allT=document.getElementsByTagName('*'), allCN=[], i=0, a;
        			while(a=allT[i++]) {
            			a.className==cn ? allCN[allCN.length]=a : null;
        			}
        			return allCN
   					}
				}
				document.title = document.getElementsByClassName('auth-code')[0].innerText;
				""")
			print 'javascript result ', self.browser.GetCurrentTitle()
			# self.parent.Hide()
			print "FUCKING SUCCESS"
			# self.Destroy()
			print 'asd %s' % self.shotBufApp 
			# self.shotBufApp.did_login()
			# enable_shotbuf()

		else:
			print 'Fail'
	
def disable_shotbuf():
	print 'time stop'
	timer.Stop()
	frame.Unbind(wx.EVT_TIMER)

def enable_shotbuf():
	print 'enable shotbuf'

	timer.Bind(wx.EVT_TIMER, OnPasteButton, timer)
	timer.Start(100)

def OnPasteButton(event):
	if not wx.TheClipboard.IsOpened():
		wx.TheClipboard.Open()
		bitmap_success = wx.TheClipboard.IsSupported(wx.DataFormat(wx.DF_BITMAP))
		text_success = wx.TheClipboard.IsSupported(wx.DataFormat(wx.DF_TEXT))
		if bitmap_success or text_success:
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
				
					isNewImage = shotBufApp.set_data_if_new(image_data) 
					if isNewImage:

						fileTemp = tempfile.NamedTemporaryFile(delete = False)
						bitmap.SaveFile(fileTemp.name, wx.BITMAP_TYPE_PNG)

						shotBufApp.paste_file(fileTemp.name)

				elif format_type in [wx.DF_UNICODETEXT, wx.DF_TEXT]:
					text = text_data_object.GetText()
					shotBufApp.paste_text_if_new(text)
					
				
		wx.TheClipboard.Close()

app = wx.App(False)
timer = wx.Timer()
dropboxApi = DropboxApi()
tokenProvider = TokenProvider()

shotBufApp = ShotBufApp(dropboxApi, tokenProvider)

frame = ShotBufFrame(None, -1, 'ShotBuf', shotBufApp)



def main():
	
	print 'is logined', shotBufApp.is_logined()

	tbiicon = CustomTaskBarIcon()
	tbiicon.parent = frame
	
	if not shotBufApp.is_logined():
		frame.Show(True)
	else:
		shotBufApp.did_login()
		enable_shotbuf()
	app.MainLoop()
	print 'Start'

if __name__ == '__main__':
	main()
