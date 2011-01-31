local L = BigWigs:NewBossLocale("Al'Akir", "ruRU")
if L then
	L.phase3_yell = "��������! ���� ����� �� � ����� ����������!"

	L.phase = "����� ���"
	L.phase_desc = "�������� � ����� ���."

	L.cloud_message = "�������� ������!"
	L.feedback_message = "%dx �������� �������"
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
