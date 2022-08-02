﻿// Получает значение предопределенного параметра
// См. описание ЗначенияПредопределенныхПараметров()
//
// Возвращаемое значение:
//	Значение параметра или массив, если указано несколько параметров по одному ключу
//
Функция ЗначениеПредопределенногоПараметра(КлючПараметра, ЗначениеПоУмолчанию = Неопределено) Экспорт

	ЗначениеПараметра = ЗначенияПредопределенныхПараметров(КлючПараметра)[КлючПараметра];	
	
	Возврат ?(ЗначениеПараметра = Неопределено, ЗначениеПоУмолчанию, ЗначениеПараметра);
	
КонецФункции

// Получает значения предопределенных параметров
// Имена параметров должны удовлетворять правилам наименования ключей структуры
// Если по одному ключу указано несколько параметров, то результатом ключа будет массив со списком этих параметров, с сортировкой по индексу
//
// Параметры:
//	КлючиПараметров - Строка, Массив, Структура
//		- Строка, где параметры перечислены через запятую
//		- Массив имен параметров
//		- Структура, где ключ - имя параметра, значение - его синоним, который будет использован при формировании результирующей структуры
//			Если синоним не заполнен, будет использоваться ключ структуры
//
// Возвращаемое значение:
//	Структура, где ключ - имя параметра или его синоним, значение - значение параметра. Если указано несколько параметров, то массив
//
// Примеры: 
//	Результат = ЗначенияПредопределенныхПараметров("ОсновнаяОрганизация, ОсновнойСклад");
//	Организация = Результат.ОсновнаяОрганизация;
//	Склад = Результат.ОсновнойСклад;
//  
//	МассивКлючей = СтрРазделить("ОсновнаяОрганизация,ОсновнойСклад", ","); 
//	Результат = ЗначенияПредопределенныхПараметров(МассивКлючей);
//	Организация = Результат.ОсновнаяОрганизация;
//	Склад = Результат.ОсновнойСклад;
//
//	СтруктураКлючей = Новый Структура("ОсновнаяОрганизация, ОсновнойСклад", "Организация");
//	Результат = ЗначенияПредопределенныхПараметров(СтруктураКлючей);
//	Организация = Результат.Организация;
//	Склад = Результат.ОсновнойСклад;
//
//	// В регистре указано несколько основных складов
//	Результат = ЗначенияПредопределенныхПараметров("ОсновнойСклад);
//	Склад1 = Результат.ОсновнойСклад[0];
//	Склад2 = Результат.ОсновнойСклад[1];
//
Функция ЗначенияПредопределенныхПараметров(КлючиПараметров) Экспорт
	
	Если НЕ ПривилегированныйРежим() Тогда
		УстановитьПривилегированныйРежим(Истина);	                              	
	КонецЕсли;
	
	ТипКлючей = ТипЗнч(КлючиПараметров);
	
	Если ТипКлючей = Тип("Структура")
		ИЛИ ТипКлючей = Тип("ФиксированнаяСтруктура") Тогда
		
		СтруктураКлючей = КлючиПараметров;
	ИначеЕсли ТипКлючей = Тип("Массив")
		ИЛИ ТипКлючей = Тип("ФиксированныйМассив") Тогда
		
		СтруктураКлючей = Новый Структура;
		
		Для каждого КлючИЗначение Из КлючиПараметров Цикл
			СтруктураКлючей.Вставить(КлючИЗначение);	
		КонецЦикла;
	Иначе
		СтруктураКлючей = Новый Структура(КлючиПараметров);
	КонецЕсли;
	
	Результат		= Новый Структура;
	СписокКлючей	= Новый Массив;
	
	Для каждого КлючИЗначение Из СтруктураКлючей Цикл
		СписокКлючей.Добавить(КлючИЗначение.Ключ);
		Результат.Вставить(?(ЗначениеЗаполнено(КлючИЗначение.Значение), КлючИЗначение.Значение, КлючИЗначение.Ключ));
	КонецЦикла;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	Д_НастройкиJira.Ключ КАК Ключ,
	|	Д_НастройкиJira.Значение КАК Значение
	|ИЗ
	|	РегистрСведений.Д_НастройкиJira КАК Д_НастройкиJira
	|ГДЕ
	|	Д_НастройкиJira.Ключ В(&СписокКлючей)
	|
	|УПОРЯДОЧИТЬ ПО
	|	Ключ,
	|	Д_НастройкиJira.Индекс
	|ИТОГИ ПО
	|	Ключ";
	
	Запрос.УстановитьПараметр("СписокКлючей", СписокКлючей);
	
	РезультатЗапроса = Запрос.Выполнить();   
	
	Выборка1 = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Пока Выборка1.Следующий() Цикл
		Выборка2 = Выборка1.Выбрать();
		
		Если Выборка2.Количество() = 0 Тогда
			Продолжить;		                          		
		КонецЕсли;
		
		Ключ = СтруктураКлючей[Выборка1.Ключ];	
		
		Если НЕ ЗначениеЗаполнено(Ключ) Тогда
			Ключ = Выборка1.Ключ;
		КонецЕсли;
		
		Выборка2 = Выборка1.Выбрать();
		
		Если Выборка2.Количество() > 1 Тогда
			Результат[Ключ] = Новый Массив;
			
			Пока Выборка2.Следующий() Цикл
				Результат[Ключ].Добавить(Выборка2.Значение);
			КонецЦикла;
		Иначе
			Выборка2.Следующий();
			
			Результат[Ключ] = Выборка2.Значение;	
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Процедура ЗаписатьЗначениеПараметра(Ключ, Значение) Экспорт
	
	НаборЗаписей = РегистрыСведений.Д_НастройкиJira.СоздатьНаборЗаписей();		
	НаборЗаписей.Отбор.Ключ.Установить(Ключ);
	НаборЗаписей.Прочитать();
	
	ПерезаписываемоеЗначение = НаборЗаписей[0];
	ПерезаписываемоеЗначение.Значение = Значение;
	
	НаборЗаписей.Записать();
	
КонецПроцедуры //ЗаписатьЗначениеПараметра