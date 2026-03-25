import os
import re
import shutil
import difflib
from parser import parse_power_report
from generator import get_rtl_patch
from validator import run_lint
from rtl_extractor import extract_full_always_block

def format_logic_to_insert(logic, target_reg, base_indent="  "):
    """Formats the Verilog logic from the power report with proper indentation and professional headers."""
    lines = [l.strip() for l in logic.split('\n') if l.strip()]
    formatted_lines = []
    
    level = 1
    indent_next = False
    
    for line in lines:
        # Pre-adjust level for 'end'
        if line.startswith('end'):
            level = max(1, level - 1)
            
        # Determine display indentation
        display_level = level
        if indent_next:
            display_level += 1
            indent_next = False
            
        # Add semicolon if missing (for declarations and assignments)
        if (not any(line.endswith(c) for c in [';', 'begin', 'end']) and 
            not any(line.startswith(k) for k in ['always', 'if', 'else', '@', '`'])):
            line += ';'
            
        formatted_lines.append(f"{base_indent * display_level}{line}")
        
        # Post-adjust level or set indent_next
        if line.startswith('begin'):
            level += 1
        elif (line.startswith('if') or line.startswith('else') or line.startswith('always')) and 'begin' not in line:
            indent_next = True
            
    header = [
        f"\n{base_indent}// " + "-"*75,
        f"{base_indent}// POWER OPTIMIZATION: AI-Injected Sequential Enable Logic",
        f"{base_indent}// Target Register: {target_reg}",
        f"{base_indent}// " + "-"*75
    ]
    footer = [f"{base_indent}// " + "-"*75 + "\n"]
    
    return '\n'.join(header + formatted_lines + footer)

def generate_and_save_diff(original_lines, new_lines, file_path, output_name):
    """Generates a git-style diff, prints it, and saves it to the diffs folder."""
    os.makedirs("diffs", exist_ok=True)
    
    diff = difflib.unified_diff(
        original_lines, 
        new_lines, 
        fromfile=f"a/{file_path}", 
        tofile=f"b/{output_name}",
        lineterm=''
    )
    
    diff_text = '\n'.join(list(diff))
    if not diff_text:
        return ""

    # Print to terminal with some basic coloring (if supported)
    print("\n--- GIT-STYLE DIFF ---")
    for line in diff_text.split('\n'):
        if line.startswith('+') and not line.startswith('+++'):
            print(f"\033[92m{line}\033[0m") # Green
        elif line.startswith('-') and not line.startswith('---'):
            print(f"\033[91m{line}\033[0m") # Red
        elif line.startswith('^'):
            print(f"\033[94m{line}\033[0m") # Blue
        else:
            print(line)
    print("----------------------\n")
    
    # Save to file
    diff_file_path = os.path.join("diffs", f"{output_name}.diff")
    with open(diff_file_path, 'w') as f:
        f.write(diff_text)
    
    return diff_file_path

def process_all_reports():
    os.makedirs("output_rtl", exist_ok=True)
    os.makedirs("diffs", exist_ok=True)
    reports = [f for f in os.listdir("reports") if f.endswith(".txt")]
    print(f"Found {len(reports)} reports.")

    for report_file in reports:
        print(f"\n>>> Processing: {report_file}")
        info = parse_power_report(os.path.join("reports", report_file))
        if not info:
            print(f"   [SKIP] Could not parse report: {report_file}")
            continue

        file_path = info['file_path']
        if not os.path.exists(file_path):
            print(f"   [SKIP] File not found: {file_path}")
            continue

        with open(file_path, 'r') as f:
            original_lines = f.readlines()

        if info['line_num'] > len(original_lines):
            print(f"   [SKIP] Line number {info['line_num']} out of range for {file_path}")
            continue

        target_line = original_lines[info['line_num'] - 1]
        context = extract_full_always_block(file_path, info['line_num'])
        
        # Get AI patch
        ai_patch = get_rtl_patch(context, info['target_reg'], info['en_signal'], target_line)

        # --- CLEANING AI OUTPUT ---
        patch_lines = [l for l in ai_patch.split('\n') if l.strip()]
        clean_patch = patch_lines[0] if patch_lines else ""
        clean_patch = re.sub(r"(\d+)d(\d+)", r"\1'd\2", clean_patch)
        clean_patch = clean_patch.replace("begin", "").replace("end", "").strip()
        if clean_patch.endswith(";"):
            clean_patch = clean_patch[:-1].strip()

        # --- APPLYING TO NEW FILE ---
        new_lines = []
        wire_injected = False
        
        # Find the end of module declaration to inject wires
        full_content = "".join(original_lines)
        module_decl_end = -1
        # Search for module ... );
        match = re.search(r"module\s+\w+.*?\);", full_content, re.DOTALL)
        if not match:
             # Try without ); for cases like module top(a,b);
             match = re.search(r"module\s+\w+.*?;", full_content, re.DOTALL)

        if match:
            module_decl_end_pos = match.end()
            current_pos = 0
            for idx, line in enumerate(original_lines):
                current_pos += len(line)
                if current_pos >= module_decl_end_pos:
                    module_decl_end = idx
                    break

        # Detect base indentation from the file
        base_indent = "  "
        if module_decl_end != -1 and module_decl_end + 1 < len(original_lines):
            for line in original_lines[module_decl_end+1:]:
                if line.strip():
                    m = re.match(r"^(\s+)", line)
                    if m:
                        base_indent = m.group(1)
                    break

        formatted_logic = format_logic_to_insert(info['logic_to_insert'], info['target_reg'], base_indent)

        for i, line in enumerate(original_lines):
            # Precision Line Replacement
            if (i + 1) == info['line_num']:
                indent = line[:line.find(line.lstrip())] if line.strip() else ""
                trailing = ""
                if ";" in line:
                    trailing = line.split(";", 1)[-1].strip()
                final_line = f"{indent}{clean_patch}; {trailing}\n"
                new_lines.append(final_line)
            else:
                new_lines.append(line)
            
            # A. Inject Wire Header after module declaration
            if i == module_decl_end and not wire_injected:
                if info['en_signal'] not in full_content:
                    new_lines.append(formatted_logic)
                wire_injected = True

        # --- SAVE TO OUTPUT FOLDER ---
        base_name = os.path.basename(file_path)
        name, ext = os.path.splitext(base_name)
        output_file_name = f"{name}_optimized{ext}"
        output_path = os.path.join("output_rtl", output_file_name)
        
        with open(output_path, 'w') as f:
            f.writelines(new_lines)
        
        # --- GENERATE DIFF ---
        diff_file = generate_and_save_diff(original_lines, new_lines, file_path, output_file_name)

        success, err = run_lint(output_path)
        if success:
            print(f"✅ SUCCESS: {info['target_reg']} optimized -> {output_path}")
            if diff_file:
                print(f"📄 Diff saved: {diff_file}")
        else:
            print(f"❌ LINT ERROR in {output_path}: {err}")

if __name__ == "__main__":
    process_all_reports()
