# Patch 0.9.2 --- Incremental Search Engine

## Цель

Добавить полноценный движок поиска для **UniListView**, который
одинаково работает в режимах **List**, **Cards** и **Tree**.

## Общие требования

-   UTF-8 BOM
-   CRLF
-   Не использовать `with`
-   Guard Clauses
-   Без magic numbers
-   При необходимости добавить `System.UITypes`
-   Все новые unit'ы добавить в runtime package, demo и `.dproj`

## Новый unit

`UniList.Search.pas`

## Новые свойства

``` delphi
SearchText: string;

SearchOptions:
  soIgnoreCase
  soVisibleColumnsOnly
  soWrapAround
  soRespectFilters
```

## Новые методы

``` delphi
FindNext;
FindPrevious;
ClearSearch;
```

## Функциональность

-   При выключенном `soVisibleColumnsOnly` поиск выполняется по всем
    scalar-полям `TUniListItem.Data`, включая поля без колонок.
-   При включённом `soRespectFilters` поиск ограничивается элементами,
    прошедшими активные фильтры.
-   Пока строка поиска не пуста, List и Cards показывают только найденные
    элементы. Tree дополнительно сохраняет цепочки родителей найденных узлов.
-   Найденный текст подсвечивается с использованием реальных метрик шрифта.
    Текущий результат выбирается целиком и прокручивается в область просмотра.

### List

-   Поиск по видимым колонкам.
-   Подсветка найденного текста.

### Cards

-   Поиск по карточкам.
-   Подсветка совпадений.

### Tree

-   Автоматическое раскрытие пути к найденному узлу.
-   Восстановление прежнего состояния дерева после очистки поиска.

## Demo

Добавить строку поиска.

Горячие клавиши:

-   Ctrl+F
-   Enter
-   Shift+Enter
-   Esc

## Изменяемые файлы

-   UniList.Control.pas
-   UniList.Search.pas (новый)
-   MainUnit.pas
-   MainUnit.fmx
-   Runtime package
-   Demo project

## Acceptance Criteria

-   Работает в List, Cards и Tree.
-   Подсветка использует текущую тему.
-   Совместимо с виртуализацией.
-   Сохраняет отзывчивость интерфейса при 100 000 элементов.
-   Компилируется без предупреждений.
