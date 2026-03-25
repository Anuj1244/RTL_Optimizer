import re

def run_lint(file_path):
    try:
        with open(file_path, 'r') as f:
            content = f.read()

        # Strict whole-word count
        begins = len(re.findall(r'\bbegin\b', content))
        ends = len(re.findall(r'\bend\b', content))

        if begins != ends:
            return False, f"Unbalanced blocks ({begins} begins / {ends} ends)"
        
        # Check for the common AI syntax error
        if re.search(r"\d+d\d+", content):
            return False, "Verilog constant syntax error (missing ' )"

        return True, ""
    except Exception as e:
        return False, str(e)