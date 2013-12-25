* Собираем в XCode архив
* Закидываем подписанный Dropbox.framework в директорию Frameworks в архиве
* Делаем дистрибьюцию с помощью Export Developer ID-signed Application
* Собираем .dmg с помощью distribute.sh
* убеждаемся что собранный .dmg корректно работает => на тестирование
* делаем подписывание с помощью Sparkle и sign_update.sh (см. исходники) и сохраняем временно DSA сигнатуру
* добавляем новую запись в Site/app/appcast.xml и прописываем DSA сигнатуру
* создаём release notes и заливаем <версия>.html в Site/app/

Если improperly signed: https://github.com/andymatuschak/Sparkle/issues/114