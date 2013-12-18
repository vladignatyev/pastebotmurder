pastebotmurder
==============

PasteBot Murder Application

Copy-paste application to connect desktop and mobile using Dropbox Datastore API

sacral how-to how to build release build
----------------------------------------
Проблема со сборкой подписанного архива кроется втом, что фреймворк дропбокса не содержит Info.plist

Хуячим Info.plist:
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
      <key>CFBundleExecutable</key>
        <string>Dropbox</string>
          <key>CFBundleIdentifier</key>
            <string>com.dropbox.Dropbox</string>
              <key>CFBundleInfoDictionaryVersion</key>
                <string>6.0</string>
                  <key>CFBundleName</key>
                    <string>Dropbox</string>
                      <key>CFBundlePackageType</key>
                        <string>FMWK</string>
                          <key>CFBundleShortVersionString</key>
                            <string>2.1.0-b3</string>
                              <key>CFBundleSignature</key>
                                <string>????</string>
                                  <key>CFBundleVersion</key>
                                    <string>210</string>
                                    </dict>
                                    </plist>


Делаем архив. Выдираем .app, кладём plist в
Contents/Frameworks/Dropbox.framework/Resources/Versions/A/Resources/Info.plist

запускаем команду
codesign --force --verify --verbose --sign "Developer ID Application: Vladimir Ignatev (9MBK7F2A62)" ~/x/ShotBuf.app/Contents/Frameworks/Dropbox.framework

После этого заменяем фреймворк в архиве на полученный подписанный. Дистрибьютим через XCode

статья на стеке: http://stackoverflow.com/questions/19637131/sign-a-framework-for-osx-10-9




how-to python prototype
-----------------------

* git clone git@github.com:vladignatyev/pastebotmurder.git .
* sudo easy_install pip
* sudo pip install virtualenv
* cd python-prototype
* virtualenv env
* source env/bin/activate
* pip install -r requirements.txt
* python prototype.py
*  > login
*  > track_clipboard
