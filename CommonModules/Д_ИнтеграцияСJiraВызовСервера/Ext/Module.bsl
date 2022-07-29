﻿Функция ПолучитьСтруктуруМетаданных(ДокументСправочникСсылка) Экспорт
	
	СтруктураМетаданных = Новый Структура();
	
	ТипЗначения = ТипЗнч(ДокументСправочникСсылка);
	ИмяОбъекта = Метаданные.НайтиПоТипу(ТипЗначения).ПолноеИмя();
	МассивРазделения = СтрРазделить(ИмяОбъекта, ".");
	
	СтруктураМетаданных.Вставить("ТипДокумента", МассивРазделения[0]);
	СтруктураМетаданных.Вставить("ИмяДокумента", МассивРазделения[1]);
		
	Возврат СтруктураМетаданных;
	
КонецФункции

Функция ПолучитьКоличествоПараметровДляСопоставления(ШаблонJSON) Экспорт
	
	ИндексПараметра = 0;
	ПродолжатьПоиск = Истина;
	
	Пока ПродолжатьПоиск Цикл
		
		ИндексПараметра = ИндексПараметра + 1;
		ИмяПараметра = "#Параметр" + Строка(ИндексПараметра) + "#";
		
		Если СтрНайти(ШаблонJSON, ИмяПараметра) = 0 Тогда
			ПродолжатьПоиск = Ложь;
			ИндексПараметра = ИндексПараметра - 1;
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ИндексПараметра;
	
КонецФункции

Функция СформироватьСтандартныйШаблонЗапроса(ШаблонJSON, ДанныеОбъекта) Экспорт
	
	КоличествоСтрок = ПолучитьКоличествоПараметровДляСопоставления(ШаблонJSON);
	ТекстЗапроса = "ВЫБРАТЬ";
	
	Для Счетчик = 1 По КоличествоСтрок Цикл
		ИмяПараметра = "#Параметр" + Строка(Счетчик) + "#";
		ШаблонСтрокиЗапроса = ?(Счетчик = КоличествоСтрок, " 	%1.%2 КАК %2", " 	%1.%2 КАК %2,");
		ТекстЗапроса = ТекстЗапроса + Символы.ПС + СтрШаблон(ШаблонСтрокиЗапроса, ДанныеОбъекта.ИмяОбъекта, ИмяПараметра);
	КонецЦикла;
	
	ШаблонОкончанияЗапроса = "ИЗ
	|	%1.%2 КАК %2
	|ГДЕ
	|	%2.Ссылка = &Ссылка";
	ТекстЗапроса = ТекстЗапроса + Символы.ПС + СтрШаблон(ШаблонОкончанияЗапроса, ДанныеОбъекта.ТипОбъекта, ДанныеОбъекта.ИмяОбъекта);
	
	Возврат ТекстЗапроса;
	
КонецФункции

Функция НазначенныеТипыЗапросовПоОбъекту(СсылкаНаОбъект, ВызываемыйМетод) Экспорт
	
	СтруктураМетаданных = Д_ИнтеграцияСJiraВызовСервера.ПолучитьСтруктуруМетаданных(СсылкаНаОбъект);
	
	Запрос = Новый Запрос();
	Запрос.Текст = "ВЫБРАТЬ
	|	Д_НастройкиПорядкаВыполненияИспользуемыеЗапросы.Запрос КАК Запрос,
	|	Д_НастройкиПорядкаВыполненияИспользуемыеЗапросы.ИдентификаторДляФормулы КАК ИдентификаторДляФормулы
	|ИЗ
	|	Справочник.Д_НастройкиПорядкаВыполнения.ИспользуемыеЗапросы КАК Д_НастройкиПорядкаВыполненияИспользуемыеЗапросы
	|ГДЕ
	|	Д_НастройкиПорядкаВыполненияИспользуемыеЗапросы.Ссылка.ТипОбъекта = &ТипОбъекта
	|	И Д_НастройкиПорядкаВыполненияИспользуемыеЗапросы.Ссылка.ИмяОбъекта = &ИмяОбъекта
	|	И Д_НастройкиПорядкаВыполненияИспользуемыеЗапросы.Ссылка.ВызываемыйМетод = &ВызываемыйМетод
	|
	|УПОРЯДОЧИТЬ ПО
	|	Д_НастройкиПорядкаВыполненияИспользуемыеЗапросы.НомерСтроки"; 
	
	Запрос.УстановитьПараметр("ТипОбъекта", ?(СтруктураМетаданных.ТипДокумента = "Документ", Перечисления.Д_ТипыОбъектов.Документ, Перечисления.Д_ТипыОбъектов.Справочник));
	Запрос.УстановитьПараметр("ИмяОбъекта", СтруктураМетаданных.ИмяДокумента);
	Запрос.УстановитьПараметр("ВызываемыйМетод", ВызываемыйМетод);
	
	ТаблицаЗапросов = Запрос.Выполнить().Выгрузить();
	
	Если ТаблицаЗапросов.Количество() = 0 Тогда
		ВызватьИсключение НСтр("ru = 'Отправка данных не может быть выполнена по причине:
							| Не заполнена таблица используемых запросов'");
	КонецЕсли;
	
	Возврат ТаблицаЗапросов;
	
КонецФункции                

Функция ПолучитьСопоставленныеПараметры(СсылкаНаШаблон) Экспорт
	  
	Запрос = Новый Запрос();
	Запрос.Текст = "ВЫБРАТЬ
	|	Д_НастройкиШаблоновОтправкиСопоставленныеПараметры.Параметр КАК Параметр,
	|	Д_НастройкиШаблоновОтправкиСопоставленныеПараметры.СопоставленноеЗначение КАК СопоставленноеЗначение
	|ИЗ
	|	Справочник.Д_НастройкиШаблоновОтправки.СопоставленныеПараметры КАК Д_НастройкиШаблоновОтправкиСопоставленныеПараметры
	|ГДЕ
	|	Д_НастройкиШаблоновОтправкиСопоставленныеПараметры.Ссылка = &СсылкаНаШаблон";
	Запрос.УстановитьПараметр("СсылкаНаШаблон", СсылкаНаШаблон);
	
	ТаблицаСоответствий = Запрос.Выполнить().Выгрузить();
	
	Если ТаблицаСоответствий.Количество() = 0 Тогда
		ВызватьИсключение НСтр("ru = 'Отправка данных не может быть выполнена по причине:
							| Не существует записи сопоставления параметров.'");
	КонецЕсли;
		
	Возврат ТаблицаСоответствий;                 
	
КонецФункции  

Функция ПолучитьЗапросДляОбъекта(СсылкаНаШаблон) Экспорт	
	
	ШаблонТекстаЗапроса = "";
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Д_НастройкиШаблоновОтправки.ШаблонЗапроса КАК ШаблонЗапроса
	|ИЗ
	|	Справочник.Д_НастройкиШаблоновОтправки КАК Д_НастройкиШаблоновОтправки
	|ГДЕ
	|	Д_НастройкиШаблоновОтправки.Ссылка = &СсылкаНаШаблон";
	Запрос.УстановитьПараметр("СсылкаНаШаблон", СсылкаНаШаблон);
	РезультатЗапроса = Запрос.Выполнить();
	Выборка = РезультатЗапроса.Выбрать();
	
	Если Выборка.Следующий() Тогда
		ШаблонТекстаЗапроса = Выборка.ШаблонЗапроса;
	КонецЕсли;
	
	Возврат ШаблонТекстаЗапроса;
	
КонецФункции

Функция ПолучитьШаблонВыполненияЗапросов(СсылкаНаОбъект, ВызываемыйМетод) Экспорт
	
	СтруктураМетаданных = Д_ИнтеграцияСJiraВызовСервера.ПолучитьСтруктуруМетаданных(СсылкаНаОбъект);
	ШаблонВыполненияЗапроса = "";
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Д_НастройкиПорядкаВыполнения.ШаблонВыполнения КАК ШаблонВыполнения
	|ИЗ
	|	Справочник.Д_НастройкиПорядкаВыполнения КАК Д_НастройкиПорядкаВыполнения
	|ГДЕ
	|	Д_НастройкиПорядкаВыполнения.ТипОбъекта = &ТипОбъекта
	|	И Д_НастройкиПорядкаВыполнения.ИмяОбъекта = &ИмяОбъекта
	|	И Д_НастройкиПорядкаВыполнения.ВызываемыйМетод = &ВызываемыйМетод";
	
	Запрос.УстановитьПараметр("ТипОбъекта", ?(СтруктураМетаданных.ТипДокумента = "Документ", Перечисления.Д_ТипыОбъектов.Документ, Перечисления.Д_ТипыОбъектов.Справочник));
	Запрос.УстановитьПараметр("ИмяОбъекта", СтруктураМетаданных.ИмяДокумента);
	Запрос.УстановитьПараметр("ВызываемыйМетод", ВызываемыйМетод);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.Следующий() Тогда
		ШаблонВыполненияЗапроса = Выборка.ШаблонВыполнения;
	КонецЕсли;
		
	Возврат ШаблонВыполненияЗапроса;
	
КонецФункции