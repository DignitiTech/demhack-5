## DEMHACK 5

Этот репозиторий содержит две папки для двух параллельных задач, за которые команда взялась в рамках дву-дневного хакатона DEMHACK 5.


### Часть для мобилок

`mobile_in_flutter` папка содержит в себе код с выполненой новой функции к UX в Digniti платформе для мобилок (создание и передача event-ов).

Это Flutter код. Мы выделили для публичного обозрения только код, написанный в пределах хакатона, и `w3n` папку с интерфейсами 3NWeb утилит, который код может использовать.

Заметим насколько код обычный и не пахнет никакой криптографией. Базовые утилиты (в `w3n`) инкорпорируют внутри себя все ньюнсы приватности.


### Часть для десктопа

`nextcloud_app_port_to_3NWeb` содержит в себе порт NextCloud [Notes](https://github.com/nextcloud/notes) приложения на 3NWeb-following Digniti платформу.

Этот порт/хак прошёл от состояния непонятки и невключения до чёткой процедуры изменений, открывания и начальной интерактивности.

Чтобы подчеркнуть самою эссенцию как делается переход обычного Web приложение в [3NWeb](https://opensource.ieee.org/3nweb/architecture/-/blob/main/etc/3NWeb-overview.pdf) приложение, обратимся на метод `fetchNotes` дающий данные программе. В оригинале метод делает [запрос по сети](https://github.com/nextcloud/notes/blob/master/src/NotesService.js#L62). В порте метод делает [запрос к файлам](https://github.com/DignitiTech/demhack-5/blob/main/nextcloud_app_port_to_3NWeb/src/NotesService.js#L65) предоставленные [3NWeb утилитами через `w3n`](https://github.com/DignitiTech/demhack-5/blob/main/nextcloud_app_port_to_3NWeb/src/DataOnDisk.js#L10).

Саму платформу для десктопа можно взять [тут (prerelease version 0.14.24)](https://3nsoft.com/downloads/platform-bundle/linux/0.14.24/3NWeb-x64.AppImage). Её для теста надо линкировать в папку.

В консоли, находясь в `nextcloud_app_port_to_3NWeb` (linux):
 - линкировать платформу для тестирования приложения
```
> ln -s path/to/platform/executable test-runner
```
 - для setup-а
```
> npm ci
```
 - для build-а
```
> npm run build
```
 - для теста
```
> bash run-tests-on.sh
```
