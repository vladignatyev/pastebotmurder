#!/usr/bin/env python	
import wx
import wx.html2
import sys
import logging
from wx.webkit import WebKitCtrl
import wx.html
import urllib3

from time import time
import tempfile
from shotbuf_app import ShotBufApp
from token_provider import TokenProvider
from dropbox_api import DropboxApi
from util import resource_path
from update_checker import UpdateChecker
import update_checker
from appcast_parser import AppCastParser
import array
import numpy
import webbrowser
import wx.lib.agw.genericmessagedialog as GMD

from wx.lib.delayedresult import startWorker

ACCESS_TOKEN = ''

def check_if_new_version_is_available():
	result = updateChecker.is_newest_version_available()
	if updateChecker.is_newest_version_available():
		message = 'You are currently running version %s, version %s is now available for download.\n\nDo you wish to install it now?'
		message = message % (update_checker.CURRENT_VERSION, updateChecker.get_newest_version())
		print message
		dlg = wx.MessageDialog(frame, message, 'A new version of Shotbuf is available.', wx.YES_NO | wx.YES_DEFAULT | wx.ICON_QUESTION)
		# dlg.SetIcon('distributive.icns')
		retCode = dlg.ShowModal()
		if (retCode == wx.ID_YES):
			print "yes"
			webbrowser.open('http://shotbuf.com/d')
			# dlg.ShowModal()
			dlg.Destroy()
			print 'after'
	return result



class CustomTaskBarIcon(wx.TaskBarIcon):
	ID_ENABLE_SHOTBUF = wx.NewId()
	ID_DISABLE_SHOTBUF = wx.NewId()
	ID_UNLINK_DROPBOX = wx.NewId()
	ID_LINK_DROPBOX = wx.NewId()
	ID_CLEAR_DATA = wx.NewId()
	ID_CHECK_UPDATES = wx.NewId()
	ID_QUIT_SHOTBUF = wx.NewId() 

	def __init__(self):
		super(CustomTaskBarIcon, self).__init__()

		self.isEnabled = False

		self.Bind(wx.EVT_MENU, self.OnMenu)
		
		self.ChangeDisableIcon()

	def ChangeActiveIcon(self):
		icon = wx.Icon(resource_path("active.png"), wx.BITMAP_TYPE_PNG)
		self.SetIcon(icon)

	def ChangeDisableIcon(self):
		icon = wx.Icon(resource_path("inactive.png"), wx.BITMAP_TYPE_PNG)
		self.SetIcon(icon)

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
		self.menu.Append(CustomTaskBarIcon.ID_QUIT_SHOTBUF, "Quit ShotBuf")
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
		elif evt_id == CustomTaskBarIcon.ID_CHECK_UPDATES:
			print 'Check updates'
			if not check_if_new_version_is_available():
				message = 'ShotBuf %s is currently the newest version available.' % update_checker.CURRENT_VERSION
				dlg = wx.MessageDialog(frame, message, "You're up to date!", wx.OK | wx.ICON_INFORMATION | wx.STAY_ON_TOP)
				dlg = dlg.ShowModal()
				
			# dlg.ShowModal()
		elif evt_id == CustomTaskBarIcon.ID_QUIT_SHOTBUF:
			app.ExitMainLoop()
			# dlg.Destroy()
			# dialog = MyDialog(self, -1)
			# print 'dialog', dialog
			# dialog.Show()
			# # if not updateChecker.is_newest_version_available():
			# updateChecker.is_newest_version_available()
			# updateCheckerFrame.ShowAsTopWindow()
        	# dlg.Destroy()
        	# else:
   #      elif evt_id == wx.ID_EXIT:
			# disable_shotbuf()
			# print 'Quit'
			# app.ExitMainLoop()
		# 	wx.MessageBox("Hello World!", "Hello")
		# elif evt_id == CustomTaskBarIcon.ID_HELLO2:
		# 	wx.MessageBox("Hi Again!", "Hi!")
		# el
		# if evt_id == wx.ID_CLOSE:
		# 	self.Destroy()
		# else:
		event.Skip()

class TransparentText(wx.StaticText):
  def __init__(self, parent, id=wx.ID_ANY, label='', 
               pos=wx.DefaultPosition, size=wx.DefaultSize, 
               style=wx.TRANSPARENT_WINDOW, name='transparenttext'):
    wx.StaticText.__init__(self, parent, id, label, pos, size, style, name)

    self.Bind(wx.EVT_PAINT, self.on_paint)
    self.Bind(wx.EVT_ERASE_BACKGROUND, lambda event: None)
    self.Bind(wx.EVT_SIZE, self.on_size)

  def on_paint(self, event):
    bdc = wx.PaintDC(self)
    dc = wx.GCDC(bdc)

    font_face = self.GetFont()
    font_color = self.GetForegroundColour()

    dc.SetFont(font_face)
    dc.SetTextForeground(font_color)
    dc.DrawText(self.GetLabel(), 0, 0)

  def on_size(self, event):
    self.Refresh()
    event.Skip()

class ShotBufFrame(wx.Frame):
	def __init__(self, parent, id, title, shotBufApp):
		self.shotBufApp = shotBufApp
		self.style = (wx.DEFAULT_FRAME_STYLE  ^ wx.RESIZE_BORDER ^ wx.CLOSE_BOX ^ wx.MAXIMIZE_BOX)
		# self.style =   wx.MINIMIZE_BOX | wx.MAXIMIZE_BOX | wx.RESIZE_BORDER | wx.SYSTEM_MENU | wx.CLOSE_BOX | wx.CLIP_CHILDREN

		wx.Frame.__init__(self, parent, -1, title, size=(410,305), style = self.style | wx.STAY_ON_TOP)

		self.panel = wx.Panel(self)
		width, height = self.GetSize()
		print 'width, height', width, height
		

		backgroundImg = wx.Image('welcome.png', wx.BITMAP_TYPE_ANY)
		backgroundImg.Resize((width,height), pos=(width/4-30,height/4-25), r=255, g=255, b=255)



		scaledImg = backgroundImg.Scale(width, height, wx.IMAGE_QUALITY_HIGH)
		print 'scaled', scaledImg
		backgroundBitmap = wx.StaticBitmap(self.panel, -1, wx.BitmapFromImage(backgroundImg))

		dropboxImg = wx.Image('dropbox.png', wx.BITMAP_TYPE_PNG)
		dropboxImg.Rescale(120, 36, wx.IMAGE_QUALITY_HIGH)

		
		dropboxBitmap = wx.StaticBitmap(self.panel, -1, dropboxImg.ConvertToBitmap(), pos=(275, 210))

		connectText = TransparentText(self.panel, -1, 'Connect to your Dropbox account', size=(279, 20), pos=(66, 25)) 
		font = wx.Font(13, wx.FONTFAMILY_DEFAULT, wx.NORMAL,wx.FONTWEIGHT_BOLD)
		connectText.SetFont(font)

		button = wx.Button(backgroundBitmap, label="Connect now", pos=(130,213), size=(140,35))
		self.Bind(wx.EVT_BUTTON, self.OnConnectDropbox, button)

	
	

	def OnConnectDropbox(self, event):
		self.dialog = WebViewDialog(self, -1)
		self.dialog.parent = self
		self.dialog.shotBufApp = self.shotBufApp

		self.dialog.browser.LoadURL(shotBufApp.get_auth_url())

		self.SetWindowStyle(self.style)
		self.dialog.Show()

	def ShowAsTopWindow(self):
		self.SetWindowStyle(self.style | wx.STAY_ON_TOP)
		self.Center()
		self.Show(True)
	


class WebViewDialog(wx.Dialog):
	def __init__(self, *args, **kw):
		super(WebViewDialog, self).__init__(*args, **kw)
		sizer = wx.BoxSizer(wx.VERTICAL)
		self.browser = wx.html2.WebView.New(self)
		sizer.Add(self.browser, 1, wx.EXPAND, 10)
		self.SetSizer(sizer)
		self.SetSize((1024, 768))
		self.Bind(wx.html2.EVT_WEBVIEW_LOADED, self.OnNavigated, self.browser)

		self.Center()
		self.SetTitle('Dropbox authorization')

	def OnNavigated(self, event):
		url = event.GetURL()
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
			auth_code = self.browser.GetCurrentTitle()
			self.parent.Hide()
			self.Destroy()
			
			startWorker(did_login, self.shotBufApp.did_finish_auth(auth_code))
			

		else:
			print 'Fail'

def did_login(result):
	enable_shotbuf()
	
def disable_shotbuf():
	tbiicon.ChangeDisableIcon()
	timer.Stop()
	frame.Unbind(wx.EVT_TIMER)

def enable_shotbuf():
	shotBufApp.enable()
	tbiicon.ChangeActiveIcon()

	timer.Bind(wx.EVT_TIMER, OnPasteButton, timer)
	timer.Start(100)

def upload_finish(result):
	print 'result finish', result.get()

def upload_file(filename):
	shotBufApp.paste_file(filename)
	return filename

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

				if format_type in [wx.DF_DIB, wx.DF_BITMAP]:
					bitmap = bitmap_data_object.GetBitmap()
					size = bitmap.GetSize()

					image_data = numpy.zeros((size[0], size[1], 3), dtype=numpy.uint8)

					image = bitmap.ConvertToImage()
					rgb_bitmap = image.ConvertToBitmap()
					rgb_bitmap.CopyToBuffer(image_data)
				
	
					isNewImage = shotBufApp.set_image_data_if_new(image_data) 
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

appcastReader = AppCastParser("http://shotbuf.com/exe/appcast32.xml")
updateChecker = UpdateChecker(appcastReader)

frame = ShotBufFrame(None, -1, 'ShotBuf', shotBufApp)

tbiicon = CustomTaskBarIcon()
tbiicon.parent = frame

logging.basicConfig(filename='shotbuf.log',level=logging.DEBUG)

logging.info('asdasdasd')
stor = resource_path('storage.txt')
cert = resource_path('trusted-certs.crt')
logging.info(stor)
logging.info(cert)

def my_handler(type, value, tb):
    logging.exception("Uncaught exception: {0}".format(str(value)))

# Install exception handler
sys.excepthook = my_handler

def main():
	logging.info('is logined')
	print 'is logined', shotBufApp.is_logined()
	
	if not shotBufApp.is_logined():
		print 'Show top frame'
		logging.info('Show top frame')
		frame.ShowAsTopWindow()
		app.MainLoop()
	else:
		try:
			shotBufApp.did_login()
			check_if_new_version_is_available()
			enable_shotbuf()
			app.MainLoop()
		except urllib3.exceptions.MaxRetryError:
			dlg = wx.MessageDialog(frame, "Please, check your internet connection.", "Network error!", wx.OK | wx.ICON_ERROR | wx.STAY_ON_TOP)

			dlg.ShowModal()
			dlg.Destroy()
		
	
	print 'Start'

if __name__ == '__main__':
	main()
