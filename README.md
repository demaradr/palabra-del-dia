# palabra-del-dia

## Word Data
- Bundled JSON files per language pair live in `Shared/Data/` (e.g., `words_es_en.json`, `words_de_en.json`).
- Schema fields: `id`, `source`, `target`, `sourceLanguage`, `targetLanguage`, `level`, `categories`, `examples`.
- Example sentences are stored as `source`/`target` pairs; the UI shows up to 2.

## Import Tool (CSV → JSON)
Use `scripts/convert_words.py` to generate JSON from a CSV export.

Required CSV columns:
```
id,source,target,sourceLanguage,targetLanguage,level,categories,example1_source,example1_target,example2_source,example2_target
```

Categories should be separated with `|`, e.g. `daily-life|home`.

Example:
```
python3 scripts/convert_words.py input.csv Shared/Data/words_es_en.json
```
