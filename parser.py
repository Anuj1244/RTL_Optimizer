import re
import os

def parse_power_report(report_path):
    info = {'target_reg': None, 'file_path': None, 'line_num': None, 'en_signal': None, 'logic_to_insert': ""}
    try:
        with open(report_path, 'r') as f:
            content = f.read()

        info['target_reg'] = re.search(r"Target Register\s*:(.*)", content).group(1).strip()
        raw_path = re.search(r"Target RTL Source\s*:(.*)", content).group(1).strip()
        info['file_path'] = raw_path.replace('E:', '/mnt/e').replace('\\', '/')
        info['line_num'] = int(re.search(r"Target RTL Source Line\s*:(.*)", content).group(1).strip())
        info['en_signal'] = f"seq_enable_{re.search(r'Sequential Enable Id\s*:(.*)', content).group(1).strip()}"

        logic_match = re.search(r"(wire seq_enable_.*)", content, re.DOTALL)
        if logic_match:
            info['logic_to_insert'] = logic_match.group(1).strip()

        return info
    except:
        return None