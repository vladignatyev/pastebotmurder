import feedparser

class AppCastParser(object):
	def __init__(self, appcast_xml):
		self.appcastXML = appcast_xml

	def update(self):
		self.d = feedparser.parse(self.appcastXML)

	def get_download_link(self):
		return self.d.entries[0]['links'][0]['href']

	def get_version(self):
		return self.d.entries[0]['links'][0]['sparkle:shortversionstring']

	def get_release_notes(self):
		return self.d.entries[0]['summary_detail']['value']
		
