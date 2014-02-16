import unittest

from appcast_parser import AppCastParser

	
app_cast = """<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
				<channel>
					<title>ShotBuf's Changelog</title>
					<link>http://shotbuf.com/exe/appcast64.xml</link>
					<description>Most recent changes with links to updates.</description>
					<language>en</language>
					<item>
						<title>Version 1.2.0</title>
						<description>
							<![CDATA[
								<h2>Version 1.2.0 (stable)</h2> <p>First public release.</p> <p>List of updates:</p> <ol> <li>fixed rare application crush</li> <li>improved look and feel of context popup</li> <li>improved responsiveness</li> <li>temporary removed "Clear data" button</li> </ol>
								]]>
						</description>
					<sparkle:releaseNotesLink>http://shotbuf.com/exe/1.2.0.html</sparkle:releaseNotesLink>
					<pubDate>Fri, 7 Feb 2014 10:31:28 +0000</pubDate>
					<enclosure url="http://shotbuf.com/exe/ShotBuf_1.2.0_64-bit.exe" sparkle:version="" sparkle:shortVersionString="1.2.0" sparkle:dsaSignature="" length="" type="application/octet-stream"/>
					</item>
				</channel>
			</rss>
"""

app_cast_with_multiple_items = """
	<rss xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/" version="2.0">
		<channel>
			<title>ShotBuf's Changelog</title>
			<link>http://shotbuf.com/app/appcast.xml</link>
			<description>Most recent changes with links to updates.</description>
			<language>en</language>
			<item>
				<title>Version 1.2.0</title>
				<description>
					<![CDATA[
						<h2>Version 1.2.0 (stable)</h2> <p>First public release.</p> <p>List of updates:</p> <ol> <li>fixed rare application crush</li> <li>improved look and feel of context popup</li> <li>improved responsiveness</li> <li>temporary removed "Clear data" button</li> </ol>
					]]>
				</description>
			<sparkle:releaseNotesLink>http://shotbuf.com/app/1.2.0.html</sparkle:releaseNotesLink>
			<pubDate/>
			<enclosure url="http://shotbuf.com/app/ShotBuf 1.2.0.dmg" sparkle:version="120" sparkle:shortVersionString="1.2.0" sparkle:dsaSignature="MCwCFDIHV0wrGpDwnvJku6b2Y4Dn5JeMAhQcrZkA1LV0MSYzeVWL4eRaWUE5sg==" length="1938151" type="application/octet-stream"/>
			</item>
			<item>
			<title>Version 1.0 (First release)</title>
			<description>
			<![CDATA[
				<h2>First release</h2> <p>The release contains only basic functionality.</p> <p>List of features:</p> <ol> <li>plain text sharing</li> <li>links sharing</li> <li>e-mails sharing</li> <li>images sharing</li> <li>link/unlink Dropbox account</li> <li>status bar "phantom" user interface</li> <li>auto-updates</li> </ol>
			]]>
			</description>
			<sparkle:releaseNotesLink>http://shotbuf.com/app/1.0.html</sparkle:releaseNotesLink>
			<pubDate>Thu, 23 Jan 2013 15:51:28 +0000</pubDate>
			<enclosure url="http://shotbuf.com/app/ShotBuf 1.0.dmg" sparkle:version="100" sparkle:shortVersionString="1.0" sparkle:dsaSignature="MC4CFQDYb7apZqTd77sZor9cfE1EvcSP7AIVAKyuf3Wh+8iWs/u/FFBz5eSGtQBP" length="1633263" type="application/octet-stream"/>
			</item>
		</channel>
	</rss>"""

expected_release_notes = """<h2>Version 1.2.0 (stable)</h2> <p>First public release.</p> <p>List of updates:</p> <ol> <li>fixed rare application crush</li> <li>improved look and feel of context popup</li> <li>improved responsiveness</li> <li>temporary removed "Clear data" button</li> </ol>"""

class AppCastParseTest(unittest.TestCase):

	def setUp(self):
		self.appCastParser = AppCastParser(app_cast)
		self.appCastParser.update()

	def test_should_get_download_url(self):
		self.assertEqual('http://shotbuf.com/exe/ShotBuf_1.2.0_64-bit.exe', self.appCastParser.get_download_link())

	def test_should_get_version(self):
		self.assertEqual('1.2.0', self.appCastParser.get_version())

	def test_should_get_version(self):
		parser = AppCastParser(app_cast_with_multiple_items)
		parser.update()
		self.assertEqual('1.2.0', parser.get_version())
	
	def test_get_release_notes(self):
		self.assertEqual(expected_release_notes, self.appCastParser.get_release_notes())	
