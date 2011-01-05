local L = BigWigs:NewBossLocale("Al'Akir", "ruRU")
if L then
	L.windburst = (GetSpellInfo(87770))
	
	L.phase3_yell = "��������! ���� ����� �� � ����� ����������!"

	L.phase_change = "����� ���"
	L.phase_change_desc = "�������� � ����� ���."
	L.phase_message = "���� %d"

	L.feedback_message = "%dx �������� �������"

	L.you = "%s �� ���!"
end

local L = BigWigs:NewBossLocale("Conclave of Wind", "ruRU")
if L then
	L.gather_strength = "%s ������ � ��������� ���������� ����!"

	L.storm_shield = GetSpellInfo(95865)
	L.storm_shield_desc = "��� ���������� �����"

	L.full_power = "������ ����"
	L.full_power_desc = "�������� ����� ���� ��������� ������ ���� � �������� ��������� ����������� �����������."
	L.gather_strength_emote = "%s �������� ������� ���� ���������� ������ �����!"

	L.wind_chill = "�� ��� %s ������ ��������� �����"
end
