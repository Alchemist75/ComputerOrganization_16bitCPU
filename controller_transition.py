file_in = open('ControllerOld.vhd', 'r')
file_out = open('ControllerTransition.vhd', 'w')

signal_list = [	'RegSrcA', 	'RegSrcB', 	'ImmSrc', 	'ExtendOp',
				'RegDst',	'ALUOp',	'ALUSrcB', 	'ALURes',
				'Jump',		'BranchOp',	'Branch',	'MemRead',
				'MemWrite',	'MemToReg', 'RegWrite']

signal_len_list = [	4, 4, 3, 1,
					4, 4, 1, 2,
					1, 2, 1, 1,
					1, 1, 1]

skip_total = 2

for line in file_in:
	pos = line.find('controlerSignal')
	if pos != -1:
		if skip_total != 0:
			skip_total -= 1
			file_out.write(line)
		else:
			signal_i = 0
			start_pos = line.find('(') + 1
			end_pos = line.find(',', start_pos)
			content = line[start_pos: end_pos]

			tab_num = line.count('\t')

			while True:
				if content.find('"') != -1:
					content = content[1:len(content)-1]
					while content:
						signal = signal_list[signal_i]
						signal_content = content[:signal_len_list[signal_i]]

						if signal_len_list[signal_i] != 1:
							file_out.write('\t'*tab_num + signal + ' <= "' + signal_content + '";\n')
						else:
							file_out.write('\t'*tab_num + signal + ' <= \'' + signal_content + '\';\n')

						content = content[signal_len_list[signal_i]:]
						signal_i += 1
				else:
					signal = signal_list[signal_i]
					file_out.write('\t'*tab_num + signal + ' <= ' + content + ';\n')
					signal_i +=1

				if signal_i == 15:
					break

				start_pos = end_pos + 1
				if line[start_pos] == ' ':
					start_pos += 1
				end_pos = line.find(',', start_pos)
				if end_pos == -1:
					end_pos = line.find(')', start_pos)
				content = line[start_pos: end_pos]

	else:
		file_out.write(line)
