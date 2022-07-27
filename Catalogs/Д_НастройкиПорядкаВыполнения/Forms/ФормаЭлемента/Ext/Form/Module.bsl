﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("СозданоИзФормыОбъекта") Тогда
		
		Элементы.ТипОбъекта.ТолькоПросмотр = Истина;
		Элементы.ИмяОбъекта.ТолькоПросмотр = Истина;
		
		Объект.ТипОбъекта = ?("Документ" = Параметры.ТипДокумента, 
		Перечисления.Д_ТипыОбъектов.Документ, Перечисления.Д_ТипыОбъектов.Справочник);
		
		Объект.ИмяОбъекта = Параметры.ИмяДокумента;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ИспользуемыеЗапросыЗапросПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.ИспользуемыеЗапросы.ТекущиеДанные;
	ИдентификаторДляФормулы = Строка(ТекущиеДанные.ТипЗапроса) + Строка(ТекущиеДанные.НомерСтроки);
	ТекущиеДанные.ИдентификаторДляФормулы = ИдентификаторДляФормулы;
	
	ОбновитьСписокДоступныхЗапросов();
	
КонецПроцедуры
          
&НаСервере
Процедура ОбновитьСписокДоступныхЗапросов()
	
	ВариантыПеременных.Очистить();
	
	Для каждого Строка Из Объект.ИспользуемыеЗапросы Цикл
		ВариантыПеременных.Добавить(Строка.ИдентификаторДляФормулы);
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	ОбновитьСписокДоступныхЗапросов();
КонецПроцедуры
