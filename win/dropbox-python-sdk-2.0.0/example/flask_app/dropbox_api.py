import dropbox
from dropbox.datastore import DatastoreError, DatastoreManager, Date, Bytes
from datetime import datetime


class DropboxApi(object):

	def login_with_token(self, token):
		self.token = token
		self.client = dropbox.client.DropboxClient(self.token)

		print 'linked account: ', self.client.account_info()

		self.manager = DatastoreManager(self.client)
		self.datastore = self.manager.open_default_datastore()
		self.bufs_table = self.datastore.get_table('bufs_values')

	def unlink(self):
		self.datastore.close()

	def insert_text(self, text, type='plain'):
		def insert_record():
			dt = datetime.now()
			d = Date.from_datetime_local(dt)
			buf = self.bufs_table.insert(value=text, type=type, created=d)
		self.datastore.transaction(insert_record, max_tries=4)

	def upload_file(self, file):
		dt = datetime.now()
		def insert_record():
			d = Date.from_datetime_local(dt)
			buf = self.bufs_table.insert(value=upload_file_name, type='image', created=d)

		f = open(file, 'rb')

		upload_file_name = 'Shot at %s.png' % dt.strftime("%d.%m.%y %H:%M:%S")

		response = self.client.put_file(upload_file_name, f)
		
		self.datastore.transaction(insert_record, max_tries=4)
