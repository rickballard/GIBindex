#!/usr/bin/env python3
# Minimal validator for GIB entries without external deps.
import os, sys, yaml, re, datetime

def utc_ts(s):
    try:
        if not s.endswith('Z'): return False
        datetime.datetime.strptime(s, '%Y-%m-%dT%H:%M:%SZ')
        return True
    except Exception:
        return False

def check_entry(path, data):
    errs = []
    required = ['id','term','kind','definition','version','timestamp','status']
    for k in required:
        if k not in data: errs.append(f"missing: {k}")
    if 'id' in data and not re.match(r'^gib:[a-z0-9-]+:[a-z0-9-]+:v\d+$', data['id']):
        errs.append('bad id format')
    if 'timestamp' in data and not utc_ts(data['timestamp']):
        errs.append('bad timestamp (use UTC RFC3339, ...Z)')
    return errs

def main(root='entries'):
    bad = 0
    for dirpath, _, files in os.walk(root):
        for fn in files:
            if fn.endswith('.gib.yaml'):
                p = os.path.join(dirpath, fn)
                with open(p, 'r', encoding='utf-8') as f:
                    data = yaml.safe_load(f)
                errs = check_entry(p, data or {})
                if errs:
                    print(f"[FAIL] {p}:", *errs, sep=" ")
                    bad += 1
    if bad:
        print(f"Validation failed: {bad} file(s).")
        sys.exit(1)
    print("Validation passed.")
if __name__ == '__main__':
    try:
        import yaml  # noqa
    except Exception:
        print("Install pyyaml: pip install pyyaml")
        sys.exit(2)
    main()
