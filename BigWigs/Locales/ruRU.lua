local L = LibStub("AceLocale-3.0"):NewLocale("Big Wigs", "ruRU")

if not L then return end

-- Core.lua
L["%s has been defeated"] = "%s побеждён"

L.bosskill = "Смерть босса"
L.bosskill_desc = "Объявлять о смерти босса."
L.berserk = "Берсерк"
L.berserk_desc = "Предупреждать и отсчитывать время до берсерка."

L.already_registered = "|cffff0000ВНИМАНИЕ:|r |cff00ff00%s|r (|cffffff00%s|r) уже загружен как модуль Big Wigs, но что-то пытается зарегистрировать его ещё раз. Обчно, это означает, что у вас две копии этого модуля в папке с модификациями (возможно, из-за ошибки программы для обновления модификаций). Мы рекомендуем вам удалить все папки Big Wigs и установить его с нуля."

-- Loader / Options.lua
L["You are running an official release of Big Wigs %s (revision %d)"] = "Вы используете официальный выпуск Big Wigs %s (ревизия %d)"
L["You are running an ALPHA RELEASE of Big Wigs %s (revision %d)"] = "Вы используете альфа-версию Big Wigs %s (ревизия %d)"
L["You are running a source checkout of Big Wigs %s directly from the repository."] = "Вы используете отладочный Big Wigs %s прямо из репозитория."
L["There is a new release of Big Wigs available(/bwv). You can visit curse.com, wowinterface.com, wowace.com or use the Curse Updater to get the new release."] = "Доступна новая версия Big Wigs(/bwv). Чтобы загрузить её, зайдите на сайт curse.com, wowinterface.com, wowace.com или воспользуйтесь Curse Updater."
L["Your alpha version of Big Wigs is out of date(/bwv)."] = "Ваша альфа-версия Big Wigs устарела(/bwv)."

L.tooltipHint = "|cffeda55fЩёлкните|r, чтобы сбросить все запущенные модули. |cffeda55fAlt+Левый клик|r - чтобы отключить их. |cffeda55fПравый клик|r открыть настройки."
L["Active boss modules:"] = "Активные модули боссов:"
L["All running modules have been reset."] = "Все запущенные модули сброшены."
L["All running modules have been disabled."] = "Все запущенные модули были отключены."

L["There are people in your group with older versions or without Big Wigs. You can get more details with /bwv."] = "В вашей группе есть игроки с более ранними версиями или без Big Wigs. Для получения более подробной информации введите команду /bwv."
L["Up to date:"] = "Текущий:"
L["Out of date:"] = "Устарелый:"
L["No Big Wigs 3.x:"] = "Нет Big Wigs 3.x:"

L.coreAddonDisabled = "Big Wigs won't function properly since the addon %s is disabled. You can enable it from the addon control panel at the character selection screen."

-- Options.lua
L["Big Wigs Encounters"] = "Big Wigs Encounters"
L["Customize ..."] = "Настройки ..."
L["Profiles"] = "Профили"
L.introduction = "Welcome to Big Wigs, where the boss encounters roam. Please fasten your seatbelt, eat peanuts and enjoy the ride. It will not eat your children, but it will assist you in preparing that new boss encounter as a 7-course dinner for your raid group.\n"
L["Configure ..."] = "Настройка..."
L.configureDesc = "Closes the interface options window and lets you configure displays for things like bars and messages.\n\nIf you want to customize more behind-the-scenes things, you can expand Big Wigs in the left tree and find the 'Customize ...' subsection."
L["Sound"] = "Звук"
L.soundDesc = "Сообщения могут сопровождаться звуком. Некоторым людям легче услышать звук и опознать к какому он сообщению относиться, нежели читать сообщения.\n\n|cffff4411Даже когда отключено, по умолчанию звук объявления рейда будет сопровождать входящие объявления рейда от других игроков. Этот звук, отличаются от используемых звуков.|r"
L["Show Blizzard warnings"] = "Оповещения Blizzard"
L.blizzardDesc = "Blizzard provides their own messages for some abilities on some encounters. In our opinion, these messages are both way too long and descriptive. We try to produce smaller, more fitting messages that do not interfere with the gameplay, and that don't tell you specifically what to do.\n\n|cffff4411When off, Blizzards warnings will not be shown in the middle of the screen, but they will still show in your chat frame.|r"
L["Show addon warnings"] = "Показать сообщения аддона"
L.addonwarningDesc = "Big Wigs and other boss encounter addons can broadcast their messages to the group over the raid warning channel. These messages are typically wrapped in three stars (***), which is what Big Wigs looks for when deciding if it should block a message or not.\n\n|cffff4411Turning this option on can result in lots of spam and is not recommended.|r"
L["Flash and shake"] = "Мигание и тряска"
L["Flash"] = "Мигание"
L["Shake"] = "Тряска"
L.fnsDesc = "Некоторые способности/эффекты являются достаточно важными, которые нуждаются во внимания. Когда вы попадаете под эффект таких способностей/эффектов, Big Wigs воспроизводит мигание и тряску экрана.\n\n|cffff4411Если вы играете с включенными табличками, функция тряски не будет работать в связи с ограничениями Blizzard, экран будет только мигать.|r"
L["Raid icons"] = "Иконка рейда"
L.raidiconDesc = "Некоторые скрипты события используют иконки рейда, чтобы помечать игроков, которые представляют особый интерес для вашей группы. К примеру 'бомба'-тип эффекта и контроль разума.\n\n|cffff4411Применимо только когда вы Лидер группы/рейда!|r"
L["Whisper warnings"] = "Оповещения шепотом"
L.whisperDesc = "Отправлять коллегам уведомления шепотом об определённых способностях, которые их затрагивают.\n\n|cffff4411Применимо только когда вы Лидер группы/рейда!|r"
L["Broadcast"] = "Вывод сообщений"
L.broadcastDesc = "Выводить все сообщения Big Wigs, в канал объявлений рейду.\n\n|cffff4411Применимо только когда вы Лидер рейда или в группе 5-чел!|r"
L["Raid channel"] = "Канал рейда"
L["Use the raid channel instead of raid warning for broadcasting messages."] = "Для передачи сообщений, использовать канал рейда вместо объявлений рейду."
L["Minimap icon"] = "Иконка у мини карты"
L["Toggle show/hide of the minimap icon."] = "Показать/скрыть иконку у мини-карты."
L["Configure"] = "Настройка"
L["Test"] = "Тест"
L["Reset positions"] = "Сброс позиции"
L["Colors"] = "Цвета"
L["Select encounter"] = "Выберите событие"
L["List abilities in group chat"] = "Вывести способности в групповой чат"

L["BAR"] = "Полосы"
L["MESSAGE"] = "Сообщения"
L["ICON"] = "Иконка"
L["WHISPER"] = "Шепот"
L["SAY"] = "Сказать"
L["FLASHSHAKE"] = "Мигание и тряска"
L["PING"] = "Импульс"
L["EMPHASIZE"] = "Увеличение"
L["MESSAGE_desc"] = "Большинство способностей событий сопровождаются с одним или несколькими сообщениями, которые Big Wigs будет отображать на экране. Если вы отключите эту опцию, ни одно из сообщений, прилагаемый к этой опции, если таковые будут, не будет отображаться."
L["BAR_desc"] = "Полосы отображаются для некоторых способностей событий когда необходимо. Если эта способность сопровождается полоской, которую вы хотите скрыть, отключите эту опцию"
L["FLASHSHAKE_desc"] = "Некоторые способности могут быть более важными, чем другие. Если вы хотите, чтобы ваш экран мигал и трясся, при использовании таких способностей, отметьте эту опцию."
L["ICON_desc"] = "Big Wigs может отмечать пострадавших от способностей иконой. Это способствует их легкому обнаружению."
L["WHISPER_desc"] = "Некоторые эффекты являются достаточно важными, Big Wigs будет отсылать предупреждение шепотом, пострадавшей персоне."
L["SAY_desc"] = "Сообщения над головой персонажей легко обнаружить. Big Wigs будут использоваться канал \"сказать\" для оповещения персонажей поблизости о эффекте на вас."
L["PING_desc"] = "Иногда местонахождение играет не малую роль, Big Wigs будет издавать импульс по мини-карте, чтобы люди знали, где вы находитесь."
L["EMPHASIZE_desc"] = "Включив это, будет СУПЕР УВЕЛИЧЕНИЕ любого сообщение или полосы, связанные с способностью босса. Сообщение будет больше, полосы будет мигать и иметь различные цвета, при надвигающейся способности будут использоваться звуки для отсчета времени. В общем, вы сами всё увидите."
L["PROXIMITY"] = "Proximity display"
L["PROXIMITY_desc"] = "Abilities will sometimes require you to spread out. The proximity display will be set up specifically for this ability so that you will be able to tell at-a-glance whether or not you are safe."
L["Advanced options"] = "Расширенны опции"
L["<< Back"] = "<< назад"

L["About"] = "Об Big Wigs"
L["Main Developers"] = "Основ. разработчики"
L["Developers"] = "Разработчики"
L["Maintainers"] = "Помощники"
L["License"] = "Лицензия"
L["Website"] = "Сайт"
L["Contact"] = "Связь"
L["See license.txt in the main Big Wigs folder."] = "Смотрите license.txt в основной папке Big Wigs."
L["irc.freenode.net in the #wowace channel"] = "irc.freenode.net на канале #wowace"
L["Thanks to the following for all their help in various fields of development"] = "Благодарим следующих лиц за их помощь в различных областях развития"

