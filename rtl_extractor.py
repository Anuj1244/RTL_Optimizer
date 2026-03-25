def extract_full_always_block(file_path, line_num):
    try:
        with open(file_path, 'r') as f:
            lines = f.readlines()
        
        start = max(0, line_num - 15)
        end = min(len(lines), line_num + 5)
        
        context = ""
        for i in range(start, end):
            context += f"{i+1}: {lines[i]}"
        return context
    except:
        return "Error: File not found."
    