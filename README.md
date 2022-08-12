# Расширение для интеграции с Jira и модулем Insight

## Интерфейс программы в режиме 1С: Предприятие




## Подключаемый интерфейс (для тех. специалиста):


Для подключения команд и дальнейшей настройки интеграции в режиме Предприятие в модуль формы объекта, в процедуре ПриСозданииНаСервере необходимо добавить:
```
// ИнтеграцияСJira
Д_ИнтеграцияСJira.ПриСозданииНаСервере(ЭтотОбъект);
// Конец ИнтеграцияСJira
```

Следующий блок кода необходимо добавить в модуль формы объекта:

```
// ИнтеграцияСJira
&НаКлиенте
Процедура Подключаемый_ИнтеграцияJiraВыполнитьКоманду(Команда)
	Д_ИнтеграцияСJiraКлиент.ВыполнитьКоманду(Команда, ЭтаФорма, Объект);
КонецПроцедуры
// Конец ИнтеграцияСJira
```

Также для работы с Интеграцией необходимо будет указывать вызываемые методы при которых будут выполняться те или иные запросы к Jira/Insight.
На данный момент доступен лишь метод ПослеЗаписиНаСервере, его необходимо вставить в одноименный обработчик формы объекта:

```
// ИнтеграцияСJira
Д_ИнтеграцияСJira.ПослеЗаписиНаСервере(ЭтотОбъект);
// Конец ИнтеграцияСJira

```

Данное руководство будет дополняться по мере разработки и готовности к полному тестированию.

Актуальная версия 1.2.0.1
