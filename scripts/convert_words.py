#!/usr/bin/env python3
import csv
import json
import sys
from pathlib import Path

def parse_categories(value: str) -> list[str]:
    if not value:
        return []
    parts = [p.strip() for p in value.split('|')]
    return [p for p in parts if p]

def main() -> int:
    if len(sys.argv) != 3:
        print("Usage: convert_words.py input.csv output.json")
        return 1

    input_path = Path(sys.argv[1])
    output_path = Path(sys.argv[2])

    rows = []
    with input_path.open(newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for i, row in enumerate(reader, start=2):
            if not row.get('id'):
                print(f"Row {i}: missing id")
                return 1
            source = row.get('source', '').strip()
            target = row.get('target', '').strip()
            if not source or not target:
                print(f"Row {i}: missing source/target")
                return 1

            source_lang = row.get('sourceLanguage', '').strip() or 'es-ES'
            target_lang = row.get('targetLanguage', '').strip() or 'en-US'

            examples = []
            ex1s = row.get('example1_source', '').strip()
            ex1t = row.get('example1_target', '').strip()
            if ex1s and ex1t:
                examples.append({'source': ex1s, 'target': ex1t})
            ex2s = row.get('example2_source', '').strip()
            ex2t = row.get('example2_target', '').strip()
            if ex2s and ex2t:
                examples.append({'source': ex2s, 'target': ex2t})

            entry = {
                'id': row['id'].strip(),
                'source': source,
                'target': target,
                'sourceLanguage': source_lang,
                'targetLanguage': target_lang,
                'level': row.get('level', '').strip() or 'beginner',
                'categories': parse_categories(row.get('categories', '').strip()),
                'examples': examples,
            }
            rows.append(entry)

    output_path.write_text(json.dumps(rows, ensure_ascii=False, indent=2), encoding='utf-8')
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
