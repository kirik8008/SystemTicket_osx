# SystemTicket

[![Make a donation to support this project](https://img.shields.io/badge/donate-YandexMoney-orange.svg?style=flat)](https://money.yandex.ru/to/41001242761077)

Program to display the ticket and work with the API CMS "СистемаЗаявок".  And added messenger for users ' communication applications.

 [ Server IM (Node.js)](https://github.com/kirik8008/imserver) to work messenger

### SystemTicket receives from the url, arrays:

- **alamofire.php?code=allticket** (Displays all open ticket)
```
//gets arrays [[value,value....]]
[["room ticket", "name user", "ticket text", "address", "contract", "phone", "latitude", "longitude"], ...]

//All values are in string

"room ticket" ( array[0] ) -  the ticket room.
"name user" ( array[1] ) - no comments)
"ticket text" ( array[2] ) - ....
"address" ( array[3] ) - ...
"contract" ( array[4] ) - contract number user.
"phone" ( array[5] ) - ...
"latitude" ( array[6] ) - Latitude. The coordinates of the display addresses on the map.
"longitude" ( array[7] ) - Longitude. The coordinates of the display addresses on the map.

```

- **alamofire.php?code=viewticket** (Display a specific ticket)

```
//sends POST
"room ticket" - the room of a specific ticket.
"employee id" - the ID of the employee making the request.
```

```
//gets arrays [key=>value,....]
["fio"=>"", "addres"=>"", "date"=>"", "dataex"=>"", "pri"=>"", "dogovor"=>"", "author"=>"", "meet"=>"", "theme"=>"", "statusx"=>"" ,"phone"=>"" ,"teamviewer"=>"" ,"location"=>""]

//All values are in string

"fio" - name user. 
"addres" - address user.
"date" - creation date of the ticket.
"dataex" - scheduled execution date.
"pri" - text ticket.
"dogovor" - contract number user.
"author" - ticket author.
"meet" - responsible for the implementation.
"theme" - ticket theme.
"statusx" - ticket status.
"phone" - phone user.
"teamviewer" - no comments))
"location" - the location of the user  (Example: "latitude_ longitude").
```


- **alamofire.php?code=closeticket** (Ticket closing)
```
//sends POST
"closeticket" - the room of a specific ticket.
"closeresult" - the result of execution(closing).
"employee id" - the ID of the employee making the request.
```

- **alamofire.php?code=newticket** (Create the ticket)

```
//send POST

"fio" - name user. 
"dogovor"  - contract number user.
"adress" - address user.
"telephone" - user phone.
"author" - ticket author (is taken from the settings).
"authorlogin" - author login (is taken from the settings).
"theme" - ticket theme.
"status" -  ticket status(new, closed).
"text" - ticket text.
"telegram" - is bool (send bot information or not)
"teamviewer" - no comments
"userId" - the ID of the employee making the request (is taken from the settings).

```

```
//gets ticket room
```

- **alamofire.php?code=themeticket** (The topic of tickets)

```
//gets array [value,...]

["theme 1", "theme 2",.......]

//ticket theme of String !
```

- **alamofire.php?code=search** (Search user)

```
//sends

"fiosearch" - name user. 
"dogovor" - contract number user.
"userId" - the ID of the employee making the request.
```

```
//gets array [[value,...]]

[["name user", "contract", "address", "phone", "teamviewer"]]

//All values are in string

"name user" ( array[0] ) - no comments.
"contract" ( array[1] ) - contract number user.
"address" ( array[2] ) - address user.
"phone" ( array[3] ) - phone user.
"teamviewer" ( array[4] ) - no comments).
```

- **alamofire.php?code=searchticket** (Search all tickets registered to a given user)
```
//send

"fiosearch" - name user
"userId" -  the ID of the employee making the request.
```

```
//gets arrays [[value]]

[["idticket", "user name", "ticket text"], ...]

//All values are in string

"idticket" ( array[0] ) - the room is already created tickets.
"user name" ( array[1] ) - no comments.
"ticket text" ( array[2] ) - ticket text.
```
