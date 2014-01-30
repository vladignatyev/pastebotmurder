import dropbox
from dropbox.datastore import DatastoreError, DatastoreManager, Date, Bytes
from datetime import datetime


class DropboxApi(object):

	def login_with_token(self, token):
		self.token = token
		self.client = dropbox.client.DropboxClient(self.token)

		print 'linked account: ', self.client.account_info()

		manager = DatastoreManager(self.client)
		self.datastore = manager.open_default_datastore()
		self.bufs_table = self.datastore.get_table('bufs_values')

	def clear_data(self):
		pass

	def insert_text(self, text, type='plain'):
		dt = datetime.now()
		d = Date.from_datetime_local(dt)
		buf = self.bufs_table.insert(value=text, type=type, created=d)
		self.datastore.commit()

	def upload_file(self, file):
		f = open(file, 'rb')
		dt = datetime.now()

		upload_file_name = 'Shot at %s.png' % dt.strftime("%d.%m.%y %H:%M:%S")

		response = self.client.put_file(upload_file_name, f)
		
		d = Date.from_datetime_local(dt)

		buf = self.bufs_table.insert(value=upload_file_name, type='image', created=d)
		self.datastore.commit()
