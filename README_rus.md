# SVGA_NOTE_RECOGNIZER

## Цель

Целью проекта является распознование нот и их отображение на нотном стане

## Используемые проекты

Проект создан на основе следующих проектов:

* https://github.com/yuri-panchul/basics-graphics-music
* https://github.com/dsmv/2023-lalambda-fpga-labs
* https://github.com/dsmv/vivado_simulation_example

## Структура каталогов

Структура каталогов повторяет структуру проекта basics-graphics-music

* boards - каталоги с проектами для целевых плат
    * rzrd_svga - модуль RZRD с поддержкой режима SVGA 1024x768
* labs   - каталоги лабораторных
    * 99_svga - проекты
    * svga_osc - портирование проекта lab_ext_svga_osc из 2023-lalambda-fpga-labs
    * svga_note_recognizer - распознование нот
    * common - общие файлы для синтеза
    * tb_common - общие файлы для моделирования
* peripherals - общие компоненты
* scripts - командные файлы

## Моделирование

Моделирование выполняется в системе Vivado. Тестовый пример разработан на основе проекта vivado_simulation_example.

Требуется провести подготовку как указано в документе: https://github.com/dsmv/vivado_simulation_example/blob/main/README_rus.md

В файле labs/99_svga/svga_note_recognizer/run_sim_vivado/env.sh необходимо указать путь к установленной системе Vivado.

Рабочий каталог для моделирования: labs/99_svga/svga_note_recognizer/run_sim_vivado/sim_01

Командные файлы:

* compile.sh - компиляция исходных текстов. Файл systemverilog.sh содержит список файлов для компиляции
* elaborate.sh - сборка проекта
* c_run_0.sh - запуск моделирования в режиме командной строки
* g_run.sh - запуск Vivado в режиме GUI
* g_run.tcl - команда на перезапуск сеанса моделирования.

В файле g_run.tcl указаны файлы .wcfg с описанием сигналов для временных диаграмм.

## Алгоритм работы в системе Visual Studio Code

* Открыть каталог labs/99_svga/svga_note_recognizer/run_sim_vivado/sim_01 во строенном терминале Visual Studio Code
* Провести настройку на систему моделирования: source ../env.sh  
* Провести компиляцию: ./compile.sh
* Провести сборку: ./elaborate.sh
* Запустить Vivado в режиме GUI:
    * Открыть каталог labs/99_svga/svga_note_recognizer/run_sim_vivado/sim_01 (Open Container Folder)
    * Открыть терминал
    * Запустить: ./g_run.sh
* Запустить сеанс моделирования на 280 us

Для перезапуска сеанса моделирования:
* Действия во встроенном терминале Visual Studio Code (предполагается что он открыт и там выполнени source ../env.sh)
    * Провести компиляцию: ./compile.sh
    * Провести сборку: ./elaborate.sh
* Действия в Vivado GUI:
    * Выполнить команду relaunch_sim через иконку в строке Toolbox. Предполагается что выполнена подготовка в соотвествии с указаниями в проекте vivado_simulation_example
    * Запустить сеанс моделирования на 280 us    

Перед выполнением relaunch_sim требуется сохранить все изменения в окнах временных диаграмм.

В файл g_run.tcl можно добавить указания на открытие новых окон временных диаграмм. Для добавления импользуется параметр -view <имя>.wcfg

