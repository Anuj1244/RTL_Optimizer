import os
from groq import Groq
client = Groq(api_key=os.environ.get("GROQ_API_KEY"))

def get_rtl_patch(context, register, enable_signal, target_line):
    # System prompt to keep the 70B model strictly on task
    system_msg = "You are an RTL Refactoring tool. You only wrap code in 'if' conditions. You NEVER change the original assignment logic."

    prompt = f"""
    CONTEXT:
    {context}

    TARGET REGISTER: {register}
    ENABLE SIGNAL: {enable_signal}
    TARGET LINE CONTENT: {target_line.strip()}

    TASK: 
    Wrap the assignment in TARGET LINE CONTENT with: if ({enable_signal})
    
    RETURNING RULE:
    Return ONLY the new line. Do NOT include 'begin' or 'end' or any other lines from the context.
    Example: if ({enable_signal}) {register} <= ...;
    """

    completion = client.chat.completions.create(
        model="llama-3.3-70b-versatile",
        messages=[
            {"role": "system", "content": system_msg},
            {"role": "user", "content": prompt}
        ],
        temperature=0.0
    )
    return completion.choices[0].message.content.strip()