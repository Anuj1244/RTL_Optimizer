# RTL Optimizer (AI-Powered)

An automated tool for RTL power optimization using LLMs. It identifies registers with high switching activity from power reports and wraps them with sequential enable logic.

## Overview

Dynamic power consumption is a critical concern in modern digital designs, with clocking and register switching being major contributors. This tool automates the process of identifying power-hungry registers and refactoring the RTL to include sequential enable logic (clock gating at the register level) to reduce unnecessary switching.

## Key Features

- **Automated Parsing**: Extracts register and enable signal information from power reports.
- **Context-Aware Optimization**: Uses LLMs (Llama 3.3 70B via Groq) to intelligently refactor RTL without altering core logic.
- **Automated Validation**: Performs structural and syntax checks (balanced blocks, Verilog constant syntax) on generated RTL.
- **Diff Generation**: Visualizes optimizations using git-style diffs for easy review.

## File Structure

- `main.py`: Entry point for the optimization flow.
- `generator.py`: LLM interface for RTL refactoring.
- `parser.py`: Power report parser.
- `rtl_extractor.py`: RTL context extractor.
- `validator.py`: Basic RTL syntax validator.
- `templates/`: LLM prompt templates.
- `rtl/`: Input RTL designs.
- `output_rtl/`: Optimized RTL designs.
- `diffs/`: Diffs showing optimizations.
- `reports/`: Power analysis reports.

## Prerequisites

- Python 3.x
- `groq` library (`pip install groq`)
- Groq API Key (configured in `generator.py`)

## Usage

1. Place your Verilog/SystemVerilog files in the `rtl/` directory.
2. Place your power analysis reports (in `.txt` format) in the `reports/` directory.
3. Run the optimizer:
   ```bash
   python main.py
   ```
4. Find optimized RTL in `output_rtl/` and diffs in `diffs/`.

## Optimization Flow

1. **Input**: Power reports (.txt).
2. **Extraction**: Identify target register and enable signal.
3. **LLM Refactoring**: Wrap assignment in `if (enable)` condition.
4. **Code Insertion**: Inject enable logic and patch assignment.
5. **Validation & Diff**: Generate optimized RTL and diff reports.
